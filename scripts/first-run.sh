#!/usr/bin/env bash
set -euo pipefail

# first-run.sh — Container entrypoint
# Postinstall runs at build time. This just ensures config deps are installed
# on first start (in case the image was rebuilt without deps).

MARKER="/home/allen/.config/opencode/.initialized"

if [[ ! -f "$MARKER" ]]; then
    echo "🔧 First-run setup..."

    if [[ -f /home/allen/.config/opencode/package.json ]]; then
        echo "   Installing config dependencies..."
        cd /home/allen/.config/opencode
        pnpm install --no-frozen-lockfile --config.onlyBuiltDependencies=[] 2>&1 || true
    fi

    touch "$MARKER"
    echo "✅ Setup complete."
    echo ""
fi

cd /workspace
exec /usr/bin/bash
