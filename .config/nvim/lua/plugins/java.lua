local jdk17 = "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
local jdk25 = "/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home"

return {
  {
    "mfussenegger/nvim-jdtls",
    -- Append to LazyVim's default cmd (keeps exepath("jdtls") and lombok agent).
    opts_extend = { "cmd" },
    opts = {
      -- Run jdtls itself on JDK 21, regardless of $JAVA_HOME.
      cmd = {
        "--java-executable=" .. jdk25 .. "/bin/java",
        -- Mason's wrapper sets no -Xmx (JVM could grow to ~16 GB); cap at 6G for a
        -- 17-module project on a 64 GB machine. Remaining flags: vscode-java recommended.
        "--jvm-arg=-Xmx6G",
        "--jvm-arg=-XX:+UseParallelGC",
        "--jvm-arg=-XX:GCTimeRatio=4",
        "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
        "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
      },
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
      -- Disabled: runs a workspace-wide main-class scan on every LspAttach.
      -- Run manually when needed: :lua require('jdtls.dap').setup_dap_main_class_configs()
      dap_main = false,
      test = true,
      -- Merged into the jdtls start_or_attach config (jdtls client only). Drops diagnostics for
      -- unloaded files so neovim doesn't bufadd() thousands of buffers.
      jdtls = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function(...)
            return require("config.diagnostics").jdtls_publish_diagnostics_filter(...)
          end,
        },
      },
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
            runtimes = {
              { name = "JavaSE-17", path = jdk17, default = true },
              { name = "JavaSE-25", path = jdk25 },
            },
          },
          import = {
            gradle = {
              enabled = true,
              wrapper = { enabled = true },
              java = { home = jdk17 },
            },
            exclusions = {
              "**/node_modules/**",
              "**/.metadata/**",
              "**/archetype-resources/**",
              "**/META-INF/maven/**",
              "**/.opencode/**",
            },
          },
          -- Client-side inlay hints are disabled globally, so skip server work.
          inlayHints = {
            parameterNames = {
              enabled = "none",
            },
          },
          -- Skip fernflower-decompiled library sources in reference searches (speed, smaller results).
          references = { includeDecompiledSources = false },
          referencesCodeLens = { enabled = false },
          implementationCodeLens = "none",
          -- Keep autobuild enabled (default): disabling it breaks on-save diagnostics.
          maxConcurrentBuilds = 1,
          project = {
            -- Regex list; extends jdtls defaults (node_modules, .git). Don't filter `build`:
            -- generated annotation-processor sources are needed.
            resourceFilters = { "node_modules", "\\.git", "\\.gradle", "\\.opencode" },
          },
          imports = {
            groupRepositories = {
              "impl@maven",
            },
          },
        },
      },
    },
  },
}
