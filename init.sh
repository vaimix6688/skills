#!/bin/bash
# =============================================================================
# Skills Framework — Project Initializer
# Usage: ./init.sh --project "MyProject" [--stack "go,typescript"] [--target /path/to/project]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Defaults
PROJECT_NAME=""
TECH_STACK=""
TARGET_DIR=""
BUSINESS_TYPE="Software Project"
TARGET_USERS="Developers"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project|-p)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --stack|-s)
            TECH_STACK="$2"
            shift 2
            ;;
        --target|-t)
            TARGET_DIR="$2"
            shift 2
            ;;
        --type)
            BUSINESS_TYPE="$2"
            shift 2
            ;;
        --users)
            TARGET_USERS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: ./init.sh --project \"MyProject\" [options]"
            echo ""
            echo "Options:"
            echo "  --project, -p   Project name (required)"
            echo "  --stack, -s     Tech stack (comma-separated: go,typescript,rust,python)"
            echo "  --target, -t    Target directory (default: current directory)"
            echo "  --type          Business type (default: 'Software Project')"
            echo "  --users         Target users (default: 'Developers')"
            echo "  --help, -h      Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ]; then
    echo "Error: --project is required"
    echo "Usage: ./init.sh --project \"MyProject\""
    exit 1
fi

TARGET_DIR="${TARGET_DIR:-.}"
PROJECT_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

echo "🚀 Initializing Skills Framework for: $PROJECT_NAME"
echo "   Target: $TARGET_DIR"
echo "   Stack:  ${TECH_STACK:-auto-detect}"
echo ""

# Create directory structure
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/autocode/specs"
mkdir -p "$TARGET_DIR/autocode/examples"
mkdir -p "$TARGET_DIR/hooks"
mkdir -p "$TARGET_DIR/tools"
mkdir -p "$TARGET_DIR/docs/guidelines"
mkdir -p "$TARGET_DIR/docs/templates"
mkdir -p "$TARGET_DIR/docs/ci"
mkdir -p "$TARGET_DIR/docs/configs"
mkdir -p "$TARGET_DIR/docs/runbooks"
mkdir -p "$TARGET_DIR/docs/onboarding"
mkdir -p "$TARGET_DIR/docs/checklist"

# Copy skills
echo "📋 Copying skills..."
cp "$SCRIPT_DIR/.claude/skills/"*.md "$TARGET_DIR/.claude/skills/" 2>/dev/null || true

# Generate bootstrap.prompt
echo "⚡ Generating bootstrap.prompt..."
sed \
    -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{BUSINESS_TYPE}}/$BUSINESS_TYPE/g" \
    -e "s/{{TARGET_USERS}}/$TARGET_USERS/g" \
    -e "s/{{TECH_STACK}}/${TECH_STACK:-To be configured}/g" \
    -e "s/{{REPO_LIST}}/${PROJECT_LOWER}/g" \
    -e "s/{{RULE_1}}/TODO: Define golden rule 1/g" \
    -e "s/{{RULE_2}}/TODO: Define golden rule 2/g" \
    -e "s/{{RULE_3}}/TODO: Define golden rule 3/g" \
    -e "s/{{RULE_4}}/TODO: Define golden rule 4/g" \
    -e "s/{{RULE_5}}/TODO: Define golden rule 5/g" \
    -e "s/{{PRINCIPLE_1}}/TODO: Define architecture principle 1/g" \
    -e "s/{{PRINCIPLE_2}}/TODO: Define architecture principle 2/g" \
    -e "s/{{PRINCIPLE_3}}/TODO: Define architecture principle 3/g" \
    -e "s|{{REPOMIX_PATH}}|.repomix-output.xml|g" \
    "$SCRIPT_DIR/bootstrap/bootstrap.prompt.template" > "$TARGET_DIR/.claude/bootstrap.prompt"

# Generate autocode.config
echo "⚙️  Generating autocode.config..."
sed \
    -e "s/MyProject/$PROJECT_NAME/g" \
    -e "s|/path/to/repos|$(cd "$TARGET_DIR" && pwd)|g" \
    -e "s/myproject/$PROJECT_LOWER/g" \
    "$SCRIPT_DIR/autocode/autocode.config.example" > "$TARGET_DIR/autocode/autocode.config"

# Copy autocode essentials
cp "$SCRIPT_DIR/autocode/SPEC_TEMPLATE.md" "$TARGET_DIR/autocode/" 2>/dev/null || true
cp "$SCRIPT_DIR/autocode/autocode.sh" "$TARGET_DIR/autocode/" 2>/dev/null || true
cp "$SCRIPT_DIR/autocode/autocode.ps1" "$TARGET_DIR/autocode/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/autocode/examples/" "$TARGET_DIR/autocode/examples/" 2>/dev/null || true

# Copy docs based on tech stack
echo "📚 Copying documentation templates..."

# Always copy these
cp "$SCRIPT_DIR/docs/templates/"*.md "$TARGET_DIR/docs/templates/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/guidelines/"*.md "$TARGET_DIR/docs/guidelines/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/runbooks/"*.md "$TARGET_DIR/docs/runbooks/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/onboarding/"*.md "$TARGET_DIR/docs/onboarding/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/checklist/"*.md "$TARGET_DIR/docs/checklist/" 2>/dev/null || true
cp "$SCRIPT_DIR/docs/ci/security-scan.yml" "$TARGET_DIR/docs/ci/" 2>/dev/null || true

# Universal configs
for f in editorconfig lintstaged.json commitlint.config.js; do
    cp "$SCRIPT_DIR/docs/configs/$f" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
done

# Stack-specific configs
IFS=',' read -ra STACKS <<< "${TECH_STACK:-}"
for stack in "${STACKS[@]}"; do
    stack=$(echo "$stack" | tr -d ' ')
    case $stack in
        go)
            cp "$SCRIPT_DIR/docs/ci/ci-go.yml" "$TARGET_DIR/docs/ci/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/Makefile.go" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/golangci.yml" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            ;;
        rust)
            cp "$SCRIPT_DIR/docs/ci/ci-rust.yml" "$TARGET_DIR/docs/ci/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/Makefile.rust" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/rust-toolchain.toml" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/rustfmt.toml" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/clippy.toml" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            ;;
        typescript|ts)
            cp "$SCRIPT_DIR/docs/ci/ci-typescript.yml" "$TARGET_DIR/docs/ci/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/Makefile.typescript" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/eslint.config.mjs" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/prettierrc.json" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/prettierignore" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            ;;
        python|py)
            cp "$SCRIPT_DIR/docs/ci/ci-python.yml" "$TARGET_DIR/docs/ci/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/Makefile.python" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            cp "$SCRIPT_DIR/docs/configs/ruff.toml" "$TARGET_DIR/docs/configs/" 2>/dev/null || true
            ;;
    esac
done

# Copy docker-compose if exists
cp "$SCRIPT_DIR/docs/configs/docker-compose.yml" "$TARGET_DIR/docs/configs/" 2>/dev/null || true

echo ""
echo "✅ Skills Framework initialized for $PROJECT_NAME!"
echo ""
echo "Generated files:"
find "$TARGET_DIR" -not -path '*/.git/*' -not -path '*/node_modules/*' -type f | sort | head -40
echo ""
echo "Next steps:"
echo "  1. Edit .claude/bootstrap.prompt — fill in golden rules & principles"
echo "  2. Edit autocode/autocode.config — set repository paths"
echo "  3. Write your first spec: autocode/specs/your-feature.spec.md"
echo "  4. Run: ./autocode/autocode.sh /path/to/repo autocode/specs/your-feature.spec.md"
