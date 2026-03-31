#!/bin/bash
# =============================================================================
# AutoCode — Autonomous Coding Loop
# Usage: ./autocode.sh [repo-path] [spec-file] [--agent agent-name]
#
# Examples:
#   ./autocode.sh /path/to/myproject-core spec.md
#   ./autocode.sh /path/to/myproject-ai spec.md --agent backend-architect
#   ./autocode.sh . spec.md --max-retries 5 --max-cost 10
#   ./autocode.sh . program.md --mode program --metric "npm test -- --coverage"
#   ./autocode.sh . spec.md --strategy plansearch --candidates 3
#   ./autocode.sh . spec.md --strategy resilient
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
INPUT_MODE="${INPUT_MODE:-spec}"
METRIC_CMD="${METRIC_CMD:-}"
METRIC_DIRECTION="${METRIC_DIRECTION:-lower_is_better}"
MAX_TIME_PER_ITERATION="${MAX_TIME_PER_ITERATION:-300}"
STRATEGY="${DEFAULT_STRATEGY:-standard}"
CANDIDATES="${CANDIDATES:-1}"
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
    --mode) INPUT_MODE="$2"; shift 2 ;;
    --metric) METRIC_CMD="$2"; shift 2 ;;
    --metric-direction) METRIC_DIRECTION="$2"; shift 2 ;;
    --time-budget) MAX_TIME_PER_ITERATION="$2"; shift 2 ;;
    --strategy) STRATEGY="$2"; shift 2 ;;
    --candidates) CANDIDATES="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# --- Auto-detect input mode from file name ---
if [[ "$SPEC_FILE" == *"program"* ]] && [ "$INPUT_MODE" = "spec" ]; then
  INPUT_MODE="program"
fi

# --- Strategy implies settings ---
case "$STRATEGY" in
  plansearch)
    [ "$CANDIDATES" -eq 1 ] && CANDIDATES=3
    ;;
  resilient)
    [ "$CANDIDATES" -eq 1 ] && CANDIDATES=3
    ;;
  explore)
    INPUT_MODE="program"
    ;;
esac

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
INPUT_CONTENT=$(cat "$REPO_PATH/$SPEC_FILE")

# --- Build metric instructions ---
METRIC_INSTRUCTIONS=""
if [ -n "$METRIC_CMD" ]; then
  METRIC_INSTRUCTIONS="$(cat <<METRIC_EOF

## METRIC-DRIVEN KEEP/DISCARD (Autoresearch Pattern)

After EACH code change, run the metric command and compare against the previous value:

**Metric command:** \`$METRIC_CMD\`
**Direction:** $METRIC_DIRECTION

### Keep/Discard Protocol:
1. Before making changes, run the metric command and record the BASELINE value
2. Make your code changes
3. Run the metric command again to get the NEW value
4. Compare:
   - If metric IMPROVED (${METRIC_DIRECTION}): **KEEP** changes, commit checkpoint, update baseline
   - If metric WORSENED: **DISCARD** changes immediately with \`git checkout -- .\` and try a different approach
   - If metric is UNCHANGED: keep changes only if they improve code quality
5. Log each iteration: \`echo "[iteration N] baseline=X new=Y decision=KEEP/DISCARD" >> .autocode-state/metric-log.txt\`

**CRITICAL: Never keep a change that worsens the metric. Try at least 3 different approaches before giving up on an improvement.**
METRIC_EOF
)"
fi

# --- Build time budget instructions ---
TIME_INSTRUCTIONS=""
if [ "$MAX_TIME_PER_ITERATION" -gt 0 ] 2>/dev/null; then
  TIME_INSTRUCTIONS="
## TIME BUDGET

Each iteration (analyze → code → test → evaluate) must complete within **${MAX_TIME_PER_ITERATION} seconds**.
- If a test/build/metric command runs longer than this, kill it and move on
- Use \`timeout ${MAX_TIME_PER_ITERATION}\` prefix for long-running commands
- Prioritize fast feedback: prefer unit tests over integration tests within time budget"
fi

# --- Build PlanSearch instructions (ATLAS Pattern) ---
PLANSEARCH_INSTRUCTIONS=""
if [ "$CANDIDATES" -gt 1 ]; then
  PLANSEARCH_INSTRUCTIONS="
## PLANSEARCH — Multi-Candidate Planning (ATLAS Pattern)

**Before writing ANY code**, generate ${CANDIDATES} DIFFERENT solution plans:

### For each plan, document in \`.autocode-state/plans/\`:
1. **Approach**: High-level strategy (1-2 sentences)
2. **Trade-offs**: What this approach gains vs. what it sacrifices
3. **Complexity**: Estimated number of files/functions to change
4. **Risk**: What could go wrong (low/medium/high)

### Selection protocol:
1. Score each plan on 3 axes (1-5 scale):
   - **Correctness likelihood**: How confident are you this will pass all tests?
   - **Simplicity**: How minimal is the change?
   - **Performance**: Will this scale well?
2. Pick the plan with the highest total score
3. Log your selection rationale in \`.autocode-state/plans/selection.md\`
4. Implement ONLY the winning plan

### If the winning plan fails after 2 attempts:
- Do NOT patch it blindly
- Switch to the next-highest-scoring plan
- Log: \"Plan A failed because [reason], switching to Plan B\"

**CRITICAL: Generate plans BEFORE touching any code. Plans must be meaningfully different approaches, not variations of the same idea.**"
fi

# --- Build PR-CoT instructions (ATLAS Pattern) ---
PRCOT_INSTRUCTIONS=""
if [ "$STRATEGY" = "resilient" ]; then
  PRCOT_INSTRUCTIONS="
## PR-CoT — Plan-Repair Chain of Thought (ATLAS Pattern)

**Activated automatically when you fail 2+ times on the same issue.**

When normal fix-and-retry isn't working, STOP and switch to structured repair:

### Step A: DIAGNOSE (don't fix yet)
Write your OWN test cases for the failing module — independent of existing tests.
Run them to isolate the exact failure point.

### Step B: MULTI-PERSPECTIVE ANALYSIS
Analyze the failure from exactly 3 angles:
1. **Logic error**: Is the algorithm/business logic correct? Trace the data flow manually.
2. **Integration error**: Are the interfaces, types, or contracts between modules wrong?
3. **Assumption error**: Am I misunderstanding the requirement or the existing code?

For each perspective, write a 1-sentence hypothesis in \`.autocode-state/repair-log.md\`.

### Step C: TARGETED FIX
- Test the most likely hypothesis FIRST (don't shotgun)
- If hypothesis confirmed → fix it
- If hypothesis rejected → try next perspective

### Step D: APPROACH PIVOT
If ALL 3 perspectives fail to identify the issue:
- The current approach is fundamentally wrong
- \`git checkout -- .\` to discard ALL changes from this attempt
- Start fresh with a COMPLETELY different approach
- Log: \"Pivoting: original approach [X] failed because [reason], new approach: [Y]\"

**CRITICAL: PR-CoT is about understanding WHY you're failing, not trying harder at the same thing.**"
fi

if [ "$INPUT_MODE" = "program" ]; then
  # --- Program mode (exploratory, Karpathy-style) ---
  AUTONOMOUS_PROMPT="$(cat <<'PROMPT_EOF'
# AUTONOMOUS EXPLORATION MODE — DO NOT ASK FOR PERMISSION

You are operating in FULLY AUTONOMOUS **exploration mode**. You have a research direction (program.md) instead of a strict spec. Your goal is to iteratively improve the codebase through experimentation.

## YOUR LOOP (repeat until satisfied or max iterations reached):

### Step 1: READ DIRECTION
- Read program.md for the research direction and goals
- Understand what aspects to explore/optimize
- Read existing code to understand the current state

### Step 2: HYPOTHESIZE
- Form a specific hypothesis about what change could improve the system
- Keep changes small and focused — ONE idea per iteration
- Document your hypothesis in .autocode-state/notepad.md

### Step 3: IMPLEMENT
- Make the minimal code change to test your hypothesis
- Follow existing patterns in the repo

### Step 4: MEASURE
- Run tests to ensure nothing is broken
- Run the metric command if specified (see METRIC section below)
- Compare results against baseline

### Step 5: DECIDE (Keep or Discard)
- If improvement confirmed → KEEP changes, checkpoint commit with descriptive message
- If no improvement or regression → DISCARD with `git checkout -- .`
- Log the result in .autocode-state/experiment-log.md:
  ```
  ## Iteration N — [KEEP/DISCARD]
  **Hypothesis:** ...
  **Change:** ...
  **Result:** baseline=X → new=Y
  ```

### Step 6: ITERATE
- If max retries (MAX_RETRIES_PLACEHOLDER) reached → stop and summarize findings
- Otherwise → go back to Step 2 with new hypothesis informed by previous results
- Print "AUTOCODE COMPLETE" when done

## CRITICAL RULES:
- NEVER stop to ask me questions — make reasonable decisions
- ONE change per iteration — keep experiments isolated
- ALWAYS measure before and after
- NEVER keep a change that breaks existing tests
- Checkpoint commit after each KEPT change
- Document ALL experiments (including discarded ones) in experiment-log.md

## PROGRAM (Research Direction):
PROMPT_EOF
)"
else
  # --- Spec mode (standard, strict requirements) ---
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
fi

# Replace placeholder
AUTONOMOUS_PROMPT="${AUTONOMOUS_PROMPT//MAX_RETRIES_PLACEHOLDER/$MAX_RETRIES}"

# Append all instruction sections
AUTONOMOUS_PROMPT="$AUTONOMOUS_PROMPT

$INPUT_CONTENT
$PLANSEARCH_INSTRUCTIONS
$PRCOT_INSTRUCTIONS
$METRIC_INSTRUCTIONS
$TIME_INSTRUCTIONS"

# --- Execute ---
log "${BLUE}========================================${NC}"
log "${BLUE}  $PROJECT_NAME AutoCode v2.0${NC}"
log "${BLUE}========================================${NC}"
log "  Repo:        $REPO_PATH"
log "  Input:       $SPEC_FILE (mode: $INPUT_MODE)"
log "  Strategy:    $STRATEGY (candidates: $CANDIDATES)"
log "  Agent:       $AGENT_NAME"
log "  Model:       $MODEL_TIER ($MODEL_ID)"
log "  State:       $SPEC_STATE_DIR"
log "  Max retries: $MAX_RETRIES"
log "  Max cost:    \$$MAX_COST_USD"
log "  Time budget: ${MAX_TIME_PER_ITERATION}s per iteration"
if [ -n "$METRIC_CMD" ]; then
log "  Metric:      $METRIC_CMD ($METRIC_DIRECTION)"
fi
log "  Log file:    $LOG_FILE"
log "  Started:     $(date)"
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
