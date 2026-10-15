return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim" },
  },
  config = function()
    -- OpenCode v2 runs a single background daemon that all clients attach to.
    -- Discovery finds that daemon (via its state file) before it ever calls
    -- `server.start`, so `start` alone won't surface a window once the daemon
    -- is already running headless. Open it in a snacks.terminal instead, and
    -- auto-show it when a prompt starts executing so `ask()`/`select()` don't
    -- appear to do nothing.
    local opencode_cmd = "opencode"
    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = {
      win = { position = "right", enter = false },
    }

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          return require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }
    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    vim.api.nvim_create_autocmd("User", {
      pattern = "OpencodeEvent:session.execution.started",
      callback = function()
        local win = require("snacks.terminal").get(opencode_cmd, { create = false })
        if win then
          win:show()
        end
      end,
    })

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Select opencode…" })
    -- `n` only: a leader-based mapping in `t` mode delays every <leader> keystroke
    -- typed inside terminal buffers while Neovim waits to see if it matches.
    vim.keymap.set("n", "<leader>ot", function()
      require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
    end, { desc = "Toggle opencode window" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })
  end,
}
