# Skill Creation Guide

How to create effective AI agent skills for this framework. Adapted from the "writing-skills" meta-skill methodology.

## Core Principle

**Writing skills IS Test-Driven Development applied to process documentation.**

You write test cases (pressure scenarios), watch them fail (baseline behavior), write the skill, watch tests pass (agents comply), and refactor (close loopholes).

## When to Create a Skill

**Create when:**
- Technique wasn't intuitively obvious
- You'd reference this again across projects
- Pattern applies broadly (not project-specific)
- Others would benefit

**Don't create for:**
- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions (put in CLAUDE.md instead)
- Mechanical constraints enforceable with regex/validation

## Skill Types

| Type | Description | Examples |
|------|-------------|----------|
| **Persona** | Role-based agent with identity, mission, and rules | engineering-debugger, agents-orchestrator |
| **Discipline** | Process enforcement with rationalization prevention | test-driven-development, verification-before-completion |
| **Technique** | Concrete method with steps to follow | systematic-debugging, condition-based-waiting |
| **Reference** | API docs, syntax guides, tool documentation | database queries, library references |

## Skill File Structure

```yaml
---
name: Skill Name
description: "What this skill does and when to use it"
color: blue        # UI color hint
emoji: 🔧          # Visual identifier
vibe: "One-liner describing the skill's personality"
model: sonnet      # haiku | sonnet | opus
---

# Skill Name

## 🧠 Your Identity & Memory
- Role, personality, experience

## 🎯 Your Core Mission
- Primary objectives

## 🚨 Critical Rules You Must Follow
- Non-negotiable constraints

## 📋 Methodology / Workflow
- Step-by-step process

## 💭 Your Communication Style
- How to communicate findings

## 🔄 Learning & Memory
- What to remember across sessions

## 🎯 Your Success Metrics
- How to measure effectiveness
```

## Model Routing

| Tier | Model | When to use |
|------|-------|-------------|
| `haiku` | Budget | Simple tasks, docs, memory updates |
| `sonnet` | Standard | Standard development, testing, reviews |
| `opus` | Premium | Complex architecture, deep research, security audits |

## Discipline Skills: Bulletproofing Against Rationalization

Skills that enforce discipline (TDD, verification) need special treatment because AI agents will find loopholes when under pressure.

### The Iron Law Pattern
Every discipline skill should have one unbreakable rule:
```markdown
## The Iron Law
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

### Rationalization Table
Capture every excuse agents make and counter it:
```markdown
| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
```

### Red Flags List
Self-check triggers for agents:
```markdown
## Red Flags — STOP
- Code before test
- "I already manually tested it"
- "Just this once"
**All of these mean: STOP. Start over.**
```

### Spirit vs Letter Defense
Add this early in the skill:
```markdown
**Violating the letter of the rules is violating the spirit of the rules.**
```

## Quality Checklist

Before deploying a new skill:

- [ ] Name uses only letters, numbers, hyphens
- [ ] YAML frontmatter with required fields (name, description, model)
- [ ] Description clearly states purpose and triggers
- [ ] Clear overview with core principle
- [ ] Code examples are concrete and runnable (not templates)
- [ ] One excellent example per concept (not multi-language)
- [ ] Common mistakes section with fixes
- [ ] Cross-references to related skills
- [ ] Tested against real scenarios

## Search Optimization (CSO)

Future agents need to FIND your skill. Optimize for discovery:

1. **Rich description** — use concrete triggers and symptoms
2. **Keyword coverage** — include error messages, symptoms, synonyms
3. **Descriptive naming** — verb-first, active voice (`systematic-debugging` not `debug-helpers`)

### Description Anti-Patterns
```yaml
# ❌ BAD: Too vague
description: For debugging

# ❌ BAD: Summarizes workflow (agent may follow description instead of reading skill)
description: Use when debugging — observe, hypothesize, isolate, verify

# ✅ GOOD: Triggering conditions only
description: Use when encountering any bug, test failure, or unexpected behavior
```

## Cross-Referencing Other Skills

When referencing related skills:
```markdown
# ✅ Good — clear requirement
**Related:** Use `systematic-debugging` for the debugging discipline framework.

# ❌ Bad — unclear if required
See skills/engineering-debugger.md
```

## File Organization

| Pattern | When to use |
|---------|-------------|
| Single `.md` file | All content fits inline (<500 lines) |
| File + supporting docs | Heavy reference material (100+ lines of API docs) |
| File + scripts | Reusable tools, utilities, templates |
