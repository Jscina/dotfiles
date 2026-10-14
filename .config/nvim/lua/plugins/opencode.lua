-- Sandbox gate for opencode.nvim (finding S3). Anything that can write
-- ~/.local/state/opencode/service.json (sandbox-writable) could point nvim at a
-- fake/unsandboxed server, so `server.url` is a function that only ever hands
-- the plugin a loopback server proven to run under srt. A configured url is
-- authoritative: the plugin never calls `server.start` for it (discovery/init.lua
-- ~l.119), so this module launches the sandboxed launcher itself.
local PS = "/bin/ps"
local LSOF = "/usr/sbin/lsof"
local OPENCODE_BIN = "/opt/homebrew/bin/opencode"
local WAIT_MS = 15000
local POLL_MS = 500

local M = {}

local function launcher()
  return vim.fn.expand("~/dotfiles/bin/opencode-sandboxed")
end

function M.launch()
  vim.cmd("vsplit term://" .. vim.fn.fnameescape(launcher()) .. " | wincmd p")
end

function M.state_path()
  local base = vim.env.XDG_STATE_HOME
  if not base or base == "" then
    base = vim.fs.joinpath(vim.uv.os_homedir() or vim.env.HOME or "", ".local", "state")
  end
  return vim.fs.joinpath(base, "opencode", "service.json")
end

-- Run an absolute-path tool with an empty environment and a timeout.
local function run(cmd)
  local ok, res = pcall(function()
    return vim.system(cmd, { text = true, timeout = 3000, clear_env = true }):wait()
  end)
  if not ok or not res then
    return nil
  end
  return res.code, res.stdout or ""
end

-- ppid and full args of a pid; nil if the process does not exist.
local function proc(pid)
  local code, out = run({ PS, "-o", "ppid=,args=", "-p", tostring(pid) })
  if code ~= 0 then
    return nil
  end
  local ppid, args = out:match("^%s*(%d+)%s+(.-)%s*$")
  if not ppid then
    return nil
  end
  return { ppid = tonumber(ppid), args = args }
end

-- True if an ancestor of pid is the srt node process (sandbox-exec execs into its
-- child, so only the srt node parent stays in the tree).
local function via_srt(pid)
  local p = proc(pid)
  for _ = 1, 64 do
    if not p or p.ppid <= 1 then
      return false
    end
    p = proc(p.ppid)
    if p and p.args:find("/srt --settings ", 1, true) then
      return true
    end
  end
  return false
end

-- Prove pid is the sandboxed opencode listening on port. Returns ok, reason.
local function verify_pid(pid, port)
  local code, env = run({ PS, "eww", "-p", tostring(pid), "-o", "command=" })
  if code ~= 0 then
    return false, "cannot read process environment"
  end
  env = " " .. env:gsub("%s+", " ") .. " "
  if not env:find(" OPENCODE_SANDBOXED=1 ", 1, true) or not env:find(" SANDBOX_RUNTIME=1 ", 1, true) then
    return false, "sandbox markers missing"
  end
  local ccode, comm = run({ PS, "-o", "comm=", "-p", tostring(pid) })
  if ccode ~= 0 or vim.trim(comm) ~= OPENCODE_BIN then
    return false, "not the expected opencode binary"
  end
  if not via_srt(pid) then
    return false, "not a descendant of srt"
  end
  local lcode, lout = run({ LSOF, "-nP", "-a", "-p", tostring(pid), "-iTCP:" .. port, "-sTCP:LISTEN" })
  if lcode ~= 0 or not lout:find(":" .. port .. " (LISTEN)", 1, true) then
    return false, "pid does not listen on port " .. port
  end
  return true
end

---Verify the server registered in service.json is a sandboxed opencode.
---@param path string
---@return boolean ok
---@return string? reason
---@return table detail `{ status = "ok"|"missing"|"invalid"|"stale"|"forged", url?, password?, pid?, port? }`
function M.verify_registration(path)
  local okr, lines = pcall(vim.fn.readfile, path)
  if not okr or not lines or #lines == 0 then
    return false, "service.json not found", { status = "missing" }
  end
  local okd, reg = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not okd or type(reg) ~= "table" then
    return false, "service.json is not valid JSON", { status = "invalid" }
  end

  -- The plugin reads `url`; also accept explicit host/port.
  local host, port
  if type(reg.url) == "string" then
    host, port = reg.url:match("^http://([%w%.%-]+):(%d+)/?$")
    if not host then
      port = reg.url:match("^http://%[::1%]:(%d+)/?$")
      host = port and "::1" or nil
    end
  elseif reg.host ~= nil and reg.port ~= nil then
    host, port = reg.host, reg.port
  end
  port = tonumber(port)
  if host ~= "127.0.0.1" and host ~= "localhost" and host ~= "::1" then
    return false, "registered host is not loopback", { status = "invalid" }
  end
  if not port or port ~= math.floor(port) or port < 1 or port > 65535 then
    return false, "registered port is invalid", { status = "invalid" }
  end
  local pid = reg.pid
  if type(pid) ~= "number" or pid ~= math.floor(pid) or pid <= 1 then
    return false, "registered pid is invalid", { status = "invalid" }
  end

  local detail = { pid = pid, port = port }
  if not proc(pid) then
    detail.status = "stale"
    return false, "registered pid " .. pid .. " is not running", detail
  end
  local ok, reason = verify_pid(pid, port)
  if not ok then
    detail.status = "forged"
    return false, reason, detail
  end
  detail.status = "ok"
  detail.url = "http://" .. (host == "::1" and "[::1]" or host) .. ":" .. port
  detail.password = type(reg.password) == "string" and reg.password or nil
  return true, nil, detail
end

local function notify(msg)
  vim.notify("opencode: " .. msg, vim.log.levels.ERROR)
end

-- Module-level so repeated calls never spawn a second TUI.
local starting = false
local waiters = {}

local function finish(url)
  starting = false
  local pending = waiters
  waiters = {}
  for _, cb in ipairs(pending) do
    cb(url)
  end
end

local function refuse(reason, detail)
  if detail.status == "forged" then
    notify(("unsandboxed/forged opencode server registered at pid %d (%s); stop it"):format(detail.pid, reason))
  else
    notify("service.json rejected (" .. reason .. "); remove it and retry")
  end
end

---Resolve a verified server URL, launching the sandboxed launcher if needed.
---`o` (tests): path, launch, wait_ms, poll_ms.
---@param callback fun(url?: string)
---@param o? table
function M.resolve(callback, o)
  o = o or {}
  local path = o.path or M.state_path()

  local function try()
    local ok, reason, detail = M.verify_registration(path)
    if ok then
      local cfg_ok, cfg = pcall(require, "opencode.config")
      if detail.password and cfg_ok and cfg.opts and cfg.opts.server then
        cfg.opts.server.password = detail.password
      end
      return "ok", detail.url
    end
    if detail.status == "forged" or detail.status == "invalid" then
      refuse(reason, detail)
      return "refuse"
    end
    return "wait"
  end

  if starting then
    table.insert(waiters, callback)
    return
  end

  local state, url = try()
  if state == "ok" then
    return callback(url)
  elseif state == "refuse" then
    return callback(nil)
  end

  -- Nothing registered (or stale file): launch the sandboxed TUI ourselves.
  starting = true
  table.insert(waiters, callback)
  local launched = pcall(o.launch or M.launch)
  if not launched then
    notify("failed to launch " .. launcher())
    return finish(nil)
  end

  local timer = assert(vim.uv.new_timer())
  local elapsed = 0
  local poll = o.poll_ms or POLL_MS
  local limit = o.wait_ms or WAIT_MS
  timer:start(
    poll,
    poll,
    vim.schedule_wrap(function()
      elapsed = elapsed + poll
      local st, u = try()
      if st == "wait" and elapsed < limit then
        return
      end
      timer:stop()
      timer:close()
      if st == "ok" then
        finish(u)
      else
        if st == "wait" then
          notify(
            "no sandboxed opencode server registered within "
              .. math.floor(limit / 1000)
              .. "s; refusing to connect (needs opencode >= 2 writing service.json)"
          )
        end
        finish(nil)
      end
    end)
  )
end

return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim" },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        -- Only a verified srt-sandboxed loopback server is ever returned (see top of file).
        url = function(callback)
          M.resolve(callback)
        end,
        -- Unused by the plugin while `url` is set; kept pointing at the sandbox launcher.
        start = function()
          M.launch()
        end,
      },
    }
    -- Required for `opts.events.reload`.
    vim.o.autoread = true
    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Select opencode…" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })
  end,
}
