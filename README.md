# MDEMG APT Repository

APT package repository for [MDEMG](https://github.com/reh3376/mdemg) — Multi-Dimensional Emergent Memory Graph.

Provides `.deb` packages for Debian-based distributions: Ubuntu 20.04+, Debian 11+, Linux Mint, Pop!_OS.

---

## Quick Install

```bash
# Add repository
curl -fsSL https://reh3376.github.io/apt-mdemg/setup.sh | sudo sh

# Install CLI
sudo apt install mdemg

# Install sidebar companion (optional)
sudo apt install mdemg-sidebar
```

## Manual Setup

```bash
# 1. Add GPG signing key
curl -fsSL https://reh3376.github.io/apt-mdemg/mdemg-archive-keyring.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/mdemg-archive-keyring.gpg

# 2. Add repository
echo "deb [signed-by=/usr/share/keyrings/mdemg-archive-keyring.gpg] \
  https://reh3376.github.io/apt-mdemg stable main" | \
  sudo tee /etc/apt/sources.list.d/mdemg.list

# 3. Install
sudo apt update
sudo apt install mdemg
```

## Upgrade

```bash
sudo apt update && sudo apt upgrade mdemg
```

## Remove

```bash
# Remove package
sudo apt remove mdemg

# Remove repository
sudo rm -f /etc/apt/sources.list.d/mdemg.list
sudo rm -f /usr/share/keyrings/mdemg-archive-keyring.gpg
```

## Available Packages

| Package | Description |
|---------|-------------|
| `mdemg` | CLI + server binary, man pages, systemd units |
| `mdemg-sidebar` | Linux desktop companion app (Tauri) |

## How It Works

The `gh-dev01-pages` branch is automatically updated by the [`apt-publish.yml`](https://github.com/reh3376/mdemg/blob/main/.github/workflows/apt-publish.yml) workflow in the main MDEMG repo whenever a new release is tagged. The workflow:

1. Downloads `.deb` artifacts from the GitHub release
2. Generates APT metadata (`Packages.gz`, `Release`)
3. Signs with GPG
4. Pushes to this repo's `gh-dev01-pages` branch (served by GitHub Pages)

## Repository Structure

```
pool/
  main/
    m/
      mdemg/          # CLI .deb packages
      mdemg-sidebar/  # Sidebar .deb packages
dists/
  stable/
    main/
      binary-amd64/   # amd64 package index
      binary-arm64/   # arm64 package index
    Release           # Signed release metadata
    InRelease         # Clearsigned release
mdemg-archive-keyring.gpg  # Public GPG key
setup.sh                    # One-line setup script
```

## Links

- [MDEMG Source](https://github.com/reh3376/mdemg)
- [Linux Docs](https://github.com/reh3376/mdemg_linux)
- [Linux Sidebar](https://github.com/reh3376/mdemg-linux-sidebar)
- [Issues](https://github.com/reh3376/mdemg/issues)
