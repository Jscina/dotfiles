-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Toggle Term Mappings
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end
-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

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
