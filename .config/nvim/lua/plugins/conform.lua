return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      rust = {
        {
          exe = "leptosfmt",
          args = { "--stdin", "--rustfmt" },
          stdin = true,
        },
      },
    },
  },
}
