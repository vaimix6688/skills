# Skills Framework — AI-Augmented Software Development Kit

A complete, reusable framework for AI-augmented software development. Includes 24 Claude Code skills, spec-driven code generation, bootstrap prompt system, and token optimization integrations.

## Quick Start

### Bootstrap a new project
```bash
# Clone this repo
git clone <this-repo> skills

# Run the init script
cd skills
./init.sh --project "MyProject" --stack "typescript,react,postgresql"
```

This generates:
- `CLAUDE.md` — project master guide
- `.claude/bootstrap.prompt` — reasoning anchor (loaded once per session)
- `autocode/autocode.config` — code generation configuration
- CI/CD templates, linter configs, guidelines (based on your tech stack)

### Add skills to an existing project
```bash
# Copy skills directory
cp -r skills/.claude/skills/ your-project/.claude/skills/

# Copy bootstrap prompt template
cp skills/bootstrap/bootstrap.prompt.template your-project/.claude/bootstrap.prompt
# Edit the placeholders in bootstrap.prompt
```

## What's Inside

### `.claude/skills/` — 24 AI Agent Skills
Specialized Claude Code personas for every development role:
- **11 Engineering** — backend, frontend, database, DevOps, security, SRE, etc.
- **3 Testing** — API, performance, workflow testing
- **5 Domain** — supply chain, compliance, blockchain, orchestration
- **5 Meta** — doc sync, bootstrap architect, token optimizer, spec writer, scaffolder

### `autocode/` — Spec-Driven Code Generation
Write specs → Claude Code generates, tests, and commits code autonomously.
```bash
./autocode/autocode.sh /path/to/repo spec.md
```

### `bootstrap/` — Bootstrap Prompt System
The `bootstrap.prompt` pattern: load project context ONCE per session instead of every message.
- Saves tokens (loaded once, not per turn)
- Prevents context drift
- Anchors reasoning to golden rules

### `integrations/` — Token Optimization
- **Repomix** — pack entire codebase into 1 file (~70% compression)
- **Headroom** — compress dynamic context in real-time (~70-95%)
- Combined: **80-90% token savings**

### `docs/` — Development Lifecycle Templates
Production-ready templates for:
- Coding standards (Go, Rust, TypeScript, Python)
- Testing strategy & coverage targets
- Git workflow & branch naming
- CI/CD pipelines (GitLab CI templates)
- Security guidelines
- Deploy & rollback runbooks
- PR/bug/feature templates
- Dev lifecycle checklist

## Philosophy

### Spec-Driven Development (SDD)
```
Idea → Spec (.spec.md) → AutoCode → Tests → Ship
```
The spec describes WHAT to build. The AI decides HOW.

### Bootstrap Once, Run Many
```
bootstrap.prompt (1x) + CLAUDE.md (per-turn) = full context without token waste
```

### Self-Healing Code Generation
```
Code → Test → Fail? → Read Error → Fix → Test → Pass → Commit
```
Max 200 iterations. Max $10/session. Automatic git checkpoints.

## Customization

1. **Remove unused skills** — delete skill files you don't need
2. **Add domain skills** — create new `.md` files in `.claude/skills/`
3. **Customize guidelines** — edit files in `docs/guidelines/`
4. **Add CI templates** — extend `docs/ci/` with your CI system
5. **Configure AutoCode** — edit `autocode/autocode.config`

## License

MIT — skills adapted from [agency-agents](https://github.com/agency-agents).

CEO agent skill https://github.com/garrytan/gstack

API Skill https://github.com/bytedance/deer-flow
