return {
  { "marilari88/neotest-vitest" },
  { "nvim-neotest/neotest-jest" },
  {
    "nvim-neotest/neotest",
    depenedencies = {
      "mrcjkb/rustaceanvim",
      "nvim-neotest/neotest-python",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},
        "neotest-python",
        "neotest-vitest",
        "neotest-jest",
      },
    },
  },
}
