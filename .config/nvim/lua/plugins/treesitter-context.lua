return {
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
  {
    "rayliwell/tree-sitter-rstml",
    dependencies = { "nvim-treesitter" },
    build = ":TSUpdate",
    config = function()
      require("tree-sitter-rstml").setup()
    end,
  },
}
