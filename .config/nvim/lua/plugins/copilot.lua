return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = function()
      return {
        window = {
          layout = "vertical",
        },
      }
    end,
    keys = {
      { "<leader>am", ":CopilotChatModels<CR>", desc = "Open Copilot Chat Models", mode = { "n", "v" } },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = function()
      require("copilot.api").status = require("copilot.status")
    end,
  },
}
