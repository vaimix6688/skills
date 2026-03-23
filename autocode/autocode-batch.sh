#!/bin/bash
# =============================================================================
# AutoCode Batch — Run multiple specs sequentially
# Usage: ./autocode-batch.sh [specs-dir]
#
# Reads all *.spec.md files in the directory and runs them in order.
# Each spec should have a "Repo:" header to indicate which repo to target.
# =============================================================================

set -uo pipefail

# --- Load configuration ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/autocode.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
PROJECT_NAME="${PROJECT_NAME:-MyProject}"
PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$SCRIPT_DIR")}"
MAX_TURNS="${MAX_TURNS:-200}"

SPECS_DIR="${1:-.}"
LOG_DIR="${PROJECT_ROOT}/${PROJECT_NAME}-docs/.autocode-logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SUMMARY_LOG="$LOG_DIR/batch_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  $PROJECT_NAME AutoCode Batch Runner${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

TOTAL=0
PASSED=0
FAILED=0
SPECS=()

# Find all spec files
for spec in "$SPECS_DIR"/*.spec.md "$SPECS_DIR"/*-spec.md "$SPECS_DIR"/spec.md; do
  [ -f "$spec" ] && SPECS+=("$spec")
done

if [ ${#SPECS[@]} -eq 0 ]; then
  echo -e "${RED}No spec files found in $SPECS_DIR${NC}"
  echo "Expected: *.spec.md or *-spec.md files"
  exit 1
fi

echo "Found ${#SPECS[@]} spec(s):"
for spec in "${SPECS[@]}"; do
  echo "  - $(basename "$spec")"
done
echo ""

# Process each spec
for spec in "${SPECS[@]}"; do
  TOTAL=$((TOTAL + 1))
  SPEC_NAME=$(basename "$spec" .md)

  # Extract repo from spec (look for "Repo:" line)
  REPO=$(grep -i "^[*\-] *Repo:" "$spec" 2>/dev/null | head -1 | sed 's/.*`\(.*\)`.*/\1/' || echo "")
  if [ -z "$REPO" ]; then
    REPO=$(grep -i "Repo.*:" "$spec" 2>/dev/null | head -1 | grep -oP '\w+-\w+' | head -1 || echo "${PROJECT_NAME}-core")
  fi
  REPO_PATH="$PROJECT_ROOT/$REPO"

  echo -e "${YELLOW}[$TOTAL/${#SPECS[@]}] Processing: $SPEC_NAME${NC}"
  echo "  Repo: $REPO_PATH"

  if [ ! -d "$REPO_PATH" ]; then
    echo -e "${RED}  ERROR: Repo not found: $REPO_PATH${NC}"
    FAILED=$((FAILED + 1))
    echo "FAIL: $SPEC_NAME (repo not found)" >> "$SUMMARY_LOG"
    continue
  fi

  # Copy spec to repo
  cp "$spec" "$REPO_PATH/spec.md"

  # Run autocode
  cd "$REPO_PATH"
  SPEC_CONTENT=$(cat spec.md)

  claude \
    --print \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    "AUTONOMOUS MODE. Read spec.md, code, test, fix, commit. No questions.

SPEC:
$SPEC_CONTENT" \
    >> "$LOG_DIR/${SPEC_NAME}_${TIMESTAMP}.log" 2>&1

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}  PASSED${NC}"
    PASSED=$((PASSED + 1))
    echo "PASS: $SPEC_NAME" >> "$SUMMARY_LOG"
  else
    echo -e "${RED}  FAILED${NC}"
    FAILED=$((FAILED + 1))
    echo "FAIL: $SPEC_NAME" >> "$SUMMARY_LOG"
  fi

  # Cleanup
  rm -f "$REPO_PATH/spec.md"
  echo ""
done

# Summary
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  BATCH SUMMARY${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "  Total:  $TOTAL"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo -e "  Log:    $SUMMARY_LOG"
echo -e "${BLUE}================================================${NC}"

[ $FAILED -eq 0 ] && exit 0 || exit 1
