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
          filetypes = { "rust" },
          settings = {
            experimental = {
              classRegex = {
                'class="(.*)"',
              },
            },
          },
        },
      },
    },
  },
}
