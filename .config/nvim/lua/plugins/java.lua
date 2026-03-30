return {
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      dap = {
        hotcodereplace = "auto",
        config_overrides = {
          {
            type = "java",
            request = "attach",
            name = "Attach to Vagrant Tomcat (port 5005)",
            hostName = "localhost",
            port = 5005,
            timeout = 30000,
            projectName = "jaru-core",
          },
        },
      },
      dap_main = {},
      test = true,
      root_dir = function(fname)
        local root = vim.fs.root(fname, vim.lsp.config.jdtls.root_markers)
        if root then
          return vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
        end
        return nil
      end,
      project_name = function(root_dir)
        if not root_dir then
          return nil
        end
        return root_dir:gsub("[/:]", "_"):gsub("^_", "")
      end,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          compile = {
            nullAnalysis = {
              mode = "disabled",
            },
          },
          errors = {
            incompleteClasspath = {
              severity = "ignore",
            },
          },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
          },
          configuration = {
            runtimes = {},
          },
          inlayHints = {
            parameterNames = {
              enabled = "all",
            },
          },
          imports = {
            groupRepositories = {
              "impl@maven",
            },
          },
        },
      },
      jdtls = {
        on_init = function(client)
          client.notify("workspace/didChangeConfiguration", {
            settings = {
              java = {
                project = {
                  importEnabled = false,
                  sources = {
                    importMode = "NO_IMPORT",
                  },
                },
              },
            },
          })
          return false
        end,
      },
    },
  },
}
