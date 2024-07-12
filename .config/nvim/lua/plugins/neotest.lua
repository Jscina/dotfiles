return {
  { "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    depenedencies = { "mrcjkb/rustaceanvim", "nvim-neotest/neotest-python", "marilari88/neotest-vitest" },
    opts = { adapters = {
      ["rustaceanvim.neotest"] = {},
      "neotest-python",
      "neotest-vitest",
    } },
  },
}
