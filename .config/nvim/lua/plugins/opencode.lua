return {
  "NickvanDyke/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    prompts = {
      commit = {
        description = "Generate commit message with commitizen convention from staged changes",
        prompt = "Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.",
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>ot", function() require("opencode").toggle() end, desc = "Toggle embedded opencode", },
    { "<leader>oa", function() require("opencode").ask() end, desc = "Ask opencode", mode = "n", },
    { "<leader>oa", function() require("opencode").ask("@selection: ") end, desc = "Ask opencode about selection", mode = "v", },
    { "<leader>op", function() require("opencode").select_prompt() end, desc = "Select prompt", mode = { "n", "v", }, },
    { "<leader>on", function() require("opencode").command("session_new") end, desc = "New session", },
    { "<leader>oy", function() require('opencode').command('messages_copy') end, desc = "Copy last message", },
    { "<S-C-u>",    function() require("opencode").command("messages_half_page_up") end, desc = "Scroll messages up", },
    { "<S-C-d>",    function() require("opencode").command("messages_half_page_down") end, desc = "Scroll messages down", },
  },
}
