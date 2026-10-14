return {
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    opts = {
      interactions = {
        chat = {
          adapter = {
            name = "ollama",
            model = "qwen3.6:35b-a3b",
          },
        },
        inline = {
          adapter = {
            name = "ollama",
            model = "qwen3.6:35b-a3b",
          },
        },
      },
      -- MCP (stdio only). Intentionally omitted from opencode.json:
      --   azure:  very large tool surface and write operations.
      --   github: remote-HTTP-only with a huge tool surface; overwhelms a local model.
      mcp = {
        servers = {
          -- stdio-native, tiny tool surface
          context7 = {
            cmd = { "npx", "-y", "@upstash/context7-mcp@latest" },
          },
          -- remote HTTP servers bridged to stdio via mcp-remote
          grep_app = {
            cmd = { "npx", "-y", "mcp-remote", "https://mcp.grep.app" },
          },
          websearch = {
            cmd = { "npx", "-y", "mcp-remote", "https://mcp.exa.ai/mcp" },
          },
          -- large tool surface: manual start only, approval required for every tool
          ado = function()
            return {
              cmd = { "npx", "-y", "@azure-devops/mcp@next", os.getenv("ADO_ORG") or "", "--authentication", "envvar" },
              tool_defaults = { require_approval_before = true },
            }
          end,
        },
        opts = {
          default_servers = { "context7", "grep_app" },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = {},
      },
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
