#!/usr/bin/env bash
# scripts/agent.sh — 本地測試用
# 用法：
#   export ANTHROPIC_API_KEY="sk-ant-..."
#   USER_INPUT="WiFi 密碼是什麼？" ./scripts/agent.sh

set -euo pipefail

USER_INPUT="${USER_INPUT:-}"

if [ -z "$USER_INPUT" ]; then
  echo "Error: USER_INPUT is required" >&2
  echo "Usage: USER_INPUT='你的問題' ./scripts/agent.sh" >&2
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

PROMPT="你是家族智慧助手。以下是知識庫內容，請根據這些資料加上自身知識回答問題。用繁體中文簡潔回答，必要時可到150字。純文字，不使用 markdown 符號。

=== 知識庫 ===
${WIKI_CONTENT}
=== 結束 ===

問題：${USER_INPUT}"

claude -p "${PROMPT}" \
  --model claude-haiku-4-5-20251001 \
  --output-format json \
  | jq -r '.result // .content // .'
