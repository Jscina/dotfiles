return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = function()
    return {
      window = {
        layout = "float",
      },
    }
  end,
  keys = {
    { "<leader>am", ":CopilotChatModels<CR>", desc = "Open Copilot Chat Models", mode = { "n", "v" } },
  },
}
