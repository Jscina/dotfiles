return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        provider = "openai_fim_compatible",
        n_completions = 2, -- recommended for local models to save resources
        -- Start with a small context window and increase it gradually,
        -- depending on your local computing power.
        context_window = 512,
        provider_options = {
          openai_fim_compatible = {
            -- Ollama needs an arbitrary non-null env var as a placeholder
            api_key = "TERM",
            name = "Ollama",
            end_point = "http://localhost:11434/v1/completions",
            model = "qwen2.5-coder:7b-base",
            optional = {
              max_tokens = 56,
              top_p = 0.9,
            },
          },
        },
        virtualtext = {
          auto_trigger_ft = { "*" }, -- enables auto-triggering for all filetypes
          auto_trigger_ignore_ft = {},
          show_on_completion_menu = true, -- ensures ghost text works even when blink is active
          keymap = {
            accept = "<A-A>", -- accept whole suggestion
            accept_line = "<A-a>", -- accept one line
            accept_n_lines = "<A-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },
      })
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        -- manually trigger minuet completion
        ["<A-y>"] = {
          function(cmp)
            cmp.show({ providers = { "minuet" } })
          end,
        },
      },
      sources = {
        -- lazy.nvim merges list opts, so this appends to the defaults.
        -- Remove "minuet" here for manual-only completion.
        default = { "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            -- should match minuet's request_timeout (default 3s) * 1000
            timeout_ms = 3000,
            score_offset = 100,
          },
        },
      },
      -- recommended by minuet to avoid unnecessary requests
      completion = { trigger = { prefetch_on_insert = false } },
    },
  },
}
