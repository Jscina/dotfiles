return {
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      -- Enable DAP for debugging
      dap = {
        hotcodereplace = "auto",
        config_overrides = {
          -- Configuration for "Attach to Vagrant Tomcat (port 5005)"
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
      -- Enable automatic main class scanning
      dap_main = {},
      
      -- Enable java-test
      test = true,
      
      -- Override root_dir to ensure absolute path is used
      root_dir = function(fname)
        local root = vim.fs.root(fname, vim.lsp.config.jdtls.root_markers)
        if root then
          -- Convert to absolute path and remove trailing slash
          return vim.fn.fnamemodify(root, ":p"):gsub("/$", "")
        end
        return nil
      end,
      
      -- Override project_name to use sanitized full path instead of basename
      -- This prevents "Software does not exist" errors
      project_name = function(root_dir)
        if not root_dir then
          return nil
        end
        -- Use full path with special chars replaced to create unique project name
        return root_dir:gsub("[/:]", "_"):gsub("^_", "")
      end,
      
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          -- Suppress common warnings to improve performance
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
        },
      },
    },
  },
}
