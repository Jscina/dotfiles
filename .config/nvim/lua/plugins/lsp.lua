vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        imports = {
          granularity = {
            group = "module",
          },
          prefix = "self",
        },
        cargo = {
          features = { "ssr" },
          loadOutDirsFromCheck = true,
          buildScripts = {
            enable = true,
          },
        },
        check = {
          features = { "ssr" },
        },
        checkOnSave = {
          features = { "ssr" },
          command = "clippy",
          extraArgs = { "--no-deps" },
        },
        procMacro = {
          enable = false,
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
