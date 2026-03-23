#!/bin/bash
# Pack repository using Repomix
# Usage: ./repomix-pack.sh [path-to-repo] [output-file]

set -euo pipefail

REPO_PATH="${1:-.}"
OUTPUT="${2:-.repomix-output.xml}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if repomix is installed
if ! command -v repomix &> /dev/null; then
    echo "❌ Repomix not found. Install with: npm install -g repomix"
    exit 1
fi

# Copy config if not exists in target
if [ ! -f "${REPO_PATH}/repomix.config.json" ]; then
    echo "📋 Copying default repomix.config.json..."
    cp "${SCRIPT_DIR}/repomix.config.json" "${REPO_PATH}/repomix.config.json"
fi

# Pack
echo "📦 Packing ${REPO_PATH}..."
cd "${REPO_PATH}"
repomix --output "${OUTPUT}"

# Stats
if [ -f "${OUTPUT}" ]; then
    SIZE=$(wc -c < "${OUTPUT}" | tr -d ' ')
    SIZE_KB=$((SIZE / 1024))
    echo "✅ Packed to ${OUTPUT} (${SIZE_KB} KB)"

    # Add to gitignore if not already there
    if [ -f .gitignore ] && ! grep -q "repomix-output" .gitignore; then
        echo ".repomix-output.*" >> .gitignore
        echo "📝 Added .repomix-output.* to .gitignore"
    fi
else
    echo "❌ Packing failed"
    exit 1
fi
