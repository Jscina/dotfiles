-- Keep fzf-lua responsive on the large Java monorepo.
-- Merges on top of LazyVim's fzf extra opts (keymaps/actions are preserved).
-- Tip: launching nvim from .../connect-plus/Software (instead of the monorepo root) narrows the search root.
return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    local defaults = require("fzf-lua.defaults").defaults

    -- Append flags to the installed default command, keeping a trailing `-e` last.
    local function append(cmd, extra)
      local base, has_e = cmd:gsub("%s+%-e%s*$", "")
      return base .. " " .. extra .. (has_e > 0 and " -e" or "")
    end

    local rg_excludes = table.concat({
      "-g '!**/build/**'",
      "-g '!**/.gradle/**'",
      "-g '!**/node_modules/**'",
      "-g '!**/target/**'",
      "-g '!**/.git/**'",
      "-g '!*.min.js'",
      "-g '!*.map'",
      "-g '!*.jar'",
      "-g '!*.class'",
      "-g '!*.log'",
    }, " ")

    local fd_excludes = table.concat({
      "--exclude build",
      "--exclude .gradle",
      "--exclude node_modules",
      "--exclude target",
      "--exclude '*.class'",
      "--exclude '*.jar'",
    }, " ")

    local bigfile_lines = vim.g.java_bigfile_lines or 3000

    return vim.tbl_deep_extend("force", opts, {
      defaults = {
        git_icons = false,
      },
      grep = {
        rg_opts = append(
          defaults.grep.rg_opts,
          "--max-columns-preview --max-filesize=1M " .. rg_excludes
        ),
        git_icons = false,
        query_delay = 200, -- ms debounce for live grep
      },
      files = {
        fd_opts = append(defaults.files.fd_opts, fd_excludes),
        rg_opts = append(defaults.files.rg_opts, rg_excludes),
        git_icons = false,
      },
      previewers = {
        builtin = {
          syntax_limit_b = 100 * 1024,
          syntax_limit_l = bigfile_lines,
          limit_b = 1024 * 1024,
          -- treesitter stays enabled; syntax_limit_* above gate it for large files
        },
      },
      lsp = {
        async_or_timeout = true, -- non-blocking requests (jdtls can be slow)
      },
    })
  end,
}
