-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.tokyo_night_dark_float = false
vim.g.python3_host_prog = "/usr/bin/python3"
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = false

vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        --rustfmt = {
        --  overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
        --},
        diagnostics = {
          enable = true,
          disabled = { "unresolved-proc-macro" },
        },
        procMacro = {
          enable = true,
        },
      },
    },
  },
}
