return {
  "xiyaowong/nvim-transparent",
  config = function()
    require("transparent").setup({
      extra_groups = {
        "NormalFloat",
      },
    })
  end,
}
