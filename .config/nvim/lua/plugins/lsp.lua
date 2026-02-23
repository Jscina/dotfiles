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
        jdtls = function()
          -- jdtls is configured via ftplugin/java.lua
          return true
        end,
      },
      servers = {
        jdtls = {
          -- Disable auto-start, configured via ftplugin/java.lua
          autostart = false,
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
