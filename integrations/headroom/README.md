# Headroom Integration

## What is Headroom?
Headroom provides dynamic context compression for AI coding tools. It compresses tool output, conversation history, JSON responses, logs, and images in real-time — achieving 70-95% lossless compression.

## Key Features
- **Tool output compression** — compress large grep/read results
- **History compression** — keep more conversation context in the window
- **JSON compression** — efficiently compress API responses and configs
- **Self-learning** — adapts compression patterns to your codebase over time
- **Proxy mode** — zero-config intercept of API calls
- **Memory management** — auto-updates MEMORY.md with learned patterns

## Installation
Check the latest installation method at the Headroom repository.

## Configuration
Copy `headroom.config.yaml` to your project root:

```yaml
proxy:
  port: 8080
  target: https://api.anthropic.com

compression:
  tool_output: true
  conversation_history: true
  json_responses: true
  images: true
  min_size_bytes: 1024  # Don't compress small outputs

learning:
  enabled: true
  memory_file: .claude/memory/MEMORY.md
  pattern_retention: 30d

monitoring:
  log_savings: true
  stats_file: .headroom-stats.json
```

## Integration with AutoCode
Set in `autocode/autocode.config`:
```ini
HEADROOM_ENABLED=true
HEADROOM_PORT=8080
```

## Combined with Repomix
```
Repomix (static)  → packs codebase once    → ~70% compression
Headroom (dynamic) → compresses at runtime  → ~70-95% compression
Combined           → 80-90% total savings
```

## Monitoring
```bash
# View compression stats
cat .headroom-stats.json

# Check learned patterns
# (method depends on Headroom version)
```

## Best Practices
1. Start with default config, tune `min_size_bytes` based on usage
2. Enable self-learning for projects you work on frequently
3. Monitor stats weekly to verify savings
4. Reset learning if compression quality degrades
5. Exclude from version control: `.headroom-stats.json`
