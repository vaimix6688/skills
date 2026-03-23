# Repomix Integration

## What is Repomix?
Repomix packs your entire repository into a single AI-friendly file using Tree-sitter parsing. This enables Claude Code to understand your full codebase in one context load, with ~70% token compression.

## Installation
```bash
npm install -g repomix
```

## Usage
```bash
# Pack current directory
repomix

# Pack specific directory
repomix --path /path/to/repo

# Custom output
repomix --output .repomix-output.txt --style plain
```

## Configuration
Copy `repomix.config.json` to your project root and customize:
- `include` — which files/patterns to pack
- `ignore` — what to exclude (node_modules, build artifacts)
- `security` — secret detection (always enabled)

## Integration with AutoCode
Set in `autocode/autocode.config`:
```ini
REPOMIX_ENABLED=true
REPOMIX_OUTPUT=.repomix-output.xml
```

The autocode scripts will automatically include the packed context when running specs.

## Best Practices
1. Add `.repomix-output.*` to `.gitignore`
2. Re-pack after major structural changes
3. Enable security checks to prevent leaking secrets
4. Use XML format for best AI parsing
5. Monitor output size — if > 500KB, refine include/exclude patterns
