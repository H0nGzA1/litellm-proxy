#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-4000}"

if [ ! -f "$SCRIPT_DIR/.venv/Scripts/activate" ]; then
    echo "Virtual environment not found. Run: uv venv && uv pip install litellm[proxy]"
    exit 1
fi

source "$SCRIPT_DIR/.venv/Scripts/activate"

echo "Config: $SCRIPT_DIR/litellm_config.yaml"
echo "Proxy:  http://localhost:$PORT"
echo "Master key: sk-proxy-master-key"
echo ""

litellm --config "$SCRIPT_DIR/litellm_config.yaml" --port "$PORT"
