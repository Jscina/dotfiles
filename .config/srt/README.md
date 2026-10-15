# OpenCode Sandbox Runtime (srt) Setup

## Purpose

This directory implements the **Anthropic sandbox-runtime (srt)** baseline for OpenCode, applying constraints and best practices from ConnectPlus.wiki/Development/Claude-Code: sandbox and settings baseline.

OpenCode agents run confined inside the sandbox with these OS-enforced guarantees:
- Cannot read credentials (~/.azure, SSH keys, shell history)
- Cannot edit their own config, launcher, or sandbox settings
- Cannot write outside designated project areas
- Cannot reach hosts outside an allowlist

**Residual (by design):** Sandboxed tools run inside the srt process and inherit its restrictions. However, nvim's CodeCompanion built-in tools (run_command, read_file, grep_search, fetch_webpage, web_search) run **outside** the sandbox in nvim's process—gated by approval prompts, not by srt's OS-enforced rules. Allowed MCP servers can send data to their permitted hosts. ADO MCP runs sandboxed but reaches dev.azure.com with a PAT. No tool can "escape" srt once spawned, but threats model assumes the process itself is trusted.

## Two Layers of Defense

### Layer 1: OpenCode Permission Rules (`opencode.json`)
Rules in `~/.config/opencode/opencode.json` run at **prompt time** (best-effort):
- `permission.read`: Deny certain paths (~/.azure, ~/.ssh, ~/.gradle/daemon, etc.)
- `permission.edit`: Deny same paths plus config/launcher files
- `permission.bash`: Deny rm -rf, sudo, git push, npm publish, az tool usage without `ask`

**Mechanism:** OpenCode interpreter enforces these before the agent makes tool calls.

### Layer 2: macOS Seatbelt (via srt)
Rules in `opencode.json` (this directory) are **OS-enforced**:
- `network.allowedDomains`: Only these domains are reachable
- `filesystem.denyRead`: System-level read restrictions
- `filesystem.allowWrite`: Only these paths can be written
- `filesystem.denyWrite`: Explicitly protected paths

**Mechanism:** srt wraps the OpenCode process with macOS Seatbelt, inherited by all children (bash, npx, gradle, etc.).

## How It's Launched

```
User calls <leader>oa in nvim
  ↓
nvim plugin (opencode.lua) calls ~/dotfiles/bin/opencode-sandboxed
  ↓
Launcher checks for unsandboxed opencode processes (fail-closed if any running)
  ↓
Launcher resolves srt (newest nvm >= 24 with @anthropic-ai/sandbox-runtime)
  ↓
Launcher execs: srt --settings ~/dotfiles/.config/srt/opencode.json -- opencode
  ↓
OpenCode runs under Seatbelt + permission rules with scrubbed environment
```

**Nested calls:** The `opencode()` function in `.zshrc` (lines 125–147) detects `OPENCODE_SANDBOXED=1 && SANDBOX_RUNTIME=1` markers and verifies confinement with open() probes before calling opencode directly (no re-launch). This is convenience for nested shells inside the sandbox.

## Install

1. **Global srt:** Install the sandbox runtime globally under nvm (Node >= 24 required for NODE_USE_ENV_PROXY):
   ```bash
   nvm install 24
   npm install -g @anthropic-ai/sandbox-runtime
   ```

2. **Launcher:** Already present as `~/dotfiles/bin/opencode-sandboxed` (regular file, not a symlink). A symlink at `~/bin/opencode-sandboxed` may point to it for convenience. The launcher is protected from edits inside the sandbox.

3. **Settings file:** `~/dotfiles/.config/srt/opencode.json` is locked from edits inside the sandbox.

## Network Allowlist

The following domains are reachable from inside the sandbox (from `.config/srt/opencode.json`):

- **GitHub:** `github.com`, `api.github.com`, `*.githubusercontent.com`, `api.githubcopilot.com`
- **Anthropic:** `api.anthropic.com`, `console.anthropic.com`, `platform.claude.com`, `models.dev`, `models.opencode.ai`, `opencode.ai`
- **npm:** `registry.npmjs.org`
- **MCP servers:** `mcp.exa.ai`, `mcp.context7.com`, `mcp.grep.app`
- **Azure:** `dev.azure.com`, `*.dev.azure.com`, `*.visualstudio.com`, `login.microsoftonline.com`, `management.azure.com`
- **Build tools:** `services.gradle.org`, `downloads.gradle.org`, `plugins.gradle.org`, `plugins-artifacts.gradle.org`, `repo.maven.apache.org`, `repo1.maven.org`, `jitpack.io`, `repo.spring.io`, `jaspersoft.jfrog.io`, `sonarcloud.io`, `maven-repo.eastus.cloudapp.azure.com`, `www.datanucleus.org`
- **Internal:** `10.161.92.100` (internal Artifactory; VPN required to verify)
- **Localhost:** `127.0.0.1`, `::1` (loopback for local MCP servers, Ollama, debuggers)

### Adding a Domain

If a tool or build fails with **proxy/connection error**:

1. Identify the blocked hostname: check error messages or run `curl https://example.com` inside opencode (will show proxy denial)
2. Edit `~/dotfiles/.config/srt/opencode.json` **from outside the sandbox** (e.g., in nvim when opencode is not running, or from a terminal with no `OPENCODE_SANDBOXED=1`):
   ```json
   "network": {
     "allowedDomains": [
       // ... existing domains ...
       "example.com"
     ]
   }
   ```
3. Restart opencode (kill any running instance, then call `opencode-sandboxed` again)

## Filesystem Policy

### Read-Denied Paths (Layer 2 + Layer 1)
Cannot read:
- `~/.azure` &mdash; Azure credentials
- `~/.ssh` &mdash; SSH keys
- `~/.gradle/daemon` &mdash; Gradle daemon state
- `~/.zsh_history`, `~/.bash_history` &mdash; Shell history
- `~/.zsh_sessions` &mdash; Session data
- `~/.secrets` &mdash; Secrets file
- `~/.config/gh/hosts.yml` &mdash; GitHub authentication

### Write-Allowed Paths
Can write to:
- `~/repos` &mdash; Project clones
- `~/dotfiles` &mdash; Dotfiles repo
- `~/.gradle` &mdash; Gradle build cache (except daemon)
- `/tmp/claude` &mdash; Temporary build files
- `~/.local/state/opencode` &mdash; Service state (register with nvim plugin)
- `~/.local/share/opencode` &mdash; Session artifacts
- `~/.cache/opencode` &mdash; Cache

**Note:** `~/.npm` and `~/.bun` are not writable inside the sandbox; caches are redirected to `/tmp/claude/npm-cache` and `/tmp/claude/bun-cache` (see launcher).

### Write-Protected Paths (Locked by srt)
Cannot edit:
- `~/.config/opencode/opencode.json`, `opencode.jsonc` &mdash; Config
- `~/.config/opencode/agents`, `plugins`, `commands`, `skills`, `tools` &mdash; Agent/plugin/command dirs
- `~/dotfiles/.config/srt/*` &mdash; Sandbox settings (both absolute and home-relative paths denied)
- `~/dotfiles/bin/opencode-sandboxed` &mdash; Launcher
- `~/dotfiles/.zshrc` &mdash; Shell config
- `~/dotfiles/.config/nvim/**` &mdash; All nvim plugin files
- `~/dotfiles/.ssh`, `~/dotfiles/.secrets` &mdash; Credentials
- `~/repos/**/.git/hooks`, `~/repos/**/.git/config`, `~/repos/**/.git/modules/**/hooks|config` &mdash; Git internals (absolute-anchored denies per repo)
- `~/repos/**/.gitmodules`, `~/repos/**/.vscode`, `~/repos/**/.idea` &mdash; VCS/IDE metadata
- `~/repos/**/opencode.json`, `opencode.jsonc`, `.mcp.json` &mdash; Config in projects
- `~/repos/**/.opencode/agents|plugins|commands|skills|tools` &mdash; Agent definitions

**Consequence:** Edit these files **outside** the sandbox. Use nvim (not from inside opencode), your shell, or any other editor. The sandbox cannot modify its own chain of launch.

### Git Operations Inside the Sandbox

Most git operations work inside the sandbox (`add`, `commit`, `branch`, `checkout -b`, `switch -c`, `stash`, `merge`, `rebase`, `tag`, `fetch`, `push`, `worktree add -b`, `gc`). **These fail:**
- `git init` or `git clone` into `~/repos` or `~/dotfiles` (seatbelt blocks `.git/config` write)
- `git submodule add/update` (tries to write `.git/config` and `.gitmodules`)
- `git config <key> <value>` (modifies `.git/config`)
- `git remote add/set-url` (writes `.git/config`)
- `git branch --set-upstream-to` (writes `.git/config`)
- `git push -u` (upstream setup tries to write `.git/config`)
- `git push` (denied by OpenCode permission.bash rules, though srt itself allows the `.git/config` write needed for tracking)
- Plain `git pull` without an explicit upstream ref (fails only if upstream is not recorded in `.git/config`; read access is allowed)

## Zscaler Proxy (TLS Inspection)

The sandbox honors Zscaler's MITM TLS certificate chain:
- Launcher exports `NODE_EXTRA_CA_CERTS=$HOME/.certs/ZscalerRootCA.pem` (line 147 of launcher)
- This must exist; if missing, HTTPS traffic fails with certificate errors
- NODE_EXTRA_CA_CERTS only affects Node.js and bun; the Java/JVM uses its own truststore (srt does not modify it)
- srt tunnels TLS without terminating it; the JVM and gradle work inside the sandbox with the host's existing trust setup

## Gradle and JVM Configuration

The launcher configures:
- **Temp dir:** `/tmp/claude` (inside sandbox write-allowed area; shared with opencode)
- **JVM tmpdir:** `-Djava.io.tmpdir=/tmp/claude` (Java temp files stay in allowed area)
- **Gradle daemon registry:** `-Dorg.gradle.daemon.registry.base=/tmp/claude/gradle-daemon` (avoids `~/.gradle/daemon` read restriction, which is denied)
- **Other JVM args:** `-Djava.net.preferIPv4Stack=true` (line 173 of launcher)
- **Proxy:** srt's embedded javaagent is prepended automatically; do not override

These settings allow `./gradlew build` to run inside the sandbox. Gradle daemon state is stored under `/tmp/claude/gradle-daemon` instead of the inaccessible `~/.gradle/daemon`.

## Stale/Unsandboxed Server

If opencode starts refusing to launch with:
```
opencode-sandboxed: refusing to start: unsandboxed opencode process(es) running
```

An old opencode instance is still running outside the sandbox. To find and stop it:

```bash
# List all opencode processes
pgrep -fl opencode

# Kill a specific one (replace <PID>)
kill <PID>

# Or force-kill all (last resort)
pkill -9 opencode
```

The launcher checks:
1. All processes named `opencode` (from `ps`)
2. The PID recorded in `~/.local/state/opencode/service.json`

If any lack `OPENCODE_SANDBOXED=1` in their environment, the launcher refuses to start (fail-closed).

## Stale/Unsandboxed Server Guard

The launcher guard requires **both** `OPENCODE_SANDBOXED=1` **and** `SANDBOX_RUNTIME=1` environment markers, **and** an srt process ancestor (check: `ps eww $$` shows `/srt --settings`). The markers alone are spoofable; the launcher verifies with real open() attempts on srt-denied files to confirm confinement. Nested calls from inside the sandbox are allowed (both markers already set and srt ancestry confirmed).

## nvim and CodeCompanion Run Outside the Sandbox

The nvim editor process itself and its CodeCompanion MCP client run **outside** srt with nvim's full environment privileges. Only the **MCP servers** (context7, grep_app, websearch, ado) run sandboxed. Built-in CodeCompanion tools run in nvim's unsandboxed process:

| Tool | Sandbox | Approval | Protection |
|---|---|---|---|
| run_command | ❌ | ✓ (can be disabled) | ✓ (deny list + approval) |
| create_file | ❌ | ✓ (must approve) | ✓ |
| insert_edit_into_file | ❌ | ✓ (must approve per file) | ✓ |
| read_file | ❌ | ✓ (must approve) | ✓ |
| grep_search | ❌ | ✓ (must approve) | ✓ |
| delete_file | ❌ | ✓ (must approve) | ✓ |
| fetch_webpage | ❌ | ✓ (must approve) | ✓ |
| web_search | ❌ | ✓ (must approve) | ✓ |
| file_search | ❌ | ❌ | ❌ |
| get_changed_files | ❌ | ❌ | ❌ |
| get_diagnostics | ❌ | ❌ | ❌ |
| ask_questions | ❌ | ❌ | ❌ |

The run_command tool is already disabled (`enabled = false`) in codecompanion.lua (line 200). Auto mode respects `protect=true` for all tools. YOLO mode and "Always accept" bypass approvals.

## Editing Protected Files

The sandbox denies writes to its own chain of launch: launcher, settings, nvim config, .zshrc, opencode config, git internals, and agent/command dirs. You **cannot edit these files from inside opencode** (seatbelt denies the write).

**How to edit them:**
1. Launch nvim from a fresh shell (or quit the running opencode TUI)
2. Edit the file normally in nvim (outside the sandbox)
3. Save and close nvim
4. Restart opencode: quit the existing TUI, then call `opencode-sandboxed` or press `<leader>oa` again

**Affected files:**
- `~/.config/opencode/opencode.json`, `opencode.jsonc`
- `~/dotfiles/.config/srt/opencode.json`, `mcp.json`, `mcp-ado.json`
- `~/dotfiles/.config/nvim/lua/plugins/**`
- `~/dotfiles/bin/opencode-sandboxed`
- `~/dotfiles/.zshrc`
- Project `.git/config`, `.git/hooks`, `.git/modules`

## First Run After Restart

After upgrading opencode, srt, or changing sandbox/launcher settings:

1. **Quit the existing unsandboxed opencode:** Kill any `opencode serve` or stray `opencode` TUI process:
   ```bash
   pgrep -fl opencode  # List all processes
   kill <PID>          # Kill any unsandboxed ones
   ```

2. **Reload shell config:** In a fresh terminal (outside nvim):
   ```bash
   source ~/.zshrc
   ```

3. **Restart nvim:** Close and reopen nvim to reload the opencode.lua plugin.

4. **Launch via the launcher:** Press `<leader>oa` (the keybind calls `opencode.lua`'s `M.resolve()`, which uses the launcher).

5. **Verify the sandbox:**
   ```bash
   # Inside opencode TUI (ask an agent to run):
   ps eww $$
   ```
   **Expected:** Output includes `OPENCODE_SANDBOXED=1` and `SANDBOX_RUNTIME=1`.

6. **Run verification probes** (see checklist section below).

7. **Test git operations:**
   ```bash
   cd ~/repos/some-project
   git log --oneline -3
   git status
   git add some-file.txt
   git commit -m "test commit"
   ```
   **Expected:** All succeed. Note that `git clone`, `git init`, and upstream setup fail (see Git Operations section).

8. **Check MCP servers:** Ask CodeCompanion to list available tools. You should see context7, grep_app, websearch, and possibly ado (if ADO_ORG/ADO_MCP_AUTH_TOKEN are set).

9. **nvim integration (`opencode-sandboxed --nvim`):** Starts `opencode serve` on a random loopback port with a random password, writes `~/.local/state/opencode/service.json`, and attaches the TUI (`--server`); both run in one srt. On exit the server is killed and the registration removed. Verify: press `<leader>ot`, then `<leader>oa`; after quitting, no `opencode` process and no `service.json` remain. Requires the shared service disabled: `opencode service stop && opencode service set disabled true` (a shared service keeps the proxy/profile of the srt that first started it and gets `ConnectionRefused` once that exits).

### Known Issues and Workarounds

- **One nvim registration at a time:** `--nvim` writes a single `service.json`; a second concurrent nvim launch overwrites it, so the first nvim's plugin keymaps then target the second server. Run one sandboxed nvim session at a time.

- **ADO MCP 407 proxy handling (FIXED):** Commit a77fbe2 pins `@azure-devops/mcp@2.10.0` and injects `NODE_OPTIONS=--require=/Users/jscina/dotfiles/.config/srt/mcp-ado-preload.cjs` (for proxy credential injection). **Verified:** `core_list_projects` returned 2 projects inside the sandbox. The first-run checklist includes an ADO check (MCP list verification step).

- **Plain-IP Artifactory (10.161.92.100):** Listed in allowlist but never verified (VPN required). Re-test with VPN up if you use it.

## Known Gaps and Open Decisions

**Known gaps (by design):**
- `auth.json`, `mcp-auth.json` under `~/.local/share/opencode` are readable inside sandbox (needed for OpenCode to function); do not store secrets there.
- `service.json` is writable (by design). The nvim plugin verifies sandboxing (checks markers, ancestor srt, loopback host, listening port); a forged entry is rejected.
- `.git/hooks` and `.git/config` are always protected by srt's Seatbelt, even if accidentally included in `allowWrite`.
- Bash patterns in permission.bash (Layer 1, not srt) use best-effort matching. Agents can evade with variable substitution (e.g., `cat $HOME/.azure/config`), but srt's read-deny catches the actual file access.
- `~/.gradle` is writable as an escape route: agent-written code run later unsandboxed could access build artifacts. Same risk accepted for `~/.gradle/gradle.properties` (readable and writable; only sets `org.gradle.java.home`; denying breaks builds).
- `GITHUB_MCP_TOKEN`, `ADO_ORG`, `ADO_MCP_AUTH_TOKEN` are in the keep-list and visible to agent bash via `env`; env scrub is a denylist (URL-embedded credentials pass through).
- `~/dotfiles` is writable, which includes scripts that run **outside** the sandbox (yabairc, skhdrc, .tmux.conf, ghostty/kanata configs, sketchybar plugins/items). SketchyBar re-runs scripts without user action—**unresolved decision:** deny writes to these paths, or accept the risk.
- `.claude/{skills,commands,agents}` and `.agents/skills` under projects are writable (not covered by `.opencode` denies).
- `.opencode/plans` and `.opencode/memory` are writable by design.
- srt's `.git` Seatbelt protections cover only the launch directory; absolute denies cover `~/repos/**` and `~/dotfiles/**`. Gap: a `.git` pointer file (worktrees/submodules) or bare repo can point to config outside the pattern.
- `opencode`'s permission layer's `bin/` protection in the dotfiles worktree relies on srt only (no Layer 1 rule).

**Open decisions:**
1. **Dotfiles scripts deny-or-accept:** sketchybar, yabai, skhd, tmux configs—deny writes, or accept the risk of agent-modified behavior.
2. **Azure MCP authentication inside sandbox:** `~/.azure` is read-denied, `AZURE_*` credential vars are unset. Options: run read-only `@azure/mcp@latest` outside srt as a localhost HTTP remote MCP (caveat: with localhost open the agent can call it directly with curl and skip permission prompts), use a Reader-only service principal with a separate readable config dir, or disable the entry (`"enabled": false`).
3. **opencode 2.x upgrade risk:** See Known Issues section.

---

## Verification Checklist

Copy-paste these commands to verify the sandbox is working:

### 1. Launcher Available
```bash
opencode-sandboxed --version
```
**Expected:** OpenCode version printed; exits 0.

### 2. Credentials Denied
Inside opencode (e.g., ask an agent to run):
```bash
cat ~/.azure/config
```
**Expected:** Denied by srt Seatbelt (permission error, not "file not found").

```bash
cat ~/.zsh_history
```
**Expected:** Denied.

### 3. Network Policy
```bash
curl https://example.com
```
**Expected:** HTTP 403 (blocked by proxy allowlist).

```bash
curl -I https://github.com
```
**Expected:** HTTP 200 or 3xx (reachable).

### 4. Filesystem Write Denial
```bash
touch ~/Desktop/test.txt
```
**Expected:** Denied by srt Seatbelt.

### 5. Filesystem Write Allowed
```bash
touch ~/repos/test.txt
```
**Expected:** File created (if ~/repos exists).

### 6. Config Files Protected
```bash
echo "malicious" >> ~/.config/opencode/opencode.json
```
**Expected:** Denied by srt Seatbelt.

### 7. Protected Config Files Cannot Be Written
```bash
echo "malicious" >> /Users/jscina/dotfiles/.config/srt/opencode.json
```
**Expected:** Denied by srt Seatbelt.

```bash
echo "malicious" >> /Users/jscina/dotfiles/.config/nvim/lua/plugins/opencode.lua
```
**Expected:** Denied by srt Seatbelt.

```bash
rm -f ~/bin/opencode-sandboxed
```
**Expected:** Denied by srt Seatbelt (file write denied on the absolute dotfiles path).

### 8. Ancestor SRT Process Verification
Inside opencode:
```bash
ps eww $$ | grep -i srt
```
**Expected:** The output should show the environment and you should be able to trace an ancestor process running srt. (May not show srt binary name if sandbox-exec has already execs'd into a child.)

Or ask an agent to run this and inspect the output for `OPENCODE_SANDBOXED=1`.

### 9. Service Registration (opencode 2.x only)
**Skip this test if using opencode 1.19.0.** With opencode >= 2.x:
1. Kill any running opencode TUI
2. From nvim, press `<leader>oa`
3. In another terminal (outside sandbox):
   ```bash
   cat ~/.local/state/opencode/service.json
   ```
   **Expected:** JSON with `pid`, `host`, `port`, and `password` fields. Host should be `127.0.0.1` or `::1`.
4. Verify nvim's status bar shows "Opencode" (connected)

### 10. Process Verification
Inside opencode:
```bash
ps eww $$
```
**Expected:** Output includes `OPENCODE_SANDBOXED=1`.

### 11. Gradle Build
Clone a Java project into `~/repos/myproject` and run:
```bash
cd ~/repos/myproject
./gradlew build
```
**Expected:** Build runs, daemon temp stored in `/tmp/claude/gradle-daemon` (check `~/.gradle/daemon` is not touched).

### 12. Git Operations
```bash
cd ~/repos/an-existing-project
git log --oneline -3
git status
git add somefile.txt
git commit -m "test"
git fetch
```
**Expected:** All succeed.

```bash
git clone https://github.com/user/repo.git test-clone
```
**Expected:** Fails with permission error on `.git/config` write (expected behavior).

```bash
git branch --set-upstream-to origin/main main
```
**Expected:** Fails with permission error on `.git/config` write (expected behavior).

### 13. Ollama Local
```bash
curl http://localhost:11434/api/tags
```
**Expected:** JSON response with available models (if running on localhost:11434).

---

**Last updated:** Oct 2026  
**Sandbox baseline:** ConnectPlus team wiki, Development/Claude-Code: sandbox and settings baseline  
**Runtime:** srt (sandbox-runtime, @anthropic-ai/sandbox-runtime) with macOS Seatbelt  
**OpenCode:** https://opencode.ai/ (1.19.0 current Homebrew; 2.x supports service.json)  
**srt:** https://github.com/anthropic-experimental/sandbox-runtime
