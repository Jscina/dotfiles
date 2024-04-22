return {
  "ahmedkhalf/project.nvim",
  opts = {
    manual_mode = false,
    detection_methods = { "lsp", "pattern" },
    patterns = { ".git", "cargo.toml", "pyproject.toml", "package.json" },
    ignore_lsp = {},
    exclude_dirs = { "*/src-tauri/*", "~/dotfiles/*" },
    show_hidden = false,
    silent_chdir = true,
    scope_chdir = "global",
    datapath = vim.fn.stdpath("data"),
  },
  event = "VeryLazy",
  config = function(_, opts)
    require("project_nvim").setup(opts)
    require("lazyvim.util").on_load("telescope.nvim", function()
      require("telescope").load_extension("projects")
    end)
  end,
  keys = {
    { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
  },
}
