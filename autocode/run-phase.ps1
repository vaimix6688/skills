# =============================================================================
# AutoCode — Phase Runner (PowerShell)
# Runs all specs in a phase automatically, unattended.
#
# Usage: .\run-phase.ps1 -Phase 1
#        .\run-phase.ps1 -Phase 2 -StartFrom 5
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [int]$Phase,

    [int]$StartFrom = 1,
    [int]$MaxTurns = 0
)

$ErrorActionPreference = "Continue"

# --- Load configuration ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptDir "autocode.config"
$ProjectName = "MyProject"
$ProjectRoot = Split-Path -Parent $ScriptDir

# Default repo map
$RepoMap = @{}

if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#")) {
            $parts = $line -split "=", 2
            if ($parts.Count -eq 2) {
                $key = $parts[0].Trim()
                $val = $parts[1].Trim()
                switch -Wildcard ($key) {
                    "PROJECT_NAME"  { $ProjectName = $val }
                    "PROJECT_ROOT"  { $ProjectRoot = $val }
                    "MAX_TURNS"     { if ($MaxTurns -eq 0) { $MaxTurns = [int]$val } }
                    "REPO_MAP_*"    {
                        $repoKey = $key -replace "^REPO_MAP_", ""
                        $RepoMap[$repoKey] = $val
                    }
                }
            }
        }
    }
}

if ($MaxTurns -eq 0) { $MaxTurns = 200 }

# If no repo map loaded from config, use defaults
if ($RepoMap.Count -eq 0) {
    $RepoMap = @{
        "core"       = "${ProjectName}-core"
        "frontend"   = "${ProjectName}-frontend"
        "fe"         = "${ProjectName}-frontend"
        "infra"      = "${ProjectName}-infra"
        "crypto"     = "${ProjectName}-crypto"
        "compliance" = "${ProjectName}-compliance"
        "ingestion"  = "${ProjectName}-ingestion"
        "ai"         = "${ProjectName}-ai"
    }
}

$SpecsDir = "$ProjectRoot\${ProjectName}-docs\autocode\specs\phase$Phase"
$LogDir = "$ProjectRoot\${ProjectName}-docs\autocode\logs"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Create log directory
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

# Find specs
$Specs = Get-ChildItem "$SpecsDir\*.spec.md" | Sort-Object Name
if ($Specs.Count -eq 0) {
    Write-Host "ERROR: No specs found in $SpecsDir" -ForegroundColor Red
    exit 1
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  $ProjectName AutoCode — Phase $Phase Runner" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Specs found: $($Specs.Count)"
Write-Host "  Start from:  #$StartFrom"
Write-Host "  Max turns:   $MaxTurns"
Write-Host "  Log dir:     $LogDir"
Write-Host "  Started:     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$Total = 0
$Passed = 0
$Failed = 0
$Skipped = 0
$Results = @()

foreach ($Spec in $Specs) {
    $Total++

    if ($Total -lt $StartFrom) {
        $Skipped++
        Write-Host "[$Total/$($Specs.Count)] SKIP: $($Spec.Name)" -ForegroundColor DarkGray
        continue
    }

    # Detect repo from filename (e.g., "1.1-core-event-chain-tests.spec.md" -> "core")
    $RepoKey = ($Spec.BaseName -split '-')[1]
    $RepoName = $RepoMap[$RepoKey]
    if (-not $RepoName) { $RepoName = $RepoMap["core"] }
    $RepoPath = "$ProjectRoot\$RepoName"

    Write-Host ""
    Write-Host "[$Total/$($Specs.Count)] $($Spec.Name)" -ForegroundColor Yellow
    Write-Host "  Repo: $RepoPath" -ForegroundColor Gray
    Write-Host "  Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray

    if (-not (Test-Path $RepoPath)) {
        Write-Host "  ERROR: Repo not found" -ForegroundColor Red
        $Failed++
        $Results += [PSCustomObject]@{Spec=$Spec.Name; Status="FAIL"; Reason="Repo not found"}
        continue
    }

    # Copy spec to repo
    Copy-Item $Spec.FullName "$RepoPath\spec.md" -Force

    # Log file for this spec
    $SpecLog = "$LogDir\phase${Phase}_${Total}_$($Spec.BaseName)_${Timestamp}.log"

    # Run autocode
    Push-Location $RepoPath
    try {
        $StartTime = Get-Date

        claude --print --dangerously-skip-permissions --max-turns $MaxTurns `
            "AUTONOMOUS MODE. Read spec.md. Write tests, run them, fix until ALL PASS, then commit. No questions." `
            2>&1 | Tee-Object -FilePath $SpecLog

        $ExitCode = $LASTEXITCODE
        $Duration = (Get-Date) - $StartTime

        if ($ExitCode -eq 0) {
            Write-Host "  PASSED ($([math]::Round($Duration.TotalMinutes, 1)) min)" -ForegroundColor Green
            $Passed++
            $Results += [PSCustomObject]@{Spec=$Spec.Name; Status="PASS"; Duration="$([math]::Round($Duration.TotalMinutes, 1))m"}
        } else {
            Write-Host "  FAILED (exit $ExitCode, $([math]::Round($Duration.TotalMinutes, 1)) min)" -ForegroundColor Red
            $Failed++
            $Results += [PSCustomObject]@{Spec=$Spec.Name; Status="FAIL"; Duration="$([math]::Round($Duration.TotalMinutes, 1))m"}
        }
    }
    catch {
        Write-Host "  ERROR: $_" -ForegroundColor Red
        $Failed++
        $Results += [PSCustomObject]@{Spec=$Spec.Name; Status="ERROR"; Reason=$_.ToString()}
    }
    finally {
        # Cleanup
        Remove-Item "$RepoPath\spec.md" -ErrorAction SilentlyContinue
        Pop-Location
    }
}

# Summary
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  PHASE $Phase SUMMARY" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Total:   $Total"
Write-Host "  Passed:  $Passed" -ForegroundColor Green
Write-Host "  Failed:  $Failed" -ForegroundColor $(if ($Failed -gt 0) {"Red"} else {"Green"})
Write-Host "  Skipped: $Skipped" -ForegroundColor Gray
Write-Host ""
Write-Host "  Results:" -ForegroundColor Cyan
$Results | Format-Table -AutoSize
Write-Host "  Finished: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "  Logs:     $LogDir"
Write-Host "================================================================" -ForegroundColor Cyan

# Save summary
$Results | Export-Csv "$LogDir\phase${Phase}_summary_${Timestamp}.csv" -NoTypeInformation

if ($Failed -gt 0) { exit 1 } else { exit 0 }
