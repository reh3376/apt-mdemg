# MDEMG — Multi-Dimensional Emergent Memory Graph

Persistent memory for AI agents. Observations accumulate, cluster into themes, and promote to emergent concepts through Hebbian learning — giving LLMs a long-term knowledge graph that grows and self-organizes.

This repository hosts the **APT package repository** for Debian-based Linux distributions, served via GitHub Pages at `https://reh3376.github.io/apt-mdemg`.

---

## Prerequisites

Complete each item below before installing MDEMG. Verify each one — do not assume anything is already installed.

### 1. Supported Distribution

| Distribution | Minimum Version |
|-------------|----------------|
| Ubuntu | 20.04 LTS (Focal) |
| Debian | 11 (Bullseye) |
| Linux Mint | 20 |
| Pop!_OS | 20.04 |
| Elementary OS | 6 |
| Zorin OS | 16 |

Any Debian-based distribution with `apt` and `dpkg` should work. Both `amd64` (x86_64) and `arm64` (aarch64) architectures are supported.

```bash
# Check your distribution and version
cat /etc/os-release
# Verify architecture
dpkg --print-architecture
# Verify kernel version (5.4+ recommended)
uname -r
```

### 2. Docker Engine

Docker Engine runs the Neo4j database container. MDEMG cannot function without it.

> **Note:** You need Docker Engine, not Docker Desktop. Docker Desktop for Linux works too, but is not required.

```bash
# Check if Docker is installed and running
docker --version
docker info    # This must succeed — if it errors, Docker is not running
```

If Docker is not installed:

```bash
# Add Docker's official repository
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

> For Debian, replace `ubuntu` in the Docker repo URL with `debian`.

**Post-install — add your user to the `docker` group:**

```bash
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
newgrp docker   # Or log out/in

# Verify
docker run --rm hello-world
```

**Start and enable Docker:**

```bash
sudo systemctl enable --now docker
docker info
```

> **Note:** Docker must be running whenever you use MDEMG. Enable auto-start with: `sudo systemctl enable docker`

### 3. OpenAI API Key (recommended) or Ollama

An embedding provider powers semantic search, recall, consolidation naming, and SME consulting. Without one, these features run in degraded mode.

**Option A — OpenAI (recommended):**
1. Sign up at [platform.openai.com](https://platform.openai.com)
2. Create an API key at [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
3. You'll configure this key during `mdemg init`, or set it manually:
   ```bash
   echo 'OPENAI_API_KEY=sk-...' >> .env
   ```

**Option B — Ollama (local-only, no API key needed):**
1. Install Ollama:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. Pull an embedding model:
   ```bash
   ollama pull nomic-embed-text
   ```
3. Verify:
   ```bash
   ollama list
   ```

> **Dimension warning:** OpenAI `text-embedding-3-large` produces 3072-dimension embeddings. Many Ollama models produce fewer dimensions. Run `mdemg embeddings check` after setup to verify.

**Option C — Skip (degraded mode):**
You can run MDEMG without an embedding provider. Ingestion, observation storage, and most API endpoints will work. Semantic recall and LLM-powered naming will be unavailable.

### 4. Git (optional but recommended)

Required for git hooks, incremental ingest, and `mdemg hooks install`.

```bash
git --version
# If not installed: sudo apt install git
```

### Prerequisites Checklist

| # | Requirement | How to verify |
|---|-------------|---------------|
| 1 | Debian-based Linux | `cat /etc/os-release` → supported distribution |
| 2 | Docker Engine installed and running | `docker info` succeeds without errors |
| 3 | User in docker group | `groups` includes `docker` |
| 4 | OpenAI API key or Ollama (optional) | `echo $OPENAI_API_KEY` is set, or `ollama list` shows models |
| 5 | Git installed (optional) | `git --version` returns a version |

---

## Installation

### Quick Install (recommended)

```bash
# Add repository and GPG key
curl -fsSL https://reh3376.github.io/apt-mdemg/setup.sh | sudo sh

# Install CLI + server
sudo apt install mdemg

# Install sidebar companion (optional)
sudo apt install mdemg-sidebar
```

### Manual Setup

```bash
# 1. Add GPG signing key
curl -fsSL https://reh3376.github.io/apt-mdemg/mdemg-archive-keyring.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/mdemg-archive-keyring.gpg

# 2. Add repository
echo "deb [signed-by=/usr/share/keyrings/mdemg-archive-keyring.gpg] \
  https://reh3376.github.io/apt-mdemg stable main" | \
  sudo tee /etc/apt/sources.list.d/mdemg.list

# 3. Update and install
sudo apt update
sudo apt install mdemg
```

**Verify the installation:**

```bash
mdemg version
```

**Expected output:**

```
mdemg v0.3.x
  commit:  <short-hash>
  built:   <date>
  go:      go1.24.x
  os/arch: linux/amd64    # or linux/arm64
```

> **Note:** Docker is required at runtime (`mdemg db start` runs Neo4j via Docker) but is listed as a _recommendation_, not a hard package dependency. The `.deb` installs successfully without Docker, but you must install Docker before using MDEMG.

---

## Available Packages

| Package | Description | Contents |
|---------|-------------|----------|
| `mdemg` | CLI + server binary | `/usr/local/bin/mdemg`, man pages, systemd unit files |
| `mdemg-sidebar` | Linux desktop companion app (Tauri) | System tray app with memory dashboard, instance management, teardown |

### Package Details

**`mdemg` package installs:**
- `/usr/local/bin/mdemg` — unified CLI binary (serve, ingest, consolidate, db, hooks, etc.)
- `/usr/local/share/man/man1/mdemg*.1` — man pages for all commands
- `/etc/systemd/system/mdemg@.service` — systemd unit for server daemon
- `/etc/systemd/system/mdemg-rsic@.service` — systemd unit for RSIC self-improvement
- `/etc/systemd/system/mdemg-rsic@.timer` — timer for scheduled RSIC cycles

**`mdemg-sidebar` package installs:**
- `/usr/local/bin/mdemg-sidebar` — Tauri desktop application
- Desktop entry for application launchers
- 7-tab interface: Dashboard, Memory, Instances, Spaces, Config, Logs, Teardown

---

## Quick Start

Use the step-by-step flow to verify each component individually and catch issues early.

**Step 1 — Initialize configuration:**

```bash
cd ~/your-project    # or any directory you want to use with MDEMG
mdemg init           # Interactive wizard — press Enter to accept defaults
```

Expected: creates `.mdemg/config.yaml` and `.mdemgignore` in the current directory.

```bash
# Verify
ls -la .mdemg/config.yaml .mdemgignore
```

For non-interactive setup with all defaults:

```bash
mdemg init --defaults
```

**Step 2 — Start Neo4j:**

```bash
mdemg db start
```

Expected: starts a Docker container running Neo4j. First run pulls the `neo4j:5` image (~500MB).

```bash
# Verify container is running
mdemg db status
# Should show: container running, bolt port 7687, HTTP port 7474
```

**Step 3 — Start the server:**

```bash
mdemg start --auto-migrate
```

Expected: starts the MDEMG server as a background daemon on port 9999 and applies any pending database migrations.

```bash
# Verify server is running
mdemg status

# Health check
curl -s http://localhost:9999/healthz
# Expected: {"status":"ok"}
```

If `mdemg start` fails, use foreground mode in a separate terminal:

```bash
mdemg serve --auto-migrate
```

**Step 4 — Ingest a codebase:**

```bash
mdemg ingest --path .
```

Expected: scans the directory, extracts code symbols and content, and stores them as observations in the knowledge graph.

**Verify everything is running:**

```bash
mdemg status
```

---

## Systemd Service

The `mdemg` package includes systemd unit files for automatic start on boot and scheduled RSIC self-improvement cycles.

### Install and Enable

```bash
# Enable and start MDEMG for your user
sudo systemctl enable --now mdemg@$USER

# Check status
systemctl status mdemg@$USER

# View logs
journalctl -u mdemg@$USER -f
```

### RSIC Timer (optional)

Enable the scheduled RSIC self-improvement cycle:

```bash
# Enable the timer (runs daily at 3:00 AM with ±5min jitter)
sudo systemctl enable --now mdemg-rsic@$USER.timer

# Check timer status
systemctl list-timers | grep mdemg

# View RSIC logs
journalctl -u mdemg-rsic@$USER
```

### Manual Service Management

```bash
sudo systemctl start mdemg@$USER     # Start
sudo systemctl stop mdemg@$USER      # Stop
sudo systemctl restart mdemg@$USER   # Restart
systemctl status mdemg@$USER         # Status
journalctl -u mdemg@$USER -f         # Follow logs
```

---

## Set Up a Test Project

If you are trying MDEMG for the first time, create a dedicated test directory:

```bash
mkdir -p ~/mdemg-test && cd ~/mdemg-test
git init
git config user.email "tester@example.com"
git config user.name "Tester"

# Create sample files for ingestion
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello from MDEMG")
}
EOF

git add . && git commit -m "initial commit"
```

Then run through the Quick Start steps from within this directory.

---

## Verify Core Functionality

After completing the Quick Start, verify these core features work.

### Configuration

```bash
# Display effective config with source annotations
mdemg config show

# Validate config and probe Neo4j/embedding connectivity
mdemg config validate
```

### Embedding Provider

```bash
mdemg embeddings check
# With OpenAI: reports provider, model, dimensions (3072)
# With Ollama: reports provider, model, dimensions
# Without provider: reports "no embedding provider configured"
```

### Ingest and Observe

```bash
# Ingest the test project
mdemg ingest --path . --space-id test

# Create a manual observation via API
curl -s -X POST http://localhost:9999/v1/conversation/observe \
  -H "Content-Type: application/json" \
  -d '{"space_id":"test","session_id":"test-session","content":"Test observation","obs_type":"learning"}'
# Expected: JSON with "node_id" and "status"
```

### Recall (requires embedding provider)

```bash
curl -s -X POST http://localhost:9999/v1/conversation/recall \
  -H "Content-Type: application/json" \
  -d '{"space_id":"test","query":"What was tested?","top_k":5}'
```

### Resume Session

```bash
curl -s -X POST http://localhost:9999/v1/conversation/resume \
  -H "Content-Type: application/json" \
  -d '{"space_id":"test","session_id":"test-session","max_observations":10}'
```

### Git Hooks (optional)

```bash
mdemg hooks install --space-id test
mdemg hooks list

echo "// hook test" >> main.go
git add . && git commit -m "hook test"
```

### Space Management

```bash
mdemg space list
```

---

## Commands

| Command | Description |
|---------|-------------|
| `mdemg init` | Interactive setup wizard (or `--defaults` / `--quick`) |
| `mdemg version` | Print version, commit, build date |
| `mdemg start` | Start server in background (daemon mode) |
| `mdemg stop` | Stop the running server |
| `mdemg restart` | Restart the server |
| `mdemg status` | Show server, database, and embedding status |
| `mdemg serve` | Run server in foreground (development) |
| `mdemg db start` | Start Neo4j container |
| `mdemg db stop` | Stop Neo4j container (`--remove` to delete) |
| `mdemg db status` | Show container and schema status |
| `mdemg db migrate` | Apply pending schema migrations |
| `mdemg db shell` | Open interactive cypher-shell |
| `mdemg db backup` | Trigger, list, or configure backups |
| `mdemg ingest` | Ingest a codebase into the knowledge graph |
| `mdemg consolidate` | Run hidden layer clustering and consolidation |
| `mdemg watch` | Watch a directory and auto-ingest on changes |
| `mdemg extract-symbols` | Extract code symbols via tree-sitter |
| `mdemg embeddings check` | Verify embedding provider connectivity |
| `mdemg config show` | Display effective configuration with sources |
| `mdemg config validate` | Validate config syntax and probe connectivity |
| `mdemg config set-secret` | Store a secret in the Linux keyring |
| `mdemg config get-secret` | Retrieve a secret from the Linux keyring |
| `mdemg config list-secrets` | List known secrets and their keyring status |
| `mdemg hooks install` | Install git post-commit hooks for auto-ingestion |
| `mdemg hooks uninstall` | Remove installed git hooks |
| `mdemg hooks list` | List installed hooks and their status |
| `mdemg sidebar` | Manage sidebar companion app (start/stop/restart/status) |
| `mdemg teardown` | Full instance teardown (14 phases, `--dry-run` supported) |
| `mdemg decay` | Apply temporal decay to learning edges |
| `mdemg prune` | Prune weak edges, tombstone orphans |
| `mdemg sidecar` | Manage sidecar services (up, down, attach, detach) |
| `mdemg mcp` | Run MCP server for IDE integration |
| `mdemg space` | Manage memory spaces (list, export, import, copy, delete, rename, info) |
| `mdemg plugin` | Manage plugins |
| `mdemg demo` | Run interactive demo |
| `mdemg upgrade` | Self-update to the latest release |

Use `mdemg <command> --help` for full flag details on any command.

For complete reference documentation, see the [CLI Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md).

---

## Documentation

| Guide | What it covers |
|-------|---------------|
| [CLI Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/cli-reference.md) | All commands, flags, defaults, examples, environment variables |
| [API Reference](https://github.com/reh3376/mdemg/blob/main/docs/user/api-reference.md) | Every HTTP endpoint with request/response shapes and curl examples |
| [CMS & RSIC Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/cms-rsic-guide.md) | Conversation memory, observation types, surprise scoring, self-improvement cycles |
| [Ingestion Guide](https://github.com/reh3376/mdemg/blob/main/docs/user/ingestion-guide.md) | All 8 ingestion methods — codebase, scraper, Linear, webhooks, file watcher, API |

---

## Configuration

Priority chain (lowest to highest):

```
defaults → .mdemg/config.yaml → keyring → .env → environment variables → CLI flags
```

### View and Validate

```bash
mdemg config show          # View effective config with sources
mdemg config show --json   # Machine-readable output
mdemg config validate      # Validate syntax and probe connectivity
```

### Config File

Created by `mdemg init` at `.mdemg/config.yaml`:

```yaml
server:
  port: 9999
neo4j:
  uri: bolt://localhost:7687
  user: neo4j
  password: mdemg-dev
embeddings:
  provider: openai           # or "ollama"
  model: text-embedding-3-large
```

### Secrets

Secrets should not be stored in `config.yaml`. Use one of these approaches:

**Option A — `.env` file (recommended for development):**

```bash
cat > .env << 'EOF'
OPENAI_API_KEY=sk-...
NEO4J_PASS=your-password
EOF
```

**Option B — Linux keyring (recommended for shared machines):**

MDEMG uses the system keyring via `go-keyring`, which supports:
- **GNOME** — gnome-keyring (via Secret Service API)
- **KDE** — kwallet
- **Headless/minimal** — `pass` (GPG-based password manager)

```bash
mdemg config set-secret OPENAI_API_KEY sk-...
mdemg config set-secret NEO4J_PASS your-password

# Verify
mdemg config list-secrets
mdemg config get-secret OPENAI_API_KEY
```

> **Headless servers:** If no desktop environment is available, `go-keyring` falls back to `pass`. Install with `sudo apt install pass gnupg`, initialize with `pass init <gpg-key-id>`.

**Option C — Environment variables:**

```bash
export OPENAI_API_KEY=sk-...
# Add to ~/.bashrc or ~/.profile to persist
```

---

## Troubleshooting

### `mdemg: command not found` after install

```bash
# If installed via APT, the binary is at /usr/local/bin/mdemg
# Ensure /usr/local/bin is on your PATH:
echo $PATH | tr ':' '\n' | grep /usr/local/bin

# Fix:
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### APT repository errors

```bash
# "The following signatures couldn't be verified" → re-add the GPG key:
curl -fsSL https://reh3376.github.io/apt-mdemg/mdemg-archive-keyring.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/mdemg-archive-keyring.gpg

# "Unable to locate package mdemg" → verify the repo was added:
cat /etc/apt/sources.list.d/mdemg.list
sudo apt update

# "NO_PUBKEY" error → the keyring file is missing or corrupted:
sudo rm -f /usr/share/keyrings/mdemg-archive-keyring.gpg
curl -fsSL https://reh3376.github.io/apt-mdemg/setup.sh | sudo sh
```

### Docker not running

```bash
docker info
# If error: "Cannot connect to the Docker daemon"
sudo systemctl start docker
sudo systemctl enable docker

# If permission denied:
sudo usermod -aG docker $USER
# Log out and back in, then retry
```

### Neo4j won't start

```bash
mdemg db status
docker ps -a --filter "name=mdemg-neo4j"

# View container logs
docker logs mdemg-neo4j-$(basename $(pwd))

# Common causes:
# 1. Docker not running → sudo systemctl start docker
# 2. Port 7687 in use → mdemg db start --port 7688
# 3. Bad state → mdemg db stop --remove && mdemg db start
```

### Neo4j port conflict

```bash
ss -tlnp | grep 7687
mdemg db start --port 7688
```

### Server won't start

```bash
cat .mdemg/logs/mdemg.log
ss -tlnp | grep 9999
mdemg serve --auto-migrate   # Foreground mode to see errors
```

### Missing OpenAI key

```bash
echo $OPENAI_API_KEY
echo 'OPENAI_API_KEY=sk-...' >> .env
# Or: mdemg config set-secret OPENAI_API_KEY sk-...
mdemg restart
```

### Embedding check fails

```bash
mdemg embeddings check
# Check API key: echo $OPENAI_API_KEY
# Check network: curl -s https://api.openai.com/v1/models -H "Authorization: Bearer $OPENAI_API_KEY" | head -5
# If Ollama: ollama list
```

### Migrations fail

```bash
mdemg db status
mdemg db migrate
mdemg config validate
```

### Health check returns errors

```bash
curl -s http://localhost:9999/healthz | python3 -m json.tool
curl -s http://localhost:9999/readyz | python3 -m json.tool
mdemg status
```

### Keyring not available (headless servers)

```bash
# If mdemg config set-secret fails with "No keyring backend found":
sudo apt install pass gnupg

# Generate a GPG key if you don't have one:
gpg --gen-key

# Initialize pass:
pass init <gpg-key-id>

# Retry:
mdemg config set-secret OPENAI_API_KEY sk-...
```

---

## Upgrading

```bash
sudo apt update && sudo apt upgrade mdemg

# Apply new database migrations
mdemg restart
mdemg db migrate
```

The APT repository is updated automatically whenever a new MDEMG release is tagged on GitHub. Running `sudo apt update` will fetch the latest package metadata.

---

## Uninstall

### Remove Package (keeps config)

```bash
sudo apt remove mdemg
sudo apt remove mdemg-sidebar   # if installed
```

### Purge Package and Config

```bash
sudo apt purge mdemg
```

### Remove APT Repository

```bash
sudo rm -f /etc/apt/sources.list.d/mdemg.list
sudo rm -f /usr/share/keyrings/mdemg-archive-keyring.gpg
```

### Full Teardown

Use `mdemg teardown` before uninstalling for comprehensive cleanup:

```bash
# Preview what will be removed
mdemg teardown --dry-run

# Full teardown (server, Docker, Neo4j, hooks, MCP configs, .mdemg/)
mdemg teardown --yes

# Then remove the package and repo
sudo apt purge mdemg
sudo rm -f /etc/apt/sources.list.d/mdemg.list
sudo rm -f /usr/share/keyrings/mdemg-archive-keyring.gpg
```

### Manual Cleanup

```bash
# Stop server and Neo4j
mdemg stop
mdemg db stop --remove

# Disable systemd services
sudo systemctl disable --now mdemg@$USER 2>/dev/null
sudo systemctl disable --now mdemg-rsic@$USER.timer 2>/dev/null

# Remove Docker volumes (deletes all stored data)
docker volume ls -q --filter name=mdemg | xargs -r docker volume rm

# Remove systemd units
sudo rm -f /etc/systemd/system/mdemg@.service /etc/systemd/system/mdemg-rsic@.service /etc/systemd/system/mdemg-rsic@.timer
sudo systemctl daemon-reload

# Remove config/data directory
rm -rf .mdemg
```

---

## How the APT Repository Works

The `gh-dev01-pages` branch is automatically updated by the [`apt-publish.yml`](https://github.com/reh3376/mdemg/blob/main/.github/workflows/apt-publish.yml) workflow in the main MDEMG repo whenever a new release is tagged. The workflow:

1. Downloads `.deb` artifacts from the GitHub release
2. Generates APT metadata (`Packages`, `Packages.gz`, `Release`)
3. Signs `Release` and generates `InRelease` with GPG
4. Pushes to this repo's `gh-dev01-pages` branch (served by GitHub Pages)

The repository follows the standard Debian repository layout with `pool/` for package files and `dists/` for metadata.

### Repository Structure

```
pool/
  main/
    m/
      mdemg/              # CLI .deb packages (amd64 + arm64)
      mdemg-sidebar/      # Sidebar .deb packages (amd64 + arm64)
dists/
  stable/
    main/
      binary-amd64/       # amd64 package index (Packages, Packages.gz)
      binary-arm64/       # arm64 package index (Packages, Packages.gz)
    Release               # Signed release metadata
    InRelease             # Clearsigned release (for apt)
mdemg-archive-keyring.gpg # Public GPG key for signature verification
setup.sh                   # One-line repository setup script
```

### GPG Signing

All packages and repository metadata are signed with a GPG key. The public key is available at:

```
https://reh3376.github.io/apt-mdemg/mdemg-archive-keyring.gpg
```

The key is installed to `/usr/share/keyrings/mdemg-archive-keyring.gpg` during setup and referenced by the `signed-by` option in the sources list.

---

## Man Pages

```bash
man mdemg
man mdemg-init
man mdemg-ingest
# Full list:
ls /usr/local/share/man/man1/mdemg*
```

---

## Links

- [MDEMG Source](https://github.com/reh3376/mdemg)
- [Linux Docs](https://github.com/reh3376/mdemg_linux) — general Linux documentation (all distros)
- [Linux Sidebar](https://github.com/reh3376/mdemg-linux-sidebar) — Linux desktop companion app
- [macOS Installer (Homebrew)](https://github.com/reh3376/homebrew-mdemg)
- [macOS Menu Bar App](https://github.com/reh3376/mdemg-menubar)
- [Windows Installer](https://github.com/reh3376/mdemg-windows)
- [Issues](https://github.com/reh3376/mdemg/issues)
