#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# opencode-container — Launch opencode in a Podman container
# =============================================================================
#
# Runs the opencode TUI inside a containerized environment with:
#   - Config directory mounted (agents, skills, configs, AGENTS.md, secrets)
#   - Current working directory mounted as /workspace
#   - Named volume for persistent state (state_store.db, node_modules cache)
#   - Host ~/.agentmemory bind-mounted (agentmemory sync between host and container)
#
# SECURITY: Mounts are scoped. We do NOT mount the entire home directory,
#           SSH keys, GPG keys, AWS creds, or browser data.
#
# Usage:
#   opencode-container                    # Run in current directory
#   opencode-container /path/to/project   # Run in a specific directory
#   opencode-container --build            # Force rebuild the image
#   opencode-container -- --env MY_VAR=x  # Pass extra podman args
#
# =============================================================================

readonly SCRIPT_NAME="opencode-container"
readonly IMAGE_NAME="opencode-env"
readonly CONTAINER_HOSTNAME="opencode-env"
readonly CONTAINER_WORKDIR="/workspace"
readonly CONTAINER_USER="dev"
readonly STATE_VOLUME="opencode-state"
readonly AGENTMEMORY_HOST_DIR="${HOME}/.agentmemory"
readonly IMPROVEMENTS_DIR="${HOME}/OpencodeImprovements"
readonly CONTAINER_HOME="/home/${CONTAINER_USER}"

# --- Resolve script location (for finding Containerfile) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Config root is one level up from scripts/
CONFIG_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Defaults ---
FORCE_BUILD=false
WORKSPACE_DIR=""
EXTRA_ARGS=()
VOLUME_MOUNTS=()

# --- Parse arguments ---
show_help() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] [WORKSPACE_DIR] [-- EXTRA_ARGS...]

Launch opencode in a Podman container.

Options:
  --build       Force rebuild the container image
  --help        Show this help message

Arguments:
  WORKSPACE_DIR   Directory to mount as /workspace (default: current dir)
  -- EXTRA_ARGS   Additional arguments passed to 'podman run'

Examples:
  ${SCRIPT_NAME}                          # Run in current directory
  ${SCRIPT_NAME} /path/to/project         # Run in a specific directory
  ${SCRIPT_NAME} --build                  # Rebuild image, then run
  ${SCRIPT_NAME} -- --env MY_VAR=value    # Pass extra env to container
  ${SCRIPT_NAME} /my/project --build      # Combine options
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build)
            FORCE_BUILD=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        --)
            shift
            EXTRA_ARGS=("$@")
            break
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            echo "Run '${SCRIPT_NAME} --help' for usage." >&2
            exit 1
            ;;
        *)
            if [[ -z "$WORKSPACE_DIR" ]]; then
                WORKSPACE_DIR="$1"
            else
                echo "Error: Unexpected argument '$1'" >&2
                echo "Run '${SCRIPT_NAME} --help' for usage." >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Default workspace to home directory
if [[ -z "$WORKSPACE_DIR" ]]; then
    WORKSPACE_DIR="$HOME"
fi

# Resolve to absolute path
WORKSPACE_DIR="$(cd "$WORKSPACE_DIR" && pwd)"

# --- Check podman is installed ---
if ! command -v podman &>/dev/null; then
    echo "Error: podman is not installed or not in PATH." >&2
    echo "" >&2
    echo "Install podman:" >&2
    echo "  Fedora/RHEL:  sudo dnf install podman" >&2
    echo "  Ubuntu/Debian: sudo apt install podman" >&2
    echo "  macOS:         brew install podman" >&2
    echo "  Arch:          sudo pacman -S podman" >&2
    exit 1
fi

# --- Find Containerfile ---
# Look in config root (where the Containerfile should live)
CONTAINERFILE=""
for candidate in "${CONFIG_ROOT}/Containerfile" "${CONFIG_ROOT}/Dockerfile"; do
    if [[ -f "$candidate" ]]; then
        CONTAINERFILE="$candidate"
        break
    fi
done

if [[ -z "$CONTAINERFILE" ]]; then
    echo "Error: No Containerfile or Dockerfile found in ${CONFIG_ROOT}/" >&2
    echo "" >&2
    echo "Expected one of:" >&2
    echo "  ${CONFIG_ROOT}/Containerfile" >&2
    echo "  ${CONFIG_ROOT}/Dockerfile" >&2
    echo "" >&2
    echo "Create a Containerfile first, then re-run this script." >&2
    exit 1
fi

# --- Check if image exists, or force build ---
image_exists() {
    podman image exists "$IMAGE_NAME" 2>/dev/null
}

if [[ "$FORCE_BUILD" == true ]] || ! image_exists; then
    if [[ "$FORCE_BUILD" == true ]]; then
        echo "🔨 Force building image '${IMAGE_NAME}'..."
    else
        echo "📦 Image '${IMAGE_NAME}' not found. Building..."
    fi
    echo "   Containerfile: ${CONTAINERFILE}"
    echo ""

    podman build -t "$IMAGE_NAME" -f "$CONTAINERFILE" "$CONFIG_ROOT"

    echo ""
    echo "✅ Image built successfully."
    echo ""
else
    echo "✅ Image '${IMAGE_NAME}' already exists. Skipping build."
    echo "   (Use --build to force rebuild)"
    echo ""
fi

# --- Verify workspace directory exists ---
if [[ ! -d "$WORKSPACE_DIR" ]]; then
    echo "Error: Workspace directory does not exist: ${WORKSPACE_DIR}" >&2
    exit 1
fi

# --- Handle Tavily API key ---
SECRETS_DIR="${CONFIG_ROOT}/.secrets"
TAVILY_KEY_FILE="${SECRETS_DIR}/tavily.key"
TAVILY_MOUNT=""

if [[ -f "$TAVILY_KEY_FILE" ]]; then
    VOLUME_MOUNTS+=("--volume" "${TAVILY_KEY_FILE}:${CONTAINER_HOME}/.config/opencode/.secrets/tavily.key:ro")
else
    echo "🔑 Tavily API key not found."
    echo "   Tavily is needed for web search in opencode."
    echo ""
    read -rp "   Enter your Tavily API key (or press Enter to skip): " TAVILY_KEY

    if [[ -n "$TAVILY_KEY" ]]; then
        mkdir -p "$SECRETS_DIR"
        echo -n "$TAVILY_KEY" > "$TAVILY_KEY_FILE"
        chmod 600 "$TAVILY_KEY_FILE"
        VOLUME_MOUNTS+=("--volume" "${TAVILY_KEY_FILE}:${CONTAINER_HOME}/.config/opencode/.secrets/tavily.key:ro")
        echo "   ✅ Key saved to ${TAVILY_KEY_FILE}"
    else
        echo "   ⚠️  Skipping — Tavily search won't work without a key."
    fi
    echo ""
fi

# --- Handle X11 clipboard support ---
X11_MOUNTS=()
if [[ -n "${DISPLAY:-}" ]]; then
    X11_MOUNTS+=("--env" "DISPLAY=${DISPLAY}")
    if [[ -e "/tmp/.X11-unix" ]]; then
        X11_MOUNTS+=("--volume" "/tmp/.X11-unix:/tmp/.X11-unix")
    fi
    if [[ -e "${XAUTHORITY:-$HOME/.Xauthority}" ]]; then
        X11_MOUNTS+=("--volume" "${XAUTHORITY:-$HOME/.Xauthority}:${CONTAINER_HOME}/.Xauthority")
        X11_MOUNTS+=("--env" "XAUTHORITY=${CONTAINER_HOME}/.Xauthority")
    fi
fi

# --- Ensure host agentmemory directory exists for host<->container sync ---
mkdir -p "${AGENTMEMORY_HOST_DIR}"

# --- Print what we're doing ---
echo "🚀 Launching opencode container..."
echo ""
echo "   Workspace:      ${WORKSPACE_DIR} → ${CONTAINER_WORKDIR}"
echo "   State volume:   ${STATE_VOLUME} → ${CONTAINER_HOME}/.config/opencode/data"
echo "   Agentmemory:    ${AGENTMEMORY_HOST_DIR} ↔ ${CONTAINER_HOME}/.agentmemory"
echo "   Improvements:   ${IMPROVEMENTS_DIR} ↔ ${CONTAINER_HOME}/OpencodeImprovements"
echo "   Config:         baked into image (not mounted from host)"
echo "   User:           $(id -u):$(id -g)"
echo "   Hostname:       ${CONTAINER_HOSTNAME}"
echo ""

# --- Run the container ---
exec podman run \
    --rm \
    --interactive \
    --tty \
    --user "$(id -u):$(id -g)" \
    --userns keep-id \
    --network host \
    --hostname "$CONTAINER_HOSTNAME" \
    --workdir "$CONTAINER_WORKDIR" \
    --security-opt label=disable \
    --env "SHELL=/usr/bin/bash" \
    --env "HOME=${CONTAINER_HOME}" \
    --env "PATH=${CONTAINER_HOME}/.config/opencode/scripts:${CONTAINER_HOME}/.local/share/pnpm/bin:${CONTAINER_HOME}/.cargo/bin:${CONTAINER_HOME}/.local/bin:${CONTAINER_HOME}/.opencode/bin:/usr/local/bin:/usr/bin" \
    --volume "${WORKSPACE_DIR}:${CONTAINER_WORKDIR}" \
    --volume "${STATE_VOLUME}:${CONTAINER_HOME}/.config/opencode/data" \
    --volume "${AGENTMEMORY_HOST_DIR}:${CONTAINER_HOME}/.agentmemory" \
    --volume "${IMPROVEMENTS_DIR}:${CONTAINER_HOME}/OpencodeImprovements" \
    ${VOLUME_MOUNTS[@]+"${VOLUME_MOUNTS[@]}"} \
    ${X11_MOUNTS[@]+"${X11_MOUNTS[@]}"} \
    ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"} \
    "$IMAGE_NAME"
