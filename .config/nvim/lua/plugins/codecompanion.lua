-- MCP servers run inside the Anthropic sandbox-runtime (srt, macOS Seatbelt):
-- see ~/dotfiles/.config/srt/mcp.json (public servers) and mcp-ado.json (ADO).
-- nvim's own environment (all ~/.secrets tokens) never reaches them: `env -i`
-- runs OUTSIDE srt, so the sandboxed tree starts with an allowlisted env. If srt
-- cannot be resolved the server is skipped with a warning (never plain npx).
local SRT_DIR = vim.fn.expand("~/dotfiles/.config/srt")
local CACHE_BASE = vim.fn.expand("~/.cache/codecompanion-mcp")

-- Exact pins (npm view, 2026-10). ADO: stable 2.10.0 supports `--authentication
-- envvar` (reads ADO_MCP_AUTH_TOKEN), so the old `@next` nightly tag is not needed.
local PIN = {
  context7 = "@upstash/context7-mcp@4.4.1",
  mcp_remote = "mcp-remote@0.14.3",
  ado = "@azure-devops/mcp@2.10.0",
}

-- CodeCompanion needs a cmd for default servers; a no-op stub means "skipped".
local function skipped()
  return { cmd = { "/usr/bin/false" } }
end

local function warn(msg)
  vim.schedule(function()
    vim.notify("codecompanion MCP: " .. msg, vim.log.levels.WARN)
  end)
end

-- Newest nvm node (numeric version sort) with major >= 24 (NODE_USE_ENV_PROXY)
-- that has srt, node and npx. nvm is not writable from inside the sandbox.
local function resolve_nvm_bin()
  local root = vim.fn.expand("~/.nvm/versions/node")
  local found = {}
  for name, kind in vim.fs.dir(root) do
    local maj, min, pat = name:match("^v(%d+)%.(%d+)%.(%d+)$")
    if maj and (kind == "directory" or kind == "link") then
      table.insert(found, { tonumber(maj), tonumber(min), tonumber(pat), root .. "/" .. name .. "/bin" })
    end
  end
  table.sort(found, function(a, b)
    for i = 1, 3 do
      if a[i] ~= b[i] then
        return a[i] > b[i]
      end
    end
    return false
  end)
  for _, v in ipairs(found) do
    local bin = v[4]
    if
      v[1] >= 24
      and vim.fn.executable(bin .. "/srt") == 1
      and vim.fn.executable(bin .. "/node") == 1
      and vim.fn.executable(bin .. "/npx") == 1
    then
      return bin
    end
  end
end

-- A private directory we own (not a symlink, mode 700), created if missing.
local function private_dir(path)
  local uid = vim.uv.os_get_passwd().uid
  if vim.fn.isdirectory(path) == 0 and vim.fn.mkdir(path, "p", 448) == 0 then
    return false
  end
  local st = vim.uv.fs_lstat(path)
  if not st or st.type ~= "directory" or st.uid ~= uid then
    return false
  end
  return vim.uv.fs_chmod(path, 448) == true
end

-- Build the srt-wrapped command for one server class ("public" or "ado").
-- `pass` lists nvim env var names handed through to the sandboxed tree.
-- `extra_env` is a list of literal NAME=value entries (never secrets).
local function sandboxed(kind, settings, argv, pass, extra_env)
  local bin = resolve_nvm_bin()
  if not bin then
    warn(
      "no nvm node >= 24 with srt; run: nvm install 24 && npm install -g @anthropic-ai/sandbox-runtime. Server skipped."
    )
    return nil
  end
  local settings_path = SRT_DIR .. "/" .. settings
  if vim.fn.filereadable(settings_path) == 0 then
    warn("srt settings not found: " .. settings_path .. ". Server skipped.")
    return nil
  end
  local dir = CACHE_BASE .. "/" .. kind
  for _, d in ipairs({ CACHE_BASE, dir, dir .. "/npm-cache", dir .. "/mcp-auth", dir .. "/tmp" }) do
    if not private_dir(d) then
      warn(d .. " is not a private directory we own. Server skipped.")
      return nil
    end
  end
  local home = vim.uv.os_homedir()

  -- Inside the sandbox: srt forces TMPDIR=/tmp/claude (shared with opencode) and
  -- adds RFC1918 ranges to NO_PROXY; point TMPDIR at our private dir and narrow NO_PROXY.
  local inner = {
    "/bin/sh",
    "-c",
    'TMPDIR=$1; shift; NO_PROXY=localhost,127.0.0.1,::1; no_proxy=$NO_PROXY; export TMPDIR NO_PROXY no_proxy; exec "$@"',
    "mcp-sandbox",
    dir .. "/tmp",
    bin .. "/npx",
    "-y",
  }
  vim.list_extend(inner, argv)

  local env = {
    "HOME=" .. home,
    "PATH=" .. bin .. ":/usr/bin:/bin",
    "npm_config_cache=" .. dir .. "/npm-cache",
    "npm_config_update_notifier=false",
    "MCP_REMOTE_CONFIG_DIR=" .. dir .. "/mcp-auth",
    "NODE_USE_ENV_PROXY=1",
    "NODE_EXTRA_CA_CERTS=" .. home .. "/.certs/ZscalerRootCA.pem",
  }

  vim.list_extend(env, extra_env or {})

  local srt = { bin .. "/node", bin .. "/srt", "--settings", settings_path, "--" }
  vim.list_extend(srt, inner)

  if not pass or #pass == 0 then
    -- No secrets needed: env -i is cmd[1], nvim's env is dropped immediately.
    local cmd = { "/usr/bin/env", "-C", dir, "-i" }
    vim.list_extend(cmd, env)
    vim.list_extend(cmd, srt)
    return cmd
  end

  -- Pass named vars by reference ("$NAME" expanded by sh, never in argv/logs).
  -- No "${" anywhere: CodeCompanion rewrites ${...} in cmd strings.
  local refs = {}
  for _, name in ipairs(pass) do
    table.insert(refs, name .. '="$' .. name .. '"')
  end
  local script = 'dir=$1; shift; exec /usr/bin/env -C "$dir" -i ' .. table.concat(refs, " ") .. ' "$@"'
  local cmd = { "/bin/sh", "-c", script, "mcp-launch", dir }
  vim.list_extend(cmd, env)
  vim.list_extend(cmd, srt)
  return cmd
end

local function public_server(argv)
  return function()
    local cmd = sandboxed("public", "mcp.json", argv)
    return cmd and { cmd = cmd } or skipped()
  end
end

local function public_server_with_env(argv, pass)
  return function()
    local cmd = sandboxed("public", "mcp.json", argv, pass)
    return cmd and { cmd = cmd } or skipped()
  end
end

return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    opts = {
      adapters = {
        http = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                keep_alive = { default = "30m" },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = {
            name = "ollama",
            model = "qwen3.6:35b-a3b",
          },
          -- Built-in tools run unsandboxed inside nvim with user privileges, so
          -- every tool that writes, reads files or reaches the network asks first.
          -- `protect` keeps them asking in Auto mode too (only YOLO ignores it).
          tools = {
            -- Shell tool disabled; re-enable by removing `enabled = false` (still gated).
            ["run_command"] = {
              enabled = false,
              opts = {
                require_approval_before = true,
                require_cmd_approval = true,
                protect = true,
                safe_commands = {},
              },
            },
            ["delete_file"] = {
              opts = { require_approval_before = true, require_cmd_approval = true, protect = true },
            },
            ["create_file"] = {
              opts = { require_approval_before = true, protect = true },
            },
            ["insert_edit_into_file"] = {
              opts = {
                require_approval_before = { buffer = false, file = false },
                require_confirmation_after = true,
                protect = true,
              },
            },
            ["read_file"] = {
              opts = { require_approval_before = true, protect = true },
            },
            ["grep_search"] = {
              opts = { require_approval_before = true, protect = true },
            },
            -- Network egress from nvim's unsandboxed process.
            ["fetch_webpage"] = { opts = { require_approval_before = true, protect = true } },
            ["web_search"] = { opts = { require_approval_before = true, protect = true } },
          },
        },
        inline = {
          adapter = {
            name = "ollama",
            model = "qwen3.6:35b-a3b",
          },
        },
      },
      display = { diff = { enabled = true, threshold_for_chat = 0 } },
      -- MCP (stdio only). Intentionally omitted from opencode.json:
      --   azure:  very large tool surface and write operations.
      --   github: remote-HTTP-only with a huge tool surface; overwhelms a local model.
      mcp = {
        servers = {
          -- stdio-native, tiny tool surface
          context7 = public_server_with_env({ PIN.context7 }, { "CONTEXT7_API_KEY" }),
          grep_app = public_server({ PIN.mcp_remote, "https://mcp.grep.app" }),
          websearch = public_server_with_env(
            { PIN.mcp_remote, "https://mcp.exa.ai/mcp", "--header", "x-api-key:$EXA_API_KEY" },
            { "EXA_API_KEY" }
          ),
          -- remote HTTP servers bridged to stdio via mcp-remote
          -- large tool surface: manual start only, approval required for every tool.
          -- Own sandbox profile so the PAT is never in a process that can reach the
          -- public MCP hosts. Only ADO_MCP_AUTH_TOKEN is passed in.
          ado = function()
            local org = os.getenv("ADO_ORG")
            local pat = os.getenv("ADO_MCP_AUTH_TOKEN")
            if not org or org == "" or not pat or pat == "" then
              warn("ADO_ORG / ADO_MCP_AUTH_TOKEN not set in nvim's environment; ado server skipped.")
              return skipped()
            end
            local cmd = sandboxed(
              "ado",
              "mcp-ado.json",
              { PIN.ado, org, "--authentication", "envvar" },
              { "ADO_MCP_AUTH_TOKEN" },
              { "NODE_OPTIONS=--require=" .. SRT_DIR .. "/mcp-ado-preload.cjs" }
            )
            return cmd and { cmd = cmd, tool_defaults = { require_approval_before = true } } or skipped()
          end,
        },
        opts = {
          default_servers = { "context7", "grep_app", "websearch" },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
