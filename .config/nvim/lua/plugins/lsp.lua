return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        rust_analyzer = {
          standalone = true,
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                enable = true,
                disabled = { "unresolved-proc-macro" },
                enableExperimental = true,
              },
            },
          },
        },
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
