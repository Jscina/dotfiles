-- Java-specific LSP diagnostic configuration
-- This reduces the diagnostic load for large Java projects

-- Configure diagnostic display to only show errors, or limit severity
vim.diagnostic.config({
  virtual_text = {
    -- Only show errors in virtual text, ignore warnings and info
    severity = { min = vim.diagnostic.severity.WARN },
    -- Optionally limit how many diagnostics to show
    -- limit = 5,
  },
  signs = {
    -- Only show error signs in the gutter
    severity = { min = vim.diagnostic.severity.WARN },
  },
  underline = {
    -- Only underline errors
    severity = { min = vim.diagnostic.severity.WARN },
  },
  -- Sort diagnostics by severity (errors first)
  severity_sort = true,
  -- Don't update diagnostics while typing
  update_in_insert = false,
}, vim.api.nvim_get_current_buf())
