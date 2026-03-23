# =============================================================================
# Skills Framework — Project Initializer (PowerShell)
# Usage: .\init.ps1 -Project "MyProject" [-Stack "typescript,react"] [-Target "C:\path"]
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [string]$Stack = "",
    [string]$Target = ".",
    [string]$Type = "Software Project",
    [string]$Users = "Developers"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectLower = $Project.ToLower() -replace '\s+', '-'

Write-Host "🚀 Initializing Skills Framework for: $Project" -ForegroundColor Cyan
Write-Host "   Target: $Target"
Write-Host "   Stack:  $(if ($Stack) { $Stack } else { 'auto-detect' })"
Write-Host ""

# Create directory structure
$dirs = @(
    ".claude/skills",
    "autocode/specs",
    "autocode/examples",
    "docs/guidelines",
    "docs/templates",
    "docs/ci",
    "docs/configs",
    "docs/runbooks",
    "docs/onboarding",
    "docs/checklist"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path "$Target/$dir" -Force | Out-Null
}

# Copy skills
Write-Host "📋 Copying skills..." -ForegroundColor Yellow
Copy-Item "$ScriptDir/.claude/skills/*.md" "$Target/.claude/skills/" -Force

# Generate bootstrap.prompt
Write-Host "⚡ Generating bootstrap.prompt..." -ForegroundColor Yellow
$bootstrap = Get-Content "$ScriptDir/bootstrap/bootstrap.prompt.template" -Raw
$bootstrap = $bootstrap -replace '\{\{PROJECT_NAME\}\}', $Project
$bootstrap = $bootstrap -replace '\{\{BUSINESS_TYPE\}\}', $Type
$bootstrap = $bootstrap -replace '\{\{TARGET_USERS\}\}', $Users
$bootstrap = $bootstrap -replace '\{\{TECH_STACK\}\}', $(if ($Stack) { $Stack } else { "To be configured" })
$bootstrap = $bootstrap -replace '\{\{REPO_LIST\}\}', $ProjectLower
$bootstrap = $bootstrap -replace '\{\{RULE_[1-5]\}\}', 'TODO: Define golden rule'
$bootstrap = $bootstrap -replace '\{\{PRINCIPLE_[1-3]\}\}', 'TODO: Define architecture principle'
$bootstrap = $bootstrap -replace '\{\{REPOMIX_PATH\}\}', '.repomix-output.xml'
$bootstrap | Set-Content "$Target/.claude/bootstrap.prompt" -Encoding UTF8

# Generate autocode.config
Write-Host "⚙️  Generating autocode.config..." -ForegroundColor Yellow
$config = Get-Content "$ScriptDir/autocode/autocode.config.example" -Raw
$config = $config -replace 'MyProject', $Project
$config = $config -replace '/path/to/repos', (Resolve-Path $Target).Path
$config = $config -replace 'myproject', $ProjectLower
$config | Set-Content "$Target/autocode/autocode.config" -Encoding UTF8

# Copy autocode essentials
Copy-Item "$ScriptDir/autocode/SPEC_TEMPLATE.md" "$Target/autocode/" -Force -ErrorAction SilentlyContinue
Copy-Item "$ScriptDir/autocode/autocode.sh" "$Target/autocode/" -Force -ErrorAction SilentlyContinue
Copy-Item "$ScriptDir/autocode/autocode.ps1" "$Target/autocode/" -Force -ErrorAction SilentlyContinue
Copy-Item "$ScriptDir/autocode/examples/*" "$Target/autocode/examples/" -Force -ErrorAction SilentlyContinue

# Copy docs
Write-Host "📚 Copying documentation templates..." -ForegroundColor Yellow
$docDirs = @("templates", "guidelines", "runbooks", "onboarding", "checklist")
foreach ($dir in $docDirs) {
    Copy-Item "$ScriptDir/docs/$dir/*.md" "$Target/docs/$dir/" -Force -ErrorAction SilentlyContinue
}
Copy-Item "$ScriptDir/docs/ci/security-scan.yml" "$Target/docs/ci/" -Force -ErrorAction SilentlyContinue

# Universal configs
foreach ($f in @("editorconfig", "lintstaged.json", "commitlint.config.js")) {
    Copy-Item "$ScriptDir/docs/configs/$f" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
}

# Stack-specific configs
if ($Stack) {
    foreach ($s in $Stack.Split(',').Trim()) {
        switch ($s) {
            { $_ -in "go" } {
                Copy-Item "$ScriptDir/docs/ci/ci-go.yml" "$Target/docs/ci/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/Makefile.go" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/golangci.yml" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
            }
            { $_ -in "rust" } {
                Copy-Item "$ScriptDir/docs/ci/ci-rust.yml" "$Target/docs/ci/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/Makefile.rust" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/rust-toolchain.toml" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/rustfmt.toml" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/clippy.toml" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
            }
            { $_ -in "typescript", "ts" } {
                Copy-Item "$ScriptDir/docs/ci/ci-typescript.yml" "$Target/docs/ci/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/Makefile.typescript" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/eslint.config.mjs" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/prettierrc.json" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/prettierignore" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
            }
            { $_ -in "python", "py" } {
                Copy-Item "$ScriptDir/docs/ci/ci-python.yml" "$Target/docs/ci/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/Makefile.python" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
                Copy-Item "$ScriptDir/docs/configs/ruff.toml" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# Docker compose
Copy-Item "$ScriptDir/docs/configs/docker-compose.yml" "$Target/docs/configs/" -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "✅ Skills Framework initialized for $Project!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Edit .claude/bootstrap.prompt — fill in golden rules & principles"
Write-Host "  2. Edit autocode/autocode.config — set repository paths"
Write-Host "  3. Write your first spec: autocode/specs/your-feature.spec.md"
Write-Host "  4. Run: .\autocode\autocode.ps1 -Repo \path\to\repo -Spec autocode\specs\your-feature.spec.md"
