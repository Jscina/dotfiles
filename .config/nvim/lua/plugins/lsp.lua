return {
  {
    "neovim/nvim-lspconfig",
    opts = {
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
              procMacro = {
                ignored = { leptos_macro = { "server", "component" } },
              },
            },
          },
        },
        tailwindcss = {
          filetypes_include = { "rust" },
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
