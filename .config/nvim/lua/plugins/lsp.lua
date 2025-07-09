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
        snyk_ls = function(_, opts)
          opts.cmd = { "/usr/local/bin/snyk", "language-server" }
          return false
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
        snyk_ls = {
          init_options = {
            activateSnykCode = "true",
            authenticationMethod = "oauth",
            automaticAuthentication = "true",
          },
        },
      },
    },
  },
}
