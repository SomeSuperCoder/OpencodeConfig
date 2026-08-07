#!/usr/bin/env bash
set -euo pipefail

# first-run.sh — One-time setup on container start
# Handles postinstall scripts that pnpm skips, then drops into bash.

MARKER="/home/allen/.config/opencode/.initialized"

if [[ ! -f "$MARKER" ]]; then
    echo "🔧 First-run setup..."

    # Run opencode-ai postinstall (downloads the actual binary)
    OPENCODE_DIR="$(find /home/allen/.local/share/pnpm -path '*/opencode-ai/postinstall.mjs' -print -quit 2>/dev/null || true)"
    if [[ -n "$OPENCODE_DIR" ]]; then
        cd "$(dirname "$OPENCODE_DIR")"
        echo "   Running opencode-ai postinstall..."
        node postinstall.mjs
    fi

    # Install config dependencies
    if [[ -f /home/allen/.config/opencode/package.json ]]; then
        echo "   Installing config dependencies..."
        cd /home/allen/.config/opencode
        pnpm install --no-frozen-lockfile 2>&1 || npm install --no-audit --no-fund 2>&1 || true
    fi

    touch "$MARKER"
    echo "✅ Setup complete."
    echo ""
fi

cd /workspace
exec /usr/bin/bash
