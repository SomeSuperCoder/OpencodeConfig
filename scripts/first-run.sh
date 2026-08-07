#!/usr/bin/env bash
set -euo pipefail

# first-run.sh — Container entrypoint
# Handles first-run setup, then drops into bash.

MARKER="/home/allen/.config/opencode/.initialized"

if [[ ! -f "$MARKER" ]]; then
    echo "🔧 First-run setup..."

    if [[ -f /home/allen/.config/opencode/package.json ]]; then
        echo "   Installing config dependencies..."
        cd /home/allen/.config/opencode
        pnpm install --no-frozen-lockfile 2>&1 || true
    fi

    touch "$MARKER"
    echo "✅ Setup complete."
    echo ""
fi

cd /workspace
exec /usr/bin/bash
