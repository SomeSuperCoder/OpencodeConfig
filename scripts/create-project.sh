#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# create-project — Scaffold a new opencode project
# Usage: create-project <project-name> [options]
# ============================================================================

# --- Color support (graceful fallback) ---
if [[ -t 1 ]] && command -v tput &>/dev/null && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
else
  RED="" GREEN="" YELLOW="" BLUE="" BOLD="" RESET=""
fi

# --- Helpers ---
info()  { printf "%s%sℹ%s  %s\n" "$BLUE"  "$BOLD" "$RESET" "$*"; }
ok()    { printf "%s%s✅%s %s\n" "$GREEN" "$BOLD" "$RESET" "$*"; }
warn()  { printf "%s%s⚠️ %s%s\n" "$YELLOW" "$BOLD" "$*" "$RESET"; }
err()   { printf "%s%s❌%s %s\n" "$RED"   "$BOLD" "$RESET" "$*" >&2; }
die()   { err "$@"; exit 1; }

# --- Usage ---
usage() {
  cat <<EOF
${BOLD}Usage:${RESET} create-project <project-name> [options]

${BOLD}Options:${RESET}
  --help            Show this help message
  --no-git          Skip git repository initialization
  --no-codegraph    Skip codegraph initialization
  --dir <path>      Parent directory for the project (default: /workspace or pwd)

${BOLD}Examples:${RESET}
  create-project my-api
  create-project my-api --dir ~/projects --no-codegraph
  create-project my-api --no-git
EOF
}

# --- Parse arguments ---
PROJECT_NAME=""
NO_GIT=false
NO_CODEGRAPH=false
PARENT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --no-git)
      NO_GIT=true
      shift
      ;;
    --no-codegraph)
      NO_CODEGRAPH=true
      shift
      ;;
    --dir)
      [[ -z "${2:-}" ]] && die "--dir requires a path argument"
      PARENT_DIR="$2"
      shift 2
      ;;
    -*)
      die "Unknown option: $1 (use --help for usage)"
      ;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$1"
      else
        die "Unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

# --- Validate project name ---
if [[ -z "$PROJECT_NAME" ]]; then
  err "Missing required argument: project-name"
  echo ""
  usage
  exit 1
fi

if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
  die "Invalid project name: '$PROJECT_NAME'
  Name must start with a letter or digit and contain only letters, digits, hyphens, and underscores."
fi

# --- Determine workspace root ---
if [[ -n "$PARENT_DIR" ]]; then
  WORKSPACE="$PARENT_DIR"
elif [[ -d "/workspace" ]]; then
  WORKSPACE="/workspace"
else
  WORKSPACE="$(pwd)"
fi

PROJECT_DIR="${WORKSPACE}/${PROJECT_NAME}"

# --- Check if directory already exists ---
if [[ -d "$PROJECT_DIR" ]]; then
  die "Directory '$PROJECT_DIR' already exists. Remove it first or choose a different name."
fi

# --- Create project directory ---
info "Creating project at ${BOLD}${PROJECT_DIR}${RESET}"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# --- Initialize git ---
if [[ "$NO_GIT" == true ]]; then
  warn "Skipping git initialization (--no-git)"
else
  info "Initializing git repository..."
  git init --quiet
  echo "# ${PROJECT_NAME}" > README.md
  echo "" >> README.md
  echo "Created with opencode-project-scaffold" >> README.md
  git add README.md
  git commit -m "chore: initial commit" --quiet
  ok "Git repository initialized"
fi

# --- Initialize codegraph ---
if [[ "$NO_CODEGRAPH" == true ]]; then
  warn "Skipping codegraph initialization (--no-codegraph)"
elif command -v codegraph &>/dev/null; then
  info "Initializing codegraph index..."
  if codegraph init 2>/dev/null; then
    ok "Codegraph initialized"
  else
    warn "codegraph init returned non-zero — you may need to run it manually"
  fi
else
  warn "codegraph not found in PATH — skipping (install it and run 'codegraph init' later)"
fi

# --- Create .opencode config ---
info "Creating .opencode/ config..."
mkdir -p .opencode
cat > .opencode/opencode.json << 'OPENCODE_CONFIG'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [],
  "mcp": {},
  "permission": {}
}
OPENCODE_CONFIG
ok "OpenCode config created"

# --- Print summary ---
echo ""
printf "%s%s🚀 Project '%s' created successfully!%s\n\n" "$GREEN" "$BOLD" "$PROJECT_NAME" "$RESET"
printf "  Location: %s\n" "$PROJECT_DIR"
echo ""
echo "  Next steps:"
echo "    cd ${PROJECT_DIR}"
echo "    opencode"
echo ""
