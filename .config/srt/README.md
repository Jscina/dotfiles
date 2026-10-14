# OpenCode Sandbox Runtime (srt) Setup

## Purpose

This directory implements the **Anthropic sandbox-runtime (srt)** baseline for OpenCode, applying the constraints and best practices from [ConnectPlus.wiki Claude Code sandbox-and-settings-baseline](https://connectedagents.wiki/Claude/Development/Claude-Code:-sandbox-and-settings-baseline).

OpenCode agents run confined inside the sandbox with these guarantees:
- Cannot read credentials (~/.azure, SSH keys, shell history)
- Cannot edit their own config, launcher, or sandbox settings
- Cannot write outside designated project areas
- Cannot reach hosts outside an allowlist
- Cannot bypass the sandbox from inside

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
Launcher resolves srt (newest nvm node)
  ↓
Launcher detects OPENCODE_SANDBOXED=1 and SANDBOX_RUNTIME=1
  ↓
Launcher execs: srt --settings ~/.config/srt/opencode.json -- opencode
  ↓
OpenCode runs under Seatbelt + permission rules
```

**Zsh wrapper**: The `opencode()` function in `.zshrc` (lines 125–134) is **convenience only**. It allows typing `opencode` from inside nvim or a nested sandbox without re-typing the full path. It is **not** a security guarantee; the nvim plugin always uses the launcher directly.

## Install

1. **Global srt:** Install the sandbox runtime globally under nvm:
   ```bash
   npm install -g @anthropic-ai/sandbox-runtime
   ```

2. **Launcher symlink:** Already present as `~/dotfiles/bin/opencode-sandboxed`. It is executable and protected from edits inside the sandbox.

3. **Settings file:** `~/.config/srt/opencode.json` is locked from edits inside the sandbox.

## Network Allowlist

The following domains are reachable from inside the sandbox:

- **GitHub:** `github.com`, `api.github.com`, `*.githubusercontent.com`, `api.githubcopilot.com`
- **Anthropic:** `api.anthropic.com`, `console.anthropic.com`, `claude.ai`, `models.dev`
- **OpenCode:** `opencode.ai`
- **npm:** `registry.npmjs.org`
- **MCP servers:** `mcp.exa.ai`, `mcp.context7.com`, `mcp.grep.app`
- **Azure:** `dev.azure.com`, `*.dev.azure.com`, `*.visualstudio.com`, `login.microsoftonline.com`, `management.azure.com`
- **Build tools:** `services.gradle.org`, `downloads.gradle.org`, `plugins.gradle.org`, `plugins-artifacts.gradle.org`, `repo.maven.apache.org`, `repo1.maven.org`, `jitpack.io`, `repo.spring.io`, `jaspersoft.jfrog.io`, `sonarcloud.io`, `maven-repo.eastus.cloudapp.azure.com`, `www.datanucleus.org`
- **Internal:** `10.161.92.100` (internal Artifactory; VPN required to verify)
- **Localhost:** `127.0.0.1::1` (MCP servers, Ollama)

### Adding a Domain

If a tool or build fails with **proxy/connection error**:

1. Identify the blocked hostname: check error messages or run `curl https://example.com` inside opencode (will show proxy denial)
2. Edit `~/.config/srt/opencode.json` **from outside the sandbox** (e.g., in nvim when opencode is not running, or from a terminal with no `OPENCODE_SANDBOXED=1`):
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
- `~/.npm`, `~/.bun` &mdash; Package manager caches

### Write-Protected Paths (Locked by srt)
Cannot edit:
- `~/.config/opencode/opencode.json` &mdash; Config
- `~/.config/opencode/agents`, `skills`, `commands` &mdash; Agent definitions
- `~/.config/srt/*` &mdash; Sandbox settings
- `~/dotfiles/bin/opencode-sandboxed` &mdash; Launcher
- `~/.zshrc` &mdash; Shell config
- `~/.config/nvim/lua/plugins/opencode.lua` &mdash; nvim plugin
- `**/.mcp.json`, `**/opencode.json` &mdash; Config files in any project

**Consequence:** Edit these files **outside** the sandbox. Use nvim (not from inside opencode), your shell, or any other editor. The sandbox cannot modify its own chain of launch.

## Zscaler Proxy (TLS Inspection)

The sandbox honors Zscaler's MITM TLS certificate chain:
- Launcher exports `NODE_EXTRA_CA_CERTS=$HOME/.certs/ZscalerRootCA.pem` (line 79 of launcher)
- This must exist; if missing, HTTPS traffic fails with certificate errors
- Gradle respects the same cert via `JAVA_TOOL_OPTIONS` (see below)

## Gradle and JVM Configuration

The launcher configures:
- **Temp dir:** `/tmp/claude/gradle-daemon` (inside sandbox write-allowed area)
- **Gradle daemon registry:** `/tmp/claude/gradle-daemon` (avoids `~/.gradle/daemon` read restriction)
- **JVM args:** `-Djava.net.preferIPv4Stack=true -Dorg.gradle.daemon.registry.base=/tmp/claude/gradle-daemon` (line 87)
- **Proxy:** srt's javaagent is prepended automatically; do not override

These settings allow `./gradlew build` to run inside the sandbox, with daemon temp in an allowed location.

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

## No Escape Hatch

By design, there is **no override variable** or fallback to unsandboxed opencode. If srt, opencode, or settings are missing, the launcher exits non-zero. The nvim plugin and zsh wrapper both force sandbox use; the `opencode` command in the shell cannot bypass this without modifying files (which is denied inside the sandbox).

## Known Gaps & To-Confirm on First Run

### Confirmed Working
- Network: GitHub, Maven, Anthropic APIs, MCP servers reachable ✓
- Azure credentials (~/.azure) are correctly denied ✓
- Gradle builds run with daemon temp in `/tmp/claude` ✓
- Shell history (~/.zsh_history) denied ✓
- Ollama reachable on localhost:11434 ✓

### Not Yet Verified
- **Plain-IP Artifactory (10.161.92.100):** Listed in allowlist but untested (VPN down when builders tested). Re-test with VPN up.
- **Service registration:** nvim plugin detects `~/.local/state/opencode/service.json`. Mechanism inside sandbox unclear — the launcher sets `allowWrite` for that path. **To confirm on first run:** Kill opencode, start fresh with `<leader>oa`, confirm `service.json` is written, then confirm nvim reconnects.
- **opencode.nvim stop/toggle:** Current version only has `server.start()`. No stop or toggle. **Implication:** Must kill opencode manually; can't suspend from nvim.

### Security Gaps (By Design)
- `auth.json` and `mcp-auth.json` are readable inside sandbox (needed for OpenCode to function). Do not store secrets there.
- `service.json` is writable from inside sandbox. Agents cannot forge it to talk to an external opencode; the nvim plugin uses localhost sockets. But an agent **could** write a fake `service.json`. This is a known limitation.
- `.git/hooks` and `.git/config` are always protected by srt's Seatbelt, even if accidentally included in `allowWrite`.
- `~/.m2` (Maven cache) is not explicitly writable, though builds may cache to `/tmp/claude`. Re-test with a Maven project.

### Best-Effort Permission Rules
- Bash patterns in `permission.bash` use best-effort matching. Example: `cat ~/.azure*` checks the literal string, not glob expansion. Agents can evade with variable substitution (`cat $HOME/.azure/config`), but this requires deliberate evasion.
- Absolute paths and tilde-paths in permission rules may not catch suffix-relative or `.` paths. srt's Seatbelt catches these at the OS level.

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

### 7. Azure MCP Read-Only (Six Namespaces)
Inside opencode, call the Azure MCP tool to list resources in `monitor`, `compute`, `group`, `resourcehealth`, `aks`, `applicationinsights`:
```bash
# Example: ask an agent to use Azure MCP
az-mcp list resources --namespace compute
```
**Expected:** Tool accepts `--read-only` and `--disable-proxy-tools` flags (from opencode.json). No mutations allowed.

### 8. Az CLI (Request-for-approval)
```bash
az account show
```
**Expected:** Prompted for approval (opencode permission rules ask for `az *`).

### 9. Service Registration (To Confirm)
From nvim, press `<leader>oa` to start opencode:
1. Check that opencode starts and connects
2. In another terminal (outside sandbox), verify the file exists:
   ```bash
   cat ~/.local/state/opencode/service.json
   ```
   **Expected:** JSON with a `pid` field.
3. Confirm nvim plugin can communicate with opencode (ask a question, get a response).

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

### 12. Ollama Local
```bash
curl http://localhost:11434/api/tags
```
**Expected:** JSON response with available models.

---

**Last updated:** Oct 2026  
**Sandbox baseline:** ConnectPlus.wiki Claude Code  
**Runtime:** srt (sandbox-runtime) with macOS Seatbelt
