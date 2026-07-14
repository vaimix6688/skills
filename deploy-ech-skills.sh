#!/usr/bin/env bash
# Deploy the 6 ECH review/guard skills into a target repo's .claude/skills/
# Usage: ./deploy-ech-skills.sh /path/to/ech-repo   (defaults to global ~/.claude/skills)
set -e
SRC="$(cd "$(dirname "$0")" && pwd)/.claude/skills"
TARGET="${1:-$HOME/.claude}"
DST="$TARGET/skills"
mkdir -p "$DST"
for d in ech-plan-eng-review ech-pre-merge-review ech-design-review ech-done-gate ech-safety-guard ech-retro; do
  mkdir -p "$DST/$d"
  # source library stores flat persona .md; convert to SKILL.md form
  if [ -f "$SRC/$d/SKILL.md" ]; then cp "$SRC/$d/SKILL.md" "$DST/$d/SKILL.md";
  else
    name="$d"; desc=$(grep -m1 '^description:' "$SRC/$d.md" | sed 's/^description:[[:space:]]*//; s/^"//; s/"$//')
    { printf -- '---\nname: %s\ndescription: %s\n---\n' "$name" "$desc"; awk 'BEGIN{c=0}/^---[[:space:]]*$/{c++;next}c>=2{print}' "$SRC/$d.md"; } > "$DST/$d/SKILL.md"
  fi
done
# if deploying into a repo, suggest gitignoring so it doesn't pollute git status
if [ "$TARGET" != "$HOME/.claude" ] && [ -d "$TARGET/.git" -o -f "$TARGET/../.git" ]; then
  gi="$TARGET/.gitignore"; grep -q '^/skills/ech-' "$gi" 2>/dev/null || echo "/skills/ech-*/" >> "$gi" 2>/dev/null || true
fi
echo "Deployed 6 ECH skills → $DST"
