#!/bin/bash
# =============================================================================
# AutoCode for VSCode — Runs inside VSCode terminal
# Use when you want to run autocode directly in VSCode instead of a separate terminal.
#
# Usage: bash autocode-vscode.sh [spec-file]
# =============================================================================

# --- Load configuration ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/autocode.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
PROJECT_NAME="${PROJECT_NAME:-MyProject}"
MAX_TURNS="${MAX_TURNS:-200}"

SPEC_FILE="${1:-spec.md}"

if [ ! -f "$SPEC_FILE" ]; then
  echo "ERROR: $SPEC_FILE not found in current directory"
  echo "Usage: bash autocode-vscode.sh [spec-file]"
  exit 1
fi

SPEC_CONTENT=$(cat "$SPEC_FILE")

echo "================================================"
echo "  $PROJECT_NAME AutoCode (VSCode Mode)"
echo "  Spec: $SPEC_FILE"
echo "  Dir:  $(pwd)"
echo "  Time: $(date)"
echo "================================================"
echo ""
echo "Launching Claude Code..."
echo ""

claude \
  --print \
  --dangerously-skip-permissions \
  --max-turns "$MAX_TURNS" \
  "You are in AUTONOMOUS mode. Read the spec below and proceed automatically:
1. Write code for ALL modules
2. Write unit tests for EVERY business rule
3. Run tests — if FAIL, read error, fix code, retry
4. Run lint + build
5. When ALL PASS -> git add + git commit
6. Do NOT stop to ask questions. Make your own decisions.
7. Commit checkpoints after each module succeeds.

SPEC:
$SPEC_CONTENT"
