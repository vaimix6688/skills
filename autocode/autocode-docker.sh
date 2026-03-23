#!/bin/bash
# =============================================================================
# AutoCode in Docker Sandbox
# Runs autocode inside a Docker container for isolation.
#
# Usage: ./autocode-docker.sh [repo-name] [spec-file]
# Example: ./autocode-docker.sh myproject-core spec.md
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
MAX_TURNS="${MAX_TURNS:-200}"

REPO_NAME="${1:-${PROJECT_NAME}-core}"
SPEC_FILE="${2:-spec.md}"
REPO_PATH="$PROJECT_ROOT/$REPO_NAME"
CONTAINER_NAME="autocode-${REPO_NAME}-$(date +%s)"

if [ ! -d "$REPO_PATH" ]; then
  echo "ERROR: Repo not found: $REPO_PATH"
  exit 1
fi

if [ ! -f "$REPO_PATH/$SPEC_FILE" ]; then
  echo "ERROR: Spec not found: $REPO_PATH/$SPEC_FILE"
  exit 1
fi

echo "================================================"
echo "  $PROJECT_NAME AutoCode (Docker Sandbox)"
echo "  Repo:      $REPO_NAME"
echo "  Spec:      $SPEC_FILE"
echo "  Container: $CONTAINER_NAME"
echo "================================================"

# Build a temporary Docker image with all tools
docker run -it --rm \
  --name "$CONTAINER_NAME" \
  -v "$REPO_PATH:/workspace" \
  -v "$HOME/.claude:/root/.claude" \
  -v "$HOME/.config/claude-code:/root/.config/claude-code" \
  -w /workspace \
  -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
  node:20-bookworm \
  bash -c "
    # Install Claude Code
    npm install -g @anthropic-ai/claude-code 2>/dev/null || true

    # Install Go (if Go repo)
    if [ -f go.mod ]; then
      curl -sL https://go.dev/dl/go1.22.10.linux-amd64.tar.gz | tar -C /usr/local -xz
      export PATH=\$PATH:/usr/local/go/bin
    fi

    # Install Rust (if Rust repo)
    if [ -f Cargo.toml ] || [ -f rust-toolchain.toml ]; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source \$HOME/.cargo/env
    fi

    # Run autocode
    SPEC_CONTENT=\$(cat $SPEC_FILE)
    claude --print --dangerously-skip-permissions --max-turns $MAX_TURNS \
      \"AUTONOMOUS MODE. Read spec, code, test, fix, commit. No questions.

SPEC:
\$SPEC_CONTENT\"
  "

echo ""
echo "================================================"
echo "  Docker sandbox finished."
echo "  Changes are in: $REPO_PATH"
echo "================================================"
