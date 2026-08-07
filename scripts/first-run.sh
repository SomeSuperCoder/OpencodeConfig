#!/usr/bin/env bash
set -euo pipefail

# first-run.sh — Container entrypoint
# Starts agentmemory server, handles first-run setup, then drops into bash.

MARKER="/home/allen/.config/opencode/.initialized"

# Start agentmemory iii-engine server in background (if not already running)
if ! curl -sf http://localhost:3111/agentmemory/health >/dev/null 2>&1; then
    echo "🧠 Starting agentmemory server..."
    CI=true nohup agentmemory >/dev/null 2>&1 &
    # Wait for server to be ready
    for i in $(seq 1 10); do
        if curl -sf http://localhost:3111/agentmemory/health >/dev/null 2>&1; then
            echo "   ✅ agentmemory server ready"
            break
        fi
        sleep 1
    done
fi

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
