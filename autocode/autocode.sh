#!/bin/bash
# =============================================================================
# AutoCode — Autonomous Coding Loop
# Usage: ./autocode.sh [repo-path] [spec-file] [--agent agent-name]
#
# Examples:
#   ./autocode.sh /path/to/myproject-core spec.md
#   ./autocode.sh /path/to/myproject-ai spec.md --agent backend-architect
#   ./autocode.sh . spec.md --max-retries 5 --max-cost 10
# =============================================================================

set -euo pipefail

# --- Load configuration ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/autocode.config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi
PROJECT_NAME="${PROJECT_NAME:-MyProject}"
PROJECT_ROOT="${PROJECT_ROOT:-$(dirname "$SCRIPT_DIR")}"

# --- Configuration ---
REPO_PATH="${1:-.}"
SPEC_FILE="${2:-spec.md}"
AGENT_NAME="${DEFAULT_AGENT:-engineering-senior-developer}"
MAX_RETRIES="${MAX_RETRIES:-10}"
MAX_COST_USD="${MAX_COST_USD:-10}"
MAX_TURNS="${MAX_TURNS:-200}"
SKILLS_DIR="$HOME/.claude/skills/agency-agents/agents"
LOG_DIR="$REPO_PATH/.autocode-logs"
STATE_DIR="${STATE_DIR:-.autocode-state}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MODEL_OVERRIDE=""

# --- Parse optional args ---
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case $1 in
    --agent) AGENT_NAME="$2"; shift 2 ;;
    --max-retries) MAX_RETRIES="$2"; shift 2 ;;
    --max-cost) MAX_COST_USD="$2"; shift 2 ;;
    --model) MODEL_OVERRIDE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Validate ---
if [ ! -f "$REPO_PATH/$SPEC_FILE" ]; then
  echo -e "${RED}ERROR: Spec file not found: $REPO_PATH/$SPEC_FILE${NC}"
  echo "Usage: ./autocode.sh [repo-path] [spec-file]"
  exit 1
fi

# --- Setup logging ---
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/autocode_${TIMESTAMP}.log"

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# --- Load agent system prompt ---
SYSTEM_PROMPT=""
for dir in "engineering" "testing" "specialized"; do
  AGENT_FILE="$SKILLS_DIR/$dir/$AGENT_NAME.md"
  if [ -f "$AGENT_FILE" ]; then
    SYSTEM_PROMPT=$(cat "$AGENT_FILE")
    log "${GREEN}[AGENT] Loaded: $AGENT_FILE${NC}"
    break
  fi
done

if [ -z "$SYSTEM_PROMPT" ]; then
  log "${YELLOW}[WARN] Agent '$AGENT_NAME' not found, using default prompt${NC}"
  SYSTEM_PROMPT="You are a senior software engineer. Write production-quality code."
fi

# --- Model routing (read from skill frontmatter or override) ---
if [ -n "$MODEL_OVERRIDE" ]; then
  MODEL_TIER="$MODEL_OVERRIDE"
elif [ -n "$AGENT_FILE" ] && [ -f "$AGENT_FILE" ]; then
  MODEL_TIER=$(grep '^model:' "$AGENT_FILE" | awk '{print $2}' | tr -d '[:space:]')
fi
MODEL_TIER="${MODEL_TIER:-sonnet}"

case "$MODEL_TIER" in
  haiku)  MODEL_ID="claude-haiku-4-5-20251001" ;;
  opus)   MODEL_ID="claude-opus-4-6" ;;
  sonnet) MODEL_ID="claude-sonnet-4-6" ;;
  *)      MODEL_ID="claude-sonnet-4-6" ;;
esac
log "${GREEN}[MODEL] $MODEL_TIER → $MODEL_ID${NC}"

# --- State management (resume support) ---
SPEC_BASENAME=$(basename "$SPEC_FILE" .md)
SPEC_STATE_DIR="$REPO_PATH/$STATE_DIR/$SPEC_BASENAME"
mkdir -p "$SPEC_STATE_DIR"
NOTEPAD_FILE="$SPEC_STATE_DIR/notepad.md"
PHASE_LOG="$SPEC_STATE_DIR/phase-log.json"
ERROR_LOG="$SPEC_STATE_DIR/errors.log"

if [ -f "$PHASE_LOG" ]; then
  log "${YELLOW}[RESUME] Found previous state in $SPEC_STATE_DIR${NC}"
  log "${YELLOW}[RESUME] Previous phases: $(cat "$PHASE_LOG")${NC}"
fi

# Initialize phase log if not exists
if [ ! -f "$PHASE_LOG" ]; then
  echo '{"started":"'"$(date -Iseconds)"'","phases":[]}' > "$PHASE_LOG"
fi

# --- Build the autonomous prompt ---
SPEC_CONTENT=$(cat "$REPO_PATH/$SPEC_FILE")

AUTONOMOUS_PROMPT="$(cat <<'PROMPT_EOF'
# AUTONOMOUS CODING MODE — DO NOT ASK FOR PERMISSION

You are operating in FULLY AUTONOMOUS mode. Read the spec below and execute the complete coding loop WITHOUT stopping to ask questions.

## YOUR LOOP (repeat until all tests PASS):

### Step 1: ANALYZE
- Read the spec carefully
- Identify all modules, files, and tests needed
- Read existing code in the repo to understand patterns

### Step 2: CODE
- Write ALL code specified in the spec
- Follow existing patterns in the repo
- Use proper error handling, logging, types

### Step 3: TEST
- Write unit tests for EVERY business rule in the spec
- Run the test command specified in the DoD section
- Capture the full output

### Step 4: EVALUATE
- If ALL tests PASS (exit code 0) → go to Step 5
- If ANY test FAILS → read the error, fix the code, go back to Step 3
- Maximum retries: MAX_RETRIES_PLACEHOLDER

### Step 5: LINT & BUILD
- Run lint command from DoD
- Run build command from DoD
- If either fails → fix and retry

### Step 6: COMMIT
- git add only the files you created/modified
- git commit with descriptive message
- Print "AUTOCODE COMPLETE" as the final output

## CRITICAL RULES:
- NEVER stop to ask me questions — make reasonable decisions
- NEVER skip writing tests — every business rule needs a test
- If a dependency is missing, install it
- If you can't figure something out after 3 attempts, log it and move on
- Commit after EACH module succeeds (checkpoint commits)
- Use structured JSON logging (slog for Go, tracing for Rust, pino for TS)

## SPEC:
PROMPT_EOF
)"

# Replace placeholder
AUTONOMOUS_PROMPT="${AUTONOMOUS_PROMPT//MAX_RETRIES_PLACEHOLDER/$MAX_RETRIES}"

# Append the actual spec
AUTONOMOUS_PROMPT="$AUTONOMOUS_PROMPT

$SPEC_CONTENT"

# --- Execute ---
log "${BLUE}========================================${NC}"
log "${BLUE}  $PROJECT_NAME AutoCode v1.0${NC}"
log "${BLUE}========================================${NC}"
log "  Repo:       $REPO_PATH"
log "  Spec:       $SPEC_FILE"
log "  Agent:      $AGENT_NAME"
log "  Model:      $MODEL_TIER ($MODEL_ID)"
log "  State:      $SPEC_STATE_DIR"
log "  Max retries: $MAX_RETRIES"
log "  Max cost:   \$$MAX_COST_USD"
log "  Log file:   $LOG_FILE"
log "  Started:    $(date)"
log "${BLUE}========================================${NC}"
log ""
log "${YELLOW}[START] Launching Claude Code in autonomous mode...${NC}"
log ""

# --- Run Claude Code ---
cd "$REPO_PATH"

claude \
  --print \
  --model "$MODEL_ID" \
  --dangerously-skip-permissions \
  --max-turns "$MAX_TURNS" \
  --system-prompt "$SYSTEM_PROMPT" \
  "$AUTONOMOUS_PROMPT" \
  2>&1 | tee -a "$LOG_FILE"

EXIT_CODE=$?

log ""
log "${BLUE}========================================${NC}"
if [ $EXIT_CODE -eq 0 ]; then
  log "${GREEN}[DONE] AutoCode completed successfully${NC}"
  # Update phase log and cleanup state on success
  echo '{"started":"'"$(cat "$PHASE_LOG" | grep -o '"started":"[^"]*"' | head -1 | cut -d'"' -f4)"'","completed":"'"$(date -Iseconds)"'","status":"success"}' > "$PHASE_LOG"
else
  log "${RED}[FAIL] AutoCode exited with code $EXIT_CODE${NC}"
  echo "[$(date -Iseconds)] Exit code: $EXIT_CODE" >> "$ERROR_LOG"
fi
log "  Finished: $(date)"
log "  Log: $LOG_FILE"
log "${BLUE}========================================${NC}"

exit $EXIT_CODE
