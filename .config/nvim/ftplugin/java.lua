local jdtls = require('jdtls')

-- Find root of project
local root_markers = {'gradlew', 'mvnw', '.git', 'pom.xml', 'build.gradle'}
local root_dir = require('jdtls.setup').find_root(root_markers)

-- Use the project name for workspace folder
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. project_name .. '/workspace'

-- Get the jdtls install location
local jdtls_install = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

-- Get platform config
local os_config = 'config_mac'
if vim.fn.has('linux') == 1 then
  os_config = 'config_linux'
elseif vim.fn.has('win32') == 1 then
  os_config = 'config_win'
end

-- Find the jar file
local jar_patterns = {
  jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar'
}
local jar_file = vim.fn.glob(jar_patterns[1])

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', jar_file,
    '-configuration', jdtls_install .. '/' .. os_config,
    '-data', workspace_dir,
  },
  root_dir = root_dir,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*", "sun.*",
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
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        useBlocks = true,
      },
      configuration = {
        runtimes = {}
      }
    }
  },
  init_options = {
    bundles = {}
  },
}

-- Load java-debug and java-test bundles
local bundles = {}

-- java-debug
local java_debug_path = vim.fn.stdpath('data') .. '/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin-*.jar'
vim.list_extend(bundles, vim.split(vim.fn.glob(java_debug_path), "\n"))

-- java-test
local java_test_path = vim.fn.stdpath('data') .. '/mason/share/java-test/*.jar'
for _, bundle in ipairs(vim.split(vim.fn.glob(java_test_path), "\n")) do
  if not vim.endswith(bundle, 'com.microsoft.java.test.runner-jar-with-dependencies.jar') and
     not vim.endswith(bundle, 'jacocoagent.jar') then
    table.insert(bundles, bundle)
  end
end

-- Update config with bundles
config.init_options.bundles = bundles

-- Start or attach to jdtls
jdtls.start_or_attach(config)
