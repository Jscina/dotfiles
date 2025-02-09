vim.g.rustaceanvim = {
  server = {
    settings = {
      ["rust-analyzer"] = {
        procMacro = {
          enable = true,
        },
      },
    },
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      setup = {
        rust_analyzer = function()
          return true
        end,
      },
      servers = {
        tailwindcss = {
          settings = {
            experimental = {
              classRegex = {
                '"(.*)"',
              },
            },
          },
        },
      },
    },
  },
}
