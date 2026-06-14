#!/usr/bin/env bash
# scripts/agent.sh — local test helper
# Usage:
#   export ANTHROPIC_API_KEY="sk-ant-..."
#   USER_INPUT="What is our WiFi password?" ./scripts/agent.sh

set -euo pipefail

USER_INPUT="${USER_INPUT:-}"

if [ -z "$USER_INPUT" ]; then
  echo "Error: USER_INPUT is required" >&2
  echo "Usage: USER_INPUT='your question' ./scripts/agent.sh" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

echo "=== Running Claude agent (local test) ==="
echo "USER_INPUT: ${USER_INPUT}"
echo ""

load_dir() {
  find "$1" -name "*.md" 2>/dev/null | while read f; do
    echo "### $f"
    cat "$f"
    echo ""
  done
}

WIKI_CONTENT=$(load_dir "wiki/")

PROMPT="You are a family assistant. Use the knowledge base below as your primary source, then answer the user clearly and briefly in English. Use plain text only (no markdown).

=== Knowledge Base ===
${WIKI_CONTENT}
=== End ===

Question: ${USER_INPUT}"

claude -p "${PROMPT}" \
  --model claude-haiku-4-5-20251001 \
  --output-format json \
  | jq -r '.result // .content // .'
