-- Diagnostics helpers: jdtls publishDiagnostics filter + :DiagStats / :DiagPurge.
local M = {}

-- Max diagnostics forwarded per file (override with vim.g.jdtls_max_diagnostics).
M.max_diagnostics = 200

--- Exact loaded-buffer lookup by path (no pattern matching, never creates a buffer).
local function find_loaded_buf(fname)
  local bufs = vim.api.nvim_list_bufs()
  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b) == fname then
      return b
    end
  end
  local real = vim.uv.fs_realpath(fname)
  if not real then
    return nil
  end
  for _, b in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(b) then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= "" and vim.uv.fs_realpath(name) == real then
        return b
      end
    end
  end
  return nil
end

--- jdtls-only `textDocument/publishDiagnostics` handler (signature: err, result, ctx[, config]).
--- Neovim's default handler bufadd()s every published file; drop payloads for files not loaded.
function M.jdtls_publish_diagnostics_filter(err, result, ctx, config)
  local handler = vim.lsp.diagnostic.on_publish_diagnostics
  if type(result) ~= "table" or type(result.uri) ~= "string" then
    return handler(err, result, ctx, config)
  end

  if not find_loaded_buf(vim.uri_to_fname(result.uri)) then
    return
  end

  local cap = vim.g.jdtls_max_diagnostics or M.max_diagnostics
  local errors, warnings = {}, {}
  for _, d in ipairs(result.diagnostics or {}) do
    local sev = d.severity or 1 -- missing severity treated as ERROR
    if sev == 1 then
      errors[#errors + 1] = d
    elseif sev == 2 then
      warnings[#warnings + 1] = d
    end
  end
  local kept = {}
  for _, list in ipairs({ errors, warnings }) do
    for _, d in ipairs(list) do
      if #kept >= cap then
        break
      end
      kept[#kept + 1] = d
    end
  end

  -- Shallow copy: the original payload is left untouched. Empty lists still pass (clears stale).
  return handler(err, vim.tbl_extend("force", result, { diagnostics = kept }), ctx, config)
end

local function stats()
  local bufs = vim.fn.getbufinfo()
  local loaded, unloaded_diag, with_diag = 0, 0, 0
  local sev = { 0, 0, 0, 0 }
  for _, b in ipairs(bufs) do
    if b.loaded == 1 then
      loaded = loaded + 1
    end
    local counts = vim.diagnostic.count(b.bufnr)
    local n = 0
    for s, c in pairs(counts) do
      sev[s] = (sev[s] or 0) + c
      n = n + c
    end
    if n > 0 then
      with_diag = with_diag + 1
      if b.loaded ~= 1 then
        unloaded_diag = unloaded_diag + 1
      end
    end
  end
  local S = vim.diagnostic.severity
  print(table.concat({
    ("listed buffers:            %d"):format(#vim.fn.getbufinfo({ buflisted = 1 })),
    ("total buffers:             %d"):format(#bufs),
    ("loaded buffers:            %d"):format(loaded),
    ("unloaded w/ diagnostics:   %d"):format(unloaded_diag),
    ("buffers with diagnostics:  %d"):format(with_diag),
    ("diagnostics: total=%d  ERROR=%d  WARN=%d  INFO=%d  HINT=%d"):format(
      sev[S.ERROR] + sev[S.WARN] + sev[S.INFO] + sev[S.HINT],
      sev[S.ERROR],
      sev[S.WARN],
      sev[S.INFO],
      sev[S.HINT]
    ),
  }, "\n"))
end

local function purge()
  local purged = 0
  for _, b in ipairs(vim.fn.getbufinfo()) do
    local nr = b.bufnr
    if
      b.loaded ~= 1
      and b.listed == 0
      and b.changed ~= 1
      and #vim.fn.win_findbuf(nr) == 0
      and vim.bo[nr].buftype == ""
    then
      pcall(vim.diagnostic.reset, nil, nr)
      if pcall(vim.cmd, "bwipeout " .. nr) then
        purged = purged + 1
      end
    end
  end
  print(("DiagPurge: purged %d buffers"):format(purged))
end

vim.api.nvim_create_user_command("DiagStats", stats, { desc = "Buffer/diagnostic counts" })
vim.api.nvim_create_user_command("DiagPurge", purge, { desc = "Wipe unloaded buffers + their diagnostics" })

return M
