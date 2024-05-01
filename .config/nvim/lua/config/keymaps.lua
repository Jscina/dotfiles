-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Keymaps for LazyDocker
vim.keymap.set("n", "<leader>k", "<cmd>LazyDocker<CR>", { desc = "Toggle LazyDocker", noremap = true, silent = true })

-- Keymaps for Dev Container
vim.keymap.set(
  "n",
  "<leader>Dr",
  "<cmd>DevcontainerStart<CR>",
  { desc = "Start Container", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>Da",
  "<cmd>DevcontainerAttach<CR>",
  { desc = "Attach Container", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>De",
  "<cmd>DevcontainerExec<CR>",
  { desc = "Exceute Command in Container", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>Ds",
  "<cmd>DevcontainerStop<CR>",
  { desc = "Stop Container", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>Df",
  "<cmd>DevcontainerStopAll<CR>",
  { desc = "Stop All Containers", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>DA",
  "<cmd>DevcontainerRemoveAll<CR>",
  { desc = "Remove All Containers", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>Dl",
  "<cmd>DevcontainerLogs<CR>",
  { desc = "Container Logs", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>Dc",
  "<cmd>DevcontainerEditNearestConfig<CR>",
  { desc = "Edit Container Config", noremap = true, silent = true }
)

-- UFO Keymaps
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
vim.keymap.set("n", "<leader>ua", "<cmd>UfoEnable<CR>", { desc = "Enable UFO", noremap = true, silent = true })
