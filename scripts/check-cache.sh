#!/usr/bin/env bash
# Check the Raysurfer cache for code matching the current task.
# Reads hook input JSON from stdin and queries the search API.
# Returns additional context to Claude via stdout JSON if a match is found.

set -euo pipefail

if [ -z "${RAYSURFER_API_KEY:-}" ]; then
  exit 0
fi

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty' 2>/dev/null || true)

if [ -z "$TOOL_INPUT" ]; then
  exit 0
fi

TASK=""
if [ "$TOOL_NAME" = "Write" ]; then
  TASK=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null || true)
elif [ "$TOOL_NAME" = "Bash" ]; then
  TASK=$(echo "$TOOL_INPUT" | jq -r '.command // empty' 2>/dev/null || true)
fi

if [ -z "$TASK" ]; then
  exit 0
fi

TASK_ESCAPED=$(echo "$TASK" | head -c 500 | jq -Rs '.')

RESPONSE=$(curl -s --max-time 5 -X POST https://api.raysurfer.com/api/retrieve/search \
  -H "Authorization: Bearer $RAYSURFER_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"task\": $TASK_ESCAPED, \"top_k\": 3, \"min_verdict_score\": 0.3}" 2>/dev/null || true)

if [ -z "$RESPONSE" ]; then
  exit 0
fi

TOTAL_FOUND=$(echo "$RESPONSE" | jq -r '.total_found // 0' 2>/dev/null || echo "0")
TOP_SCORE=$(echo "$RESPONSE" | jq -r '.matches[0].combined_score // 0' 2>/dev/null || echo "0")

if [ "$TOTAL_FOUND" -gt 0 ] 2>/dev/null; then
  HAS_GOOD_MATCH=$(echo "$TOP_SCORE > 0.5" | bc -l 2>/dev/null || echo "0")
  if [ "${HAS_GOOD_MATCH:-0}" = "1" ]; then
    TOP_NAME=$(echo "$RESPONSE" | jq -r '.matches[0].code_block.name // "unknown"' 2>/dev/null || echo "unknown")
    TOP_ID=$(echo "$RESPONSE" | jq -r '.matches[0].code_block.id // ""' 2>/dev/null || echo "")
    echo "{\"additionalContext\": \"Raysurfer cache hit: '${TOP_NAME}' (score: ${TOP_SCORE}, id: ${TOP_ID}). Consider using /raysurfer to retrieve cached code before generating new code.\"}"
    exit 0
  fi
fi

exit 0
