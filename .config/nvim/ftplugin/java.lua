-- Java-specific LSP diagnostic configuration
-- This applies only to the current Java buffer

vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  signs = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  severity_sort = true,
  update_in_insert = false,
})
