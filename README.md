# dotfiles

Personal dotfiles for a macOS development environment. Manages shell, terminal, editor, window management, and status bar configs.

## Overview

| Component | Tool | Config Path |
|---|---|---|
| Shell | Zsh + Oh My Zsh | `.zshrc` |
| Terminal Multiplexer | tmux | `.tmux.conf` |
| Terminal Emulator | Ghostty | `.config/ghostty/config` |
| Editor | Neovim (LazyVim) | `.config/nvim/` |
| Window Manager | yabai + skhd | `.config/skhd/skhdrc` |
| Status Bar | SketchyBar | `.config/sketchybar/` |
| AI Coding | OpenCode | `.config/opencode/` |
| GitHub CLI | gh | `.config/gh/` |
| Azure Tooling | azp | `.config/azp/` |
| SSH | OpenSSH | `.ssh/config` |

## Shell (`.zshrc`)

Zsh with [Oh My Zsh](https://ohmyz.sh/) using the `rkj-repos` theme.

**Plugins:** `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `tmux`

**Key behavior:**
- tmux auto-starts on shell launch (session name: `main`)
- Hyphen-insensitive completion enabled
- Secrets sourced from `~/.secrets` (gitignored)

**Runtime managers:**
- [nvm](https://github.com/nvm-sh/nvm) for Node.js
- [pyenv](https://github.com/pyenv/pyenv) for Python
- [Cargo](https://doc.rust-lang.org/cargo/) for Rust
- [Bun](https://bun.sh/) runtime
- [pipx](https://pypa.github.io/pipx/) for isolated Python CLIs

**Aliases:**
- `lzg` &rarr; `lazygit`
- `lzd` &rarr; `lazydocker`

**Other:**
- [zoxide](https://github.com/ajeetdsouza/zoxide) replaces `cd`
- Microsoft telemetry disabled (`FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT`, `AZURE_DEV_COLLECT_TELEMETRY`)
- Zscaler root CA configured for Node.js (`NODE_EXTRA_CA_CERTS`)
- Java 21 and .NET via Homebrew

## tmux (`.tmux.conf`)

**Prefix:** `Ctrl-a` (rebound from default `Ctrl-b`)

**Keybindings:**
| Key | Action |
|---|---|
| `\|` | Split horizontal |
| `-` | Split vertical |
| `r` | Reload config |
| `Ctrl-h/j/k/l` | Navigate panes (vim-aware) |

**Features:**
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) integration for seamless pane/split switching
- Mouse mode enabled
- Window numbering starts at 1
- True color support (`xterm-256color` + RGB)
- Status bar at top

**Plugins** (via [TPM](https://github.com/tmux-plugins/tpm)):
- `tmux-pain-control` &mdash; sensible pane bindings
- `tmux-sensible` &mdash; reasonable defaults
- `tokyo-night-tmux` &mdash; theme (transparent status bar background)

## Ghostty (`.config/ghostty/config`)

[Ghostty](https://ghostty.org/) terminal emulator.

- **Font:** JetBrainsMono Nerd Font, size 16
- **Background:** Pure black (`#000000`) at 40% opacity with blur
- **Cursor:** Blinking bar
- **Window:** No decorations (borderless), balanced padding
- **Colors:** Tokyo Night foreground (`#c0caf5`)

## Neovim (`.config/nvim/`)

[LazyVim](https://www.lazyvim.org/) distribution (managed as a git submodule).

**Enabled LazyVim extras:**
- **AI:** Copilot, Copilot Chat
- **Coding:** blink, nvim-cmp
- **Debugging:** DAP core
- **Editor:** fzf, leap, refactoring, snacks explorer/picker
- **Formatting:** Black (Python), Prettier (JS/TS)
- **Languages:** Docker, Java, JSON, Markdown, Prisma, Python, Rust, SQL, Tailwind, TypeScript
- **LSP:** neoconf, none-ls
- **Testing:** neotest core
- **Utilities:** Octo (GitHub PRs in Neovim)

**Custom plugins** (22 total in `lua/plugins/`):

| Plugin | Purpose |
|---|---|
| `blink` | Completion engine config |
| `copilot` | GitHub Copilot |
| `core` | Core overrides |
| `dap` | Debug Adapter Protocol |
| `disabled` | Explicitly disabled plugins |
| `ecolog` | Environment variable support |
| `go-up` | Navigation helper |
| `indent_blankline` | Indentation guides |
| `java` | Java/JDTLS config |
| `lazydocker` | Docker TUI integration |
| `lazygit` | Git TUI integration |
| `lsp` | LSP configuration |
| `neotest` | Test runner |
| `neotree` | File explorer |
| `nvim_ufo` | Code folding |
| `opencode` | OpenCode AI integration |
| `tailwind_tools` | Tailwind CSS utilities |
| `tmux` | tmux-navigator integration |
| `transparent` | Transparent background |
| `treesitter-context` | Sticky function headers |
| `undotree` | Undo history visualization |
| `venv-selector` | Python virtualenv picker |

**Lua formatting:** StyLua (2-space indent, 120 column width)

## Window Management (`.config/skhd/skhdrc`)

[skhd](https://github.com/koekeishiya/skhd) hotkey daemon for [yabai](https://github.com/koekeishiya/yabai) tiling window manager.

**Focus windows:**
| Key | Action |
|---|---|
| `Cmd-h/j/k/l` | Focus west/south/north/east |
| `Cmd+Shift-h/j/k/l` | Warp (move) window |
| `Cmd+Shift-[1-9]` | Send window to space |
| `Cmd-d` | Toggle zoom parent |
| `Cmd-f` | Toggle fullscreen zoom |
| `Cmd+Shift-v` | Toggle float |
| `Cmd+Shift-n/p` | Focus next/prev in stack |

**App launchers:**
| Key | App |
|---|---|
| `Cmd-s` | System Settings |
| `Cmd-b` | Arc Browser |
| `Cmd-i` | Alacritty |

**Service:** `Cmd+Alt+Ctrl-r` restarts yabai.

## SketchyBar (`.config/sketchybar/`)

[SketchyBar](https://github.com/FelixKratz/SketchyBar) custom macOS menu bar replacement.

**Theme:** Tokyo Night (dark variant)

**Layout:**
- **Left:** Spaces, Front App
- **Center:** Spotify (notch area)
- **Right:** Clock, Calendar, Battery, Volume, CPU

**Bar style:** Floating (5px offset + margin), 30px tall, rounded corners (15px radius), blur background, transparent base color.

**Font:** JetBrainsMono Nerd Font

**Items** (`items/`): `spaces`, `front_app`, `spotify`, `clock`, `calendar`, `battery`, `volume`, `cpu`

**Plugins** (`plugins/`): `space`, `front_app`, `spotify`, `clock`, `calendar`, `power`, `sound`, `cpu`

## OpenCode (`.config/opencode/`)

[OpenCode](https://opencode.ai/) AI coding assistant configuration.

**Plugins:** `opencode-gemini-auth`, `@ex-machina/opencode-anthropic-auth`, `oh-my-openagent`

**MCP Servers:**
- `github` &mdash; GitHub Copilot MCP (remote)
- `azure` &mdash; Azure MCP (local, via npx)
- `ado` &mdash; Azure DevOps MCP (local, via npx)
- `copeland-code-search` &mdash; Code search (remote)
- `lazytail` &mdash; Log tailing (local)

**Local model:** Ollama with `qwen3.5` (reasoning + tool calling)

**TUI keybinds:** Newline via `Shift+Return`, `Ctrl+Return`, `Alt+Return`, or `Ctrl+J`

## GitHub CLI (`.config/gh/`)

- **Protocol:** HTTPS
- **User:** [Jscina](https://github.com/Jscina)
- **Alias:** `gh co` &rarr; `gh pr checkout`

## SSH (`.ssh/config`)

- Includes Colima SSH config (for container runtime)
- Auto-adds keys to agent on all hosts

## Gitignored / Secrets

The following are tracked locally but excluded from the repo:

- `.secrets` &mdash; Environment variables (API keys, tokens)
- `.ssh/` &mdash; SSH keys and known hosts
- `.config/azp/` &mdash; Azure bastion cache and tunnel options
- `.config/gh-copilot/` &mdash; Copilot auth config

## Dependencies

This setup assumes the following are installed:

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- [tmux](https://github.com/tmux-plugins/tpm) + TPM
- [Ghostty](https://ghostty.org/)
- [Neovim](https://neovim.io/) (0.10+)
- [yabai](https://github.com/koekeishiya/yabai) + [skhd](https://github.com/koekeishiya/skhd)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [fzf](https://github.com/junegunn/fzf)
- [nvm](https://github.com/nvm-sh/nvm), [pyenv](https://github.com/pyenv/pyenv), [Rust/Cargo](https://rustup.rs/), [Bun](https://bun.sh/)
- [lazygit](https://github.com/jesseduffield/lazygit), [lazydocker](https://github.com/jesseduffield/lazydocker)
