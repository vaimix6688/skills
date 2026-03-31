# =============================================================================
# AutoCode — PowerShell (Windows)
# Usage: .\autocode.ps1 [spec-file] [-Strategy plansearch] [-Candidates 3]
# Examples:
#   .\autocode.ps1 spec.md
#   .\autocode.ps1 spec.md -Strategy plansearch -Candidates 3
#   .\autocode.ps1 spec.md -Strategy resilient
#   .\autocode.ps1 program.md -Strategy explore -Metric "npm run bench"
# =============================================================================

param(
    [string]$SpecFile = "spec.md",
    [string]$Agent = "",
    [string]$Model = "",
    [string]$Mode = "",
    [string]$Strategy = "",
    [int]$Candidates = 0,
    [string]$Metric = "",
    [string]$MetricDirection = "",
    [int]$TimeBudget = 0,
    [int]$MaxTurns = 0,
    [int]$MaxRetries = 0
)

$ErrorActionPreference = "Stop"

# --- Load configuration ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "autocode.config"
$ProjectName = "MyProject"
$ProjectRoot = Split-Path -Parent $ScriptDir

if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#")) {
            $parts = $line -split "=", 2
            if ($parts.Count -eq 2) {
                $key = $parts[0].Trim()
                $val = $parts[1].Trim()
                switch ($key) {
                    "PROJECT_NAME"         { $ProjectName = $val }
                    "PROJECT_ROOT"         { $ProjectRoot = $val }
                    "MAX_TURNS"            { if ($MaxTurns -eq 0) { $MaxTurns = [int]$val } }
                    "MAX_RETRIES"          { if ($MaxRetries -eq 0) { $MaxRetries = [int]$val } }
                    "INPUT_MODE"           { if (-not $Mode) { $Mode = $val } }
                    "METRIC_CMD"           { if (-not $Metric) { $Metric = $val } }
                    "METRIC_DIRECTION"     { if (-not $MetricDirection) { $MetricDirection = $val } }
                    "MAX_TIME_PER_ITERATION" { if ($TimeBudget -eq 0) { $TimeBudget = [int]$val } }
                    "DEFAULT_STRATEGY"     { if (-not $Strategy) { $Strategy = $val } }
                    "CANDIDATES"           { if ($Candidates -eq 0) { $Candidates = [int]$val } }
                }
            }
        }
    }
}

if ($MaxTurns -eq 0) { $MaxTurns = 200 }
if ($MaxRetries -eq 0) { $MaxRetries = 10 }
if ($TimeBudget -eq 0) { $TimeBudget = 300 }
if (-not $Mode) { $Mode = "spec" }
if (-not $MetricDirection) { $MetricDirection = "lower_is_better" }
if (-not $Strategy) { $Strategy = "standard" }
if ($Candidates -eq 0) { $Candidates = 1 }

# Auto-detect mode from filename
if ($SpecFile -match "program" -and $Mode -eq "spec") { $Mode = "program" }

# Strategy implies settings
switch ($Strategy) {
    "plansearch" { if ($Candidates -eq 1) { $Candidates = 3 } }
    "resilient"  { if ($Candidates -eq 1) { $Candidates = 3 } }
    "explore"    { $Mode = "program" }
}

# --- Model routing ---
$DefaultAgent = "engineering-senior-developer"
$AgentName = if ($Agent) { $Agent } else { $DefaultAgent }
$SkillsDirs = @("$env:USERPROFILE\.claude\skills", "$ScriptDir\..\.claude\skills")
$AgentFile = ""
$ModelTier = "sonnet"

foreach ($dir in $SkillsDirs) {
    $candidate = Join-Path $dir "$AgentName.md"
    if (Test-Path $candidate) {
        $AgentFile = $candidate
        break
    }
}

if ($Model) {
    $ModelTier = $Model
} elseif ($AgentFile -and (Test-Path $AgentFile)) {
    $modelLine = Get-Content $AgentFile | Where-Object { $_ -match '^model:\s*' } | Select-Object -First 1
    if ($modelLine) {
        $ModelTier = ($modelLine -replace '^model:\s*', '').Trim()
    }
}

$ModelId = switch ($ModelTier) {
    "haiku"  { "claude-haiku-4-5-20251001" }
    "opus"   { "claude-opus-4-6" }
    "sonnet" { "claude-sonnet-4-6" }
    default  { "claude-sonnet-4-6" }
}

# --- State management ---
$StateDir = ".autocode-state"
$SpecBaseName = [System.IO.Path]::GetFileNameWithoutExtension($SpecFile)
$SpecStateDir = Join-Path (Get-Location) "$StateDir\$SpecBaseName"
if (-not (Test-Path $SpecStateDir)) { New-Item -ItemType Directory -Path $SpecStateDir -Force | Out-Null }
$PhaseLog = Join-Path $SpecStateDir "phase-log.json"
$ErrorLog = Join-Path $SpecStateDir "errors.log"

if (Test-Path $PhaseLog) {
    Write-Host "[RESUME] Found previous state in $SpecStateDir" -ForegroundColor Yellow
}
if (-not (Test-Path $PhaseLog)) {
    @{started=(Get-Date -Format "o"); phases=@()} | ConvertTo-Json | Set-Content $PhaseLog
}

if (-not (Test-Path $SpecFile)) {
    Write-Host "ERROR: $SpecFile not found in $(Get-Location)" -ForegroundColor Red
    Write-Host "Usage: .\autocode.ps1 [spec-file]"
    exit 1
}

$SpecContent = Get-Content $SpecFile -Raw

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  $ProjectName AutoCode (PowerShell)" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Input:       $SpecFile (mode: $Mode)"
Write-Host "  Strategy:    $Strategy (candidates: $Candidates)"
Write-Host "  Agent:       $AgentName"
Write-Host "  Model:       $ModelTier ($ModelId)"
Write-Host "  Dir:         $(Get-Location)"
Write-Host "  State:       $SpecStateDir"
Write-Host "  Time budget: ${TimeBudget}s per iteration"
if ($Metric) { Write-Host "  Metric:      $Metric ($MetricDirection)" }
Write-Host "  Time:        $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "  Max:         $MaxTurns turns, $MaxRetries retries"
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Launching Claude Code in autonomous mode..." -ForegroundColor Yellow
Write-Host ""

# --- Build PlanSearch instructions (ATLAS Pattern) ---
$PlanSearchInstructions = ""
if ($Candidates -gt 1) {
    $PlanSearchInstructions = @"

## PLANSEARCH — Multi-Candidate Planning (ATLAS Pattern)

**Before writing ANY code**, generate $Candidates DIFFERENT solution plans:

### For each plan, document in ``.autocode-state/plans/``:
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
3. Log your selection rationale in ``.autocode-state/plans/selection.md``
4. Implement ONLY the winning plan

### If the winning plan fails after 2 attempts:
- Do NOT patch it blindly
- Switch to the next-highest-scoring plan
- Log: "Plan A failed because [reason], switching to Plan B"

**CRITICAL: Generate plans BEFORE touching any code. Plans must be meaningfully different approaches, not variations of the same idea.**
"@
}

# --- Build PR-CoT instructions (ATLAS Pattern) ---
$PRCoTInstructions = ""
if ($Strategy -eq "resilient") {
    $PRCoTInstructions = @"

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

For each perspective, write a 1-sentence hypothesis in ``.autocode-state/repair-log.md``.

### Step C: TARGETED FIX
- Test the most likely hypothesis FIRST (don't shotgun)
- If hypothesis confirmed -> fix it
- If hypothesis rejected -> try next perspective

### Step D: APPROACH PIVOT
If ALL 3 perspectives fail to identify the issue:
- The current approach is fundamentally wrong
- ``git checkout -- .`` to discard ALL changes from this attempt
- Start fresh with a COMPLETELY different approach
- Log: "Pivoting: original approach [X] failed because [reason], new approach: [Y]"

**CRITICAL: PR-CoT is about understanding WHY you're failing, not trying harder at the same thing.**
"@
}

# --- Build metric instructions ---
$MetricInstructions = ""
if ($Metric) {
    $MetricInstructions = @"

## METRIC-DRIVEN KEEP/DISCARD (Autoresearch Pattern)

After EACH code change, run the metric command and compare against the previous value:

**Metric command:** ``$Metric``
**Direction:** $MetricDirection

### Keep/Discard Protocol:
1. Before making changes, run the metric command and record the BASELINE value
2. Make your code changes
3. Run the metric command again to get the NEW value
4. Compare:
   - If metric IMPROVED ($MetricDirection): **KEEP** changes, commit checkpoint, update baseline
   - If metric WORSENED: **DISCARD** changes immediately with ``git checkout -- .`` and try a different approach
   - If metric is UNCHANGED: keep changes only if they improve code quality
5. Log each iteration: ``echo "[iteration N] baseline=X new=Y decision=KEEP/DISCARD" >> .autocode-state/metric-log.txt``

**CRITICAL: Never keep a change that worsens the metric. Try at least 3 different approaches before giving up on an improvement.**
"@
}

# --- Build time budget instructions ---
$TimeInstructions = ""
if ($TimeBudget -gt 0) {
    $TimeInstructions = @"

## TIME BUDGET

Each iteration (analyze -> code -> test -> evaluate) must complete within **${TimeBudget} seconds**.
- If a test/build/metric command runs too long, stop it and move on
- Prioritize fast feedback: prefer unit tests over integration tests within time budget
"@
}

if ($Mode -eq "program") {
    # --- Program mode (exploratory, Karpathy-style) ---
    $Prompt = @"
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
- If improvement confirmed -> KEEP changes, checkpoint commit with descriptive message
- If no improvement or regression -> DISCARD with ``git checkout -- .``
- Log the result in .autocode-state/experiment-log.md:
  ```
  ## Iteration N — [KEEP/DISCARD]
  **Hypothesis:** ...
  **Change:** ...
  **Result:** baseline=X -> new=Y
  ```

### Step 6: ITERATE
- If max retries ($MaxRetries) reached -> stop and summarize findings
- Otherwise -> go back to Step 2 with new hypothesis informed by previous results
- Print "AUTOCODE COMPLETE" when done

## CRITICAL RULES:
- NEVER stop to ask me questions — make reasonable decisions
- ONE change per iteration — keep experiments isolated
- ALWAYS measure before and after
- NEVER keep a change that breaks existing tests
- Checkpoint commit after each KEPT change
- Document ALL experiments (including discarded ones) in experiment-log.md

## PROGRAM (Research Direction):

$SpecContent
$PlanSearchInstructions
$PRCoTInstructions
$MetricInstructions
$TimeInstructions
"@
} else {
    # --- Spec mode (standard, strict requirements) ---
    $Prompt = @"
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
- If ALL tests PASS (exit code 0) -> go to Step 5
- If ANY test FAILS -> read the error, fix the code, go back to Step 3
- Maximum retries: $MaxRetries

### Step 5: LINT & BUILD
- Run lint command from DoD
- Run build command from DoD
- If either fails -> fix and retry

### Step 6: COMMIT
- git add only the files you created/modified
- git commit with descriptive message
- Print "AUTOCODE COMPLETE" as the final output

## CRITICAL RULES:
- NEVER stop to ask questions — make reasonable decisions
- NEVER skip writing tests — every business rule needs a test
- If a dependency is missing, install it
- If you can't figure something out after 3 attempts, log it and move on
- Commit after EACH module succeeds (checkpoint commits)

## SPEC:

$SpecContent
$PlanSearchInstructions
$PRCoTInstructions
$MetricInstructions
$TimeInstructions
"@
}

claude --print --model $ModelId --dangerously-skip-permissions --max-turns $MaxTurns $Prompt

$ExitCode = $LASTEXITCODE

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
if ($ExitCode -eq 0) {
    Write-Host "  DONE - AutoCode completed successfully" -ForegroundColor Green
    @{started=(Get-Content $PhaseLog | ConvertFrom-Json).started; completed=(Get-Date -Format "o"); status="success"} | ConvertTo-Json | Set-Content $PhaseLog
} else {
    Write-Host "  FAIL - AutoCode exited with code $ExitCode" -ForegroundColor Red
    Add-Content $ErrorLog "[$(Get-Date -Format 'o')] Exit code: $ExitCode"
}
Write-Host "  Finished: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "================================================" -ForegroundColor Cyan

exit $ExitCode
