vim.g.rustaceanvim = {
  server = {
    settings = {
      ["rust-analyzer"] = {
        check = {
          command = "clippy",
          extraArgs = { "--all-features", "--workspace" },
        },
        procMacro = {
          enable = true,
        },
      },
    },
  },
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = opts.inlay_hints or {}
      opts.inlay_hints.enabled = false

      opts.setup = opts.setup or {}
      opts.setup.rust_analyzer = function()
        return true
      end

      opts.servers = opts.servers or {}

      opts.servers.tailwindcss = {
        settings = {
          experimental = {
            classRegex = {
              '"(.*)"',
            },
          },
        },
      }
      return opts
    end,
  },
}
