return {
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      require("neotest-python"),
      require("rustaceanvim.neotest"),
    },
  },
}
