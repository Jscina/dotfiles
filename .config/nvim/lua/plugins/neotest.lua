return {
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      "neotest-python",
      require("rustaceanvim.neotest"),
    },
  },
}
