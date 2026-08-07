# 🐳 Container Setup — opencode Development Environment

> **Run opencode in an isolated, reproducible container with all dependencies pre-installed.**

This guide walks you through setting up and using the opencode Podman container from scratch. No container experience required.

---

## 📋 Prerequisites

| Requirement | Why |
|-------------|-----|
| **Podman** | Container runtime (drop-in Docker replacement) |
| **Git** | Clone the config repo |
| **Internet** | First build downloads ~1GB of packages |

### Install Podman

```bash
# Fedora / RHEL
sudo dnf install -y podman

# Ubuntu / Debian
sudo apt install -y podman

# macOS (Apple Silicon or Intel)
brew install podman
podman machine init
podman machine start

# Arch
sudo pacman -S podman
```

### Verify

```bash
podman --version
# podman version 5.x.x or later
```

---

## ⚡ Quick Start (3 Commands)

```bash
# 1. Clone the config (to ANY directory — NOT your actual ~/.config/opencode)
git clone <your-repo-url> ~/opencode-container
cd ~/opencode-container

# 2. Build the image (first time only — takes a few minutes)
./scripts/launcher.sh --build

# 3. You're in. Run opencode inside the container.
opencode
```

That's it. The launcher handles everything: image build, API key setup, workspace mounts, clipboard support.

**Your first project** — the launcher drops you into a bash shell inside the container. Pick your path:

🆕 **New project** — scaffold it, step into it, start opencode:

```bash
create-project my-api      # scaffold (git, per-project config, codegraph)
cd my-api                  # step into it
opencode                   # start working
```

📂 **Existing project** — mount your projects folder, step into it, wire it up:

```bash
./scripts/launcher.sh ~/code    # on the host — mount your projects folder

cd /workspace/my-api            # inside the container — step into the project
setup-project                   # init OpenSpec + CodeGraph for it
opencode                        # start working
```

> **⚠️ Important:** Clone to a **separate directory** (e.g., `~/opencode-container`), NOT to `~/.config/opencode`. The container bakes its own copy of the config at build time. Your host's `~/.config/opencode` stays untouched.

---

## 🔧 Detailed Setup — Step by Step

### Step 1: Install Podman

See the [Prerequisites](#-prerequisites) section above.

### Step 2: Clone the Config

```bash
# Clone to a dedicated directory — NOT your actual ~/.config/opencode
git clone <your-repo-url> ~/opencode-container
cd ~/opencode-container
```

> **Why a separate directory?** The Containerfile copies files from the cloned directory into the image at build time. Your host's `~/.config/opencode` is never touched. You can name the directory whatever you want.

### Step 3: Build the Container Image

```bash
./scripts/launcher.sh --build
```

On first run, you'll see:
```
🔨 Force building image 'opencode-env'...
   Containerfile: /home/allen/.config/opencode/Containerfile

[build output...]
✅ Image built successfully.
```

This takes 3-10 minutes depending on your machine and internet speed. Subsequent runs are instant (cached layers).

### Step 4: Tavily API Key

On first launch, the launcher prompts for your [Tavily](https://tavily.com) API key:

```
🔑 Tavily API key not found.
   Tavily is needed for web search in opencode.

   Enter your Tavily API key (or press Enter to skip): tvly-xxxxx
   ✅ Key saved to /home/allen/.config/opencode/.secrets/tavily.key
```

The key is stored in your cloned directory at `.secrets/tavily.key` and mounted read-only into the container. You can skip this if you don't need web search.

### Step 5: Start Working

You're dropped into a bash shell inside the container, in `/workspace`:

```
🚀 Launching opencode container...

   Workspace:      /home/allen → /workspace
   State volume:   opencode-state → /home/allen/.config/opencode/data
   Config:         baked into image (not mounted from host)
   User:           1000:1000
   Hostname:       opencode-env
```

**What now?**
- 🆕 **New project:** run `create-project my-api` → `cd my-api` → `opencode` (see [Creating a New Project](#creating-a-new-project)).
- 📂 **Existing project:** relaunch with its path — `./scripts/launcher.sh /path/to/my/project` — then `setup-project` and `opencode` (see [Opening an Existing Project](#opening-an-existing-project)).

---

## 🖥️ Running the Container

### Basic Usage

```bash
# Run in current directory
./scripts/launcher.sh

# Run in a specific directory
./scripts/launcher.sh /path/to/my/project

# Force rebuild image, then run
./scripts/launcher.sh --build

# Combine options
./scripts/launcher.sh /my/project --build
```

### Launcher Options

| Option | Description |
|--------|-------------|
| `--build` | Force rebuild the image before running |
| `--help` | Show help message |
| `WORKSPACE_DIR` | Directory to mount as `/workspace` (default: current dir) |
| `-- EXTRA_ARGS` | Additional `podman run` arguments |

### What the Launcher Does

1. ✅ Checks if Podman is installed
2. ✅ Builds the image if it doesn't exist (or `--build` is passed)
3. ✅ Prompts for Tavily API key on first run
4. ✅ Mounts your workspace directory as `/workspace`
5. ✅ Mounts secrets file read-only
6. ✅ Enables clipboard support (X11 socket if available)
7. ✅ Maps your host UID into the container (no root-owned files)
8. ✅ Drops you into a bash shell

### Passing Extra Arguments

```bash
# Pass environment variables
./scripts/launcher.sh -- --env MY_VAR=value

# Set a custom hostname
./scripts/launcher.sh -- --hostname my-dev
```

---

## 🏗️ What's Inside the Container

The container is based on **Fedora 44** and includes:

| Tool | Version | Purpose |
|------|---------|---------|
| **Node.js** | 22 | JavaScript runtime |
| **pnpm** | 10.33.0 | Package manager |
| **Rust** | 1.97.1 | Compiled tooling |
| **Nushell** | — | Structured data shell |
| **just** | 1.55.1 | Task runner |
| **opencode-ai** | latest | The TUI |
| **codegraph** | 1.5.0 | Codebase intelligence |
| **agentmemory** | 0.9.28 | Persistent memory |
| **openspec** | 1.7.0 | Spec management |

Plus: `git`, `curl`, `jq`, `ripgrep`, `tree`, `tmux`, `python3`, `gh`, `podman`, `xclip`, and build tools (`gcc`, `make`, `cmake`).

### MCP Servers

| Server | Status | What It Does |
|--------|--------|--------------|
| **codegraph** | Local (bundled) | Codebase exploration, symbol lookup, call chains |
| **tavily** | Remote | Web search, docs extraction |
| **agentmemory** | Local (bundled) | Persistent memory across sessions |

All MCP servers are pre-configured and load automatically when you run `opencode`.

---

## 📁 Working Inside the Container

### Creating a New Project

```bash
create-project my-api
```

This creates:
- `my-api/` directory with git initialized
- `README.md` with boilerplate
- `.opencode/opencode.json` config file
- Codegraph index (if available)

**Options:**
```bash
create-project my-api --no-git          # Skip git init
create-project my-api --no-codegraph    # Skip codegraph init
create-project my-api --dir ~/projects  # Create in a specific parent dir
```

### Opening an Existing Project

Mount any existing project as `/workspace` by passing its path to the launcher:

```bash
# On the host
./scripts/launcher.sh /path/to/my/project
```

You're dropped into the project root inside the container. Wire it up for opencode:

```bash
# 1. Initialize OpenSpec + CodeGraph for this directory
setup-project

# 2. Start working
opencode
```

**What `setup-project` does** — it initializes the two things agents need to be effective on an existing codebase:

- **OpenSpec** (`openspec init`) — spec-driven development: an `openspec/` structure (config, changes, specs) plus OpenCode tooling in `.opencode/`
- **CodeGraph** (`codegraph init`) — indexes the codebase (`.codegraph/`) so agents can explore symbols, call chains, and blast radius

It's safe to re-run — both tools are idempotent. Pass a directory to target something other than the current one (`setup-project /path/to/project`).

> Files are **bidirectional** — edits you make inside the container appear on your host and vice versa.

### Running opencode

```bash
opencode
```

This launches the TUI. All agents, skills, and MCP servers are loaded from the image — no setup needed.

### Working with Files

Your workspace (`~/` on the host) is mounted at `/workspace` in the container. **Files are bidirectional** — changes you make inside the container appear on your host and vice versa.

```bash
# Inside the container
cd /workspace
ls                  # See your host files
opencode            # Start the TUI
git status          # Git works as expected
pnpm install        # Install dependencies
```

### Clipboard Support

If you're on a desktop Linux machine with X11, clipboard operations work automatically. The launcher mounts the X11 socket and Xauthority file.

---

## ⚙️ Configuration

### How Config Works

**The container config is OWNED by the container image.** This means:

- ✅ Agents, skills, MCP configs, and `AGENTS.md` are baked into the image at build time
- ✅ They're always consistent — every build gets the same config
- ❌ Changes you make to config files inside the container **don't affect the host**
- ❌ Changes you make to config files on the host **don't affect the container**

This is intentional. The container is a reproducible, isolated environment.

### Updating Container Config

To update the config that ships with the container:

1. **Edit files on your host** (in your cloned directory, e.g., `~/opencode-container/`)
2. **Rebuild the image:**

```bash
./scripts/launcher.sh --build
```

This picks up your host-side config changes and bakes them into the new image.

### Secrets Management

Secrets are handled separately from config — they're **mounted at runtime**, not baked in.

| Secret | Location | How It's Mounted |
|--------|----------|------------------|
| Tavily API key | `<cloned-dir>/.secrets/tavily.key` | Read-only bind mount |

**Rules:**
- The `.secrets/` directory is **never committed to git** (check your `.gitignore`)
- Secrets are mounted read-only — the container can read but not modify them
- If you skip the Tavily key prompt, web search won't work (you can add it later by creating the file)

**To add a key later:**
```bash
# On the host — in your cloned directory
mkdir -p ~/opencode-container/.secrets
echo -n "tvly-your-key-here" > ~/opencode-container/.secrets/tavily.key
chmod 600 ~/opencode-container/.secrets/tavily.key
```

---

## 🏛️ Architecture

### What's Mounted (Host → Container)

| Host Path | Container Path | Mode |
|-----------|----------------|------|
| `~/` (or specified dir) | `/workspace` | Read/Write |
| `<cloned-dir>/.secrets/tavily.key` | `/home/allen/.config/opencode/.secrets/tavily.key` | Read-only |
| `/tmp/.X11-unix` | `/tmp/.X11-unix` | Read/Write (if X11 available) |
| `~/.Xauthority` | `/home/allen/.Xauthority` | Read/Write (if X11 available) |

### What's Baked Into the Image

| Component | Path in Container |
|-----------|-------------------|
| Agents | `/home/allen/.config/opencode/agents/` |
| Skills | `/home/allen/.config/opencode/skills/` |
| AGENTS.md | `/home/allen/.config/opencode/AGENTS.md` |
| opencode config | `/home/allen/.config/opencode/opencode.jsonc` |
| Package deps | `/home/allen/.config/opencode/node_modules/` |
| Scripts | `/usr/local/bin/first-run`, `/usr/local/bin/create-project`, `/usr/local/bin/setup-project` |

### Persistent State

A named volume (`opencode-state`) stores:
- `state_store.db` — opencode session state
- `node_modules/` cache — faster subsequent installs

This survives container rebuilds.

### User Mapping

The container runs as a non-root user (`allen`, UID 1000) with `--userns keep-id`. Your host UID is mapped into the container, so files you create inside have correct ownership on the host.

---

## 🔍 Troubleshooting

### "podman is not installed or not in PATH"

```bash
# Verify installation
podman --version

# If not found, install it:
# Fedora:   sudo dnf install podman
# Ubuntu:   sudo apt install podman
# macOS:    brew install podman && podman machine init && podman machine start
```

### Build Fails with "permission denied"

```bash
# If running rootless podman, make sure your user is in the right group
# (usually automatic on modern distros)
# Try building explicitly:
podman build -t opencode-env -f Containerfile .
```

### "Tavily search won't work"

You skipped the API key prompt or the file doesn't exist. Add it manually:

```bash
# In your cloned directory (e.g., ~/opencode-container)
mkdir -p .secrets
echo -n "tvly-your-key" > .secrets/tavily.key
chmod 600 .secrets/tavily.key
```

Then restart the container — it picks up the key automatically.

### Clipboard Not Working (xclip inside container)

Ensure X11 is available:

```bash
# On the host, check if X11 is running
echo $DISPLAY
ls /tmp/.X11-unix/

# If empty, X11 isn't running — clipboard won't work in the container
# This is expected on headless servers
```

### Container Can't See My Files

Make sure you're passing the right directory:

```bash
# Default: mounts current directory
cd ~/my-project
./scripts/launcher.sh

# Or specify explicitly
./scripts/launcher.sh ~/my-project
```

### First-Run Setup Takes Long

The first run runs `pnpm install` for config dependencies. Subsequent runs skip this (cached via the `.initialized` marker file).

### Container Config Is Stale

If you updated files on the host and want them in the container:

```bash
./scripts/launcher.sh --build
```

This rebuilds the image, picking up all host-side changes.

### "opencode: command not found" Inside Container

The image might be stale. Rebuild:

```bash
./scripts/launcher.sh --build
```

### Image Build Is Slow

First build downloads ~1GB of packages. Subsequent builds use Podman layer caching and only rebuild changed layers (typically seconds).

---

## 🔗 Quick Reference

```bash
# Install podman
sudo dnf install podman        # Fedora
sudo apt install podman        # Ubuntu
brew install podman            # macOS

# Build & run
cd ~/opencode-container        # Or wherever you cloned
./scripts/launcher.sh --build  # First time / after config changes
./scripts/launcher.sh          # Subsequent runs

# Inside the container
create-project my-app          # New project
setup-project                  # Wire an existing project (OpenSpec + CodeGraph)
opencode                       # Start the TUI

# On the host
~/opencode-container/.secrets/ # Secrets directory
```

---

*Built for the opencode software company. Every specialist gets a reproducible, identical environment — no "works on my machine."*
