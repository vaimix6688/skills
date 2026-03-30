# =============================================================================
# AutoCode — PowerShell (Windows)
# Usage: .\autocode.ps1 [spec-file]
# Example: .\autocode.ps1 spec.md
# =============================================================================

param(
    [string]$SpecFile = "spec.md",
    [string]$Agent = "",
    [string]$Model = "",
    [int]$MaxTurns = 0
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
                    "PROJECT_NAME"  { $ProjectName = $val }
                    "PROJECT_ROOT"  { $ProjectRoot = $val }
                    "MAX_TURNS"     { if ($MaxTurns -eq 0) { $MaxTurns = [int]$val } }
                }
            }
        }
    }
}

if ($MaxTurns -eq 0) { $MaxTurns = 200 }

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
Write-Host "  Spec:  $SpecFile"
Write-Host "  Agent: $AgentName"
Write-Host "  Model: $ModelTier ($ModelId)"
Write-Host "  Dir:   $(Get-Location)"
Write-Host "  State: $SpecStateDir"
Write-Host "  Time:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "  Max:   $MaxTurns turns"
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Launching Claude Code in autonomous mode..." -ForegroundColor Yellow
Write-Host ""

$Prompt = @"
AUTONOMOUS MODE — DO NOT ASK FOR PERMISSION.

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
- Maximum retries: 10

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
- Commit after EACH module succeeds (checkpoint commits)

## SPEC:

$SpecContent
"@

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
