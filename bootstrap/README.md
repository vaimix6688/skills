# Bootstrap Prompt System

## What is bootstrap.prompt?

A `bootstrap.prompt` file placed in `.claude/` is automatically loaded by Claude Code at the start of every session. Unlike `CLAUDE.md` (which is loaded with every message), bootstrap.prompt loads **once** — saving tokens and preventing context drift.

## Why use it?

| | CLAUDE.md | bootstrap.prompt |
|---|---|---|
| **Load frequency** | Every message | Once per session |
| **Purpose** | Project facts & instructions | Reasoning anchor & constraints |
| **Content** | Tech stack, repo map, conventions | Golden rules, decision flow, identity |
| **Token cost** | Per turn | One-time |

## How it works

1. Place `bootstrap.prompt` in your project's `.claude/` directory
2. Start a new Claude Code session in that project
3. The prompt is automatically injected into the system context
4. All subsequent messages benefit from the anchored context without re-loading it

## Usage

### Quick Start
```bash
# Copy the template
cp bootstrap/bootstrap.prompt.template your-project/.claude/bootstrap.prompt

# Edit placeholders
# Replace all {{PLACEHOLDER}} values with your project details
```

### With init script
```bash
# The init script generates bootstrap.prompt automatically
./init.sh --project "MyProject" --type "SaaS" --stack "TypeScript, React, Node.js"
```

## Template Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{PROJECT_NAME}}` | Project name | MyApp |
| `{{BUSINESS_TYPE}}` | Business model | B2B SaaS |
| `{{TARGET_USERS}}` | Primary users | SMB owners, developers |
| `{{TECH_STACK}}` | Core technologies | TypeScript, React, PostgreSQL |
| `{{REPO_LIST}}` | Repository names | myapp-core, myapp-frontend |
| `{{RULE_N}}` | Golden rules | Event sourcing only, no DELETE |

## Best Practices

1. **Keep it concise** — under 200 lines for token efficiency
2. **Focus on constraints** — what NOT to do is more important than what to do
3. **Include reasoning flow** — analyze → plan → act → validate
4. **Update periodically** — when architecture or constraints change significantly
5. **Complement CLAUDE.md** — don't duplicate content between the two files

## Examples

See `examples/` for real-world bootstrap.prompt files:
- `tracepro.bootstrap.prompt` — Supply chain traceability system (multi-repo, multi-language)
- `saas.bootstrap.prompt` — Generic SaaS application (monorepo, TypeScript)
