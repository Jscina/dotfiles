-- Exact pins (npm view, 2026-10).
local PIN = {
  context7 = "@upstash/context7-mcp@4.4.1",
  mcp_remote = "mcp-remote@0.14.3",
}

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
          -- Every tool that writes, reads files or reaches the network asks first.
          -- `protect` keeps them asking in Auto mode too (only YOLO ignores it).
          tools = {
            -- Shell tool disabled; re-enable by removing `enabled = false` (still gated).
            ["run_command"] = {
              enabled = false,
              opts = {
                require_approval_before = true,
                require_cmd_approval = true,
                protect = true,
                safe_commands = {},
              },
            },
            ["delete_file"] = {
              opts = { require_approval_before = true, require_cmd_approval = true, protect = true },
            },
            ["create_file"] = {
              opts = { require_approval_before = true, protect = true },
            },
            ["insert_edit_into_file"] = {
              opts = { require_approval_before = { buffer = true, file = true }, protect = true },
            },
            ["read_file"] = {
              opts = { require_approval_before = true, protect = true },
            },
            ["grep_search"] = {
              opts = { require_approval_before = true, protect = true },
            },
            ["fetch_webpage"] = { opts = { require_approval_before = true, protect = true } },
            ["web_search"] = { opts = { require_approval_before = true, protect = true } },
          },
        },
        inline = {
          adapter = {
            name = "ollama",
            model = "qwen3.6:35b-a3b",
          },
        },
      },
      -- MCP (stdio only). github omitted: remote-HTTP-only with a huge tool
      -- surface that overwhelms a local model.
      mcp = {
        servers = {
          -- stdio-native, tiny tool surface
          context7 = {
            cmd = { "npx", "-y", PIN.context7 },
          },
          -- remote HTTP servers bridged to stdio via mcp-remote
          grep_app = {
            cmd = { "npx", "-y", PIN.mcp_remote, "https://mcp.grep.app" },
          },
          websearch = {
            cmd = { "npx", "-y", PIN.mcp_remote, "https://mcp.exa.ai/mcp" },
          },
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
