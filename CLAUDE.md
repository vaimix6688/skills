# CLAUDE.md — Skills Framework

## What is this?

This is a **reusable skills framework** for AI-augmented software development. It provides:

- **28 Claude Code skills** — specialized AI agent personas for every development role
- **AutoCode system** — spec-driven autonomous code generation with self-healing loops
- **Bootstrap prompt system** — one-time context loading for token efficiency
- **Development lifecycle templates** — guidelines, CI/CD, configs, runbooks
- **Token optimization** — Repomix + Headroom integration for 80-90% token savings

## Quick Start

### For a new project:
```bash
./init.sh --project "MyProject" --stack "typescript,react,postgresql"
```

### For an existing project:
1. Copy `.claude/skills/` to your project
2. Create `.claude/bootstrap.prompt` from `bootstrap/bootstrap.prompt.template`
3. Copy `autocode/` for spec-driven development
4. Copy relevant `docs/` templates

## Directory Structure

```
skills/
├── .claude/
│   ├── bootstrap.prompt          # Session context anchor (loaded once)
│   └── skills/                   # 28 AI agent skills
├── autocode/                     # Spec-driven code generation
│   ├── autocode.config.example   # Project-specific configuration
│   ├── SPEC_TEMPLATE.md          # Standard spec format
│   └── examples/                 # Example specs
├── hooks/                        # Automated checks & guardrails (CI, pre-commit, validations)
├── tools/                        # Custom scripts & recurring workflow prompts
├── bootstrap/                    # Bootstrap prompt templates & examples
├── integrations/                 # Repomix + Headroom setup
│   ├── repomix/                  # Static codebase compression
│   └── headroom/                 # Dynamic context compression
└── docs/                         # Development lifecycle templates
    ├── guidelines/               # Coding standards, testing, git, security
    │   ├── AI_AGENT_BASELINE.md      # Universal AI agent behavior rules (Karpathy + Universal Protocol + Rune)
    │   ├── INVARIANTS_TEMPLATE.md    # Hard invariants registry template (logic-guardian pattern)
    │   ├── coding-standards.md
    │   ├── testing-strategy.md
    │   ├── git-workflow.md
    │   ├── security-guidelines.md
    │   ├── bug-fix-process.md
    │   └── release-process.md
    ├── ci/                       # CI/CD pipeline templates (Go, Rust, TS, Python)
    ├── configs/                  # Linter configs, Makefiles, docker-compose
    ├── templates/                # PR, bug report, feature request templates
    ├── runbooks/                 # Deploy & rollback procedures
    ├── onboarding/               # New developer setup guide
    └── checklist/                # Software dev lifecycle checklist
```

## AI Agent Discipline Layer (NEW v1.1 — 2026-04-25)

Three-layer discipline system, applied per task complexity:

| Layer | File | When to apply |
|-------|------|---------------|
| **L1 Universal** | [docs/guidelines/AI_AGENT_BASELINE.md §1](docs/guidelines/AI_AGENT_BASELINE.md) — Karpathy 4 principles | Always (every project, every task) |
| **L2 Code Discipline** | [AI_AGENT_BASELINE.md §2](docs/guidelines/AI_AGENT_BASELINE.md) — Universal Engineering Task Protocol (5-section + PACE-lite) | Code edits with test suite. Skip for doc-only edits. |
| **L3 Hard Invariants** | [docs/guidelines/INVARIANTS_TEMPLATE.md](docs/guidelines/INVARIANTS_TEMPLATE.md) — copy → `<project>/docs/INVARIANTS.md`, fill domain rules | Large project with core modules + financial / state-machine / audit critical paths |

**Reference pattern** in project root `CLAUDE.md`:

```markdown
## AI Agent Baseline

Follows [AI_AGENT_BASELINE.md](D:/Code/skills/docs/guidelines/AI_AGENT_BASELINE.md):
- L1 Karpathy 4 principles — always
- L2 Universal Protocol — for code edits in `<paths>` (skip `docs/`)
- L3 INVARIANTS — see [docs/INVARIANTS.md](./docs/INVARIANTS.md)
```

**Sources distilled:**
- [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) — 86k★ behavioral rules
- Universal Engineering Task Protocol (Telegram-circulated, VN community)
- [rune-kit/rune](https://github.com/rune-kit/rune) — 5-layer mesh, INVARIANTS pattern, workflow chains

## Skills Catalog (28 skills)

### Engineering (11)
| Skill | Purpose |
|-------|---------|
| `engineering-backend-architect` | Go/Rust API design, service architecture |
| `engineering-software-architect` | System design, DDD, architecture decisions |
| `engineering-database-optimizer` | PostgreSQL tuning, query optimization |
| `engineering-sre` | Monitoring, SLOs, incident response |
| `engineering-devops-automator` | CI/CD, Kubernetes, infrastructure as code |
| `engineering-security-engineer` | Security audits, auth patterns, key management |
| `engineering-code-reviewer` | Multi-language PR reviews |
| `engineering-frontend-developer` | React, Next.js, UI/UX implementation |
| `engineering-senior-developer` | Full-stack general development |
| `engineering-technical-writer` | Documentation, ADRs, API docs |
| `engineering-data-engineer` | Data pipelines, ETL, event streaming |

### Testing (3)
| Skill | Purpose |
|-------|---------|
| `testing-api-tester` | API contract tests, endpoint validation |
| `testing-performance-benchmarker` | Load testing, latency benchmarks |
| `testing-workflow-optimizer` | E2E tests, integration test optimization |

### Domain-Specific (5)
| Skill | Purpose |
|-------|---------|
| `supply-chain-strategist` | Supply chain domain logic |
| `compliance-auditor` | Regulatory compliance, audit trails |
| `blockchain-security-auditor` | ZK proofs, blockchain security |
| `agents-orchestrator` | Multi-agent coordination |
| `specialized-workflow-architect` | Business process automation |

### Research (1)
| Skill | Purpose |
|-------|---------|
| `deep-research` | Multi-angle web research (4-phase: Broad → Deep → Diversity → Synthesis) |

### Audit (1)
| Skill | Purpose |
|-------|---------|
| `saas-project-auditor` | Full-stack SaaS project audit, feature inventory, gaps, launch roadmap |

### Meta Skills (8)
| Skill | Purpose |
|-------|---------|
| `project-memory-updater` | Continuous learning loop, extract rules/workflows from errors |
| `business-analyst` | PRD, user stories, business rules, personas, journey maps |
| `doc-sync-automator` | Auto-update docs when code changes |
| `bootstrap-architect` | Create/maintain bootstrap.prompt |
| `repomix-headroom-optimizer` | Token optimization setup |
| `spec-writer` | Convert ideas to SDD-format specs |
| `agent-bootstrap` | Create agent personas/CLAUDE.md through adaptive onboarding conversations |
| `project-scaffolder` | Bootstrap new projects |

## Magic Keywords

When you detect these keywords at the **start** of a user's message, automatically load and apply the corresponding skill:

| Keyword | Skill | Behavior |
|---------|-------|----------|
| `autopilot` | `agents-orchestrator` | Full autonomous pipeline: analyze → architect → develop → test → ship |
| `architect` | `engineering-software-architect` | System design mode: analyze trade-offs, propose architecture |
| `review` | `engineering-code-reviewer` | Code review mode: read diff/PR, provide actionable feedback |
| `secure` | `engineering-security-engineer` | Security audit mode: threat model, vulnerability scan |
| `research` | `deep-research` | 4-phase web research: Broad → Deep → Diversity → Synthesis |
| `spec` | `spec-writer` | Convert idea/requirements into SDD-format specification |
| `audit` | `saas-project-auditor` | Full project audit: inventory, gaps, launch roadmap |
| `optimize` | `engineering-database-optimizer` | Database optimization: query plans, indexes, schema review |
| `devops` | `engineering-devops-automator` | Infrastructure mode: CI/CD, K8s, IaC |
| `test` | `testing-api-tester` | API testing mode: contract tests, endpoint validation |
| `analyze` | `business-analyst` | Business analysis: PRD, user stories, journey maps |

**Usage:** Just start your message with the keyword:
```
architect: Design a microservices architecture for our payment system
review: Check the latest PR for security issues
research: What are the best practices for event sourcing in 2026?
```

## Model Routing

Each skill has a `model` field in its frontmatter that determines which Claude model to use:

| Tier | Model | When to use | Skills |
|------|-------|-------------|--------|
| `haiku` | claude-haiku-4-5 | Simple tasks, docs, memory updates | doc-sync-automator, project-memory-updater, bootstrap-architect, repomix-headroom-optimizer, technical-writer |
| `sonnet` | claude-sonnet-4-6 | Standard development, testing, reviews | Most engineering & testing skills (default) |
| `opus` | claude-opus-4-6 | Complex architecture, deep research, security audits | software-architect, backend-architect, agents-orchestrator, deep-research, saas-project-auditor, security-engineer, blockchain-security-auditor |

AutoCode reads the `model` field automatically. Override with `--model`:
```bash
./autocode.sh /repo spec.md --agent engineering-senior-developer --model opus
```

## Key Concepts

### The Continuous Learning Loop
To operate Claude as a self-improving infrastructure, follow these rules:
1. **Error -> Rule**: When Claude makes a mistake, add a rule to `CLAUDE.md` or `.claude/bootstrap.prompt`.
2. **Repetition -> Workflow**: When you repeat a task, write a new workflow in `tools/` or a new skill in `.claude/skills/`.
3. **Breakage -> Guardrail**: When something breaks, add an automated test or guardrail to `hooks/`.
*Use the `project-memory-updater` skill to automate this loop.*

### bootstrap.prompt vs CLAUDE.md
| | CLAUDE.md | bootstrap.prompt |
|---|---|---|
| Load | Every message | Once per session |
| Purpose | Project facts | Reasoning anchor |
| Content | Tech stack, repo map | Golden rules, constraints |
| Token cost | Per turn | One-time |

### AutoCode Workflow

AutoCode supports two input modes:

**Spec Mode** (default) — strict requirements, deterministic output:
```
Spec (SDD format) → Claude Code → Code → Test → Lint → Fix → Commit
```
Self-healing loop: if tests fail, Claude reads errors and fixes automatically.

**Program Mode** (exploratory, inspired by Karpathy's autoresearch) — research direction, iterative experiments:
```
program.md (direction) → Hypothesize → Implement → Measure → Keep/Discard → Repeat
```
Agent runs ~20-100 experiments autonomously, keeping improvements and discarding regressions.

```bash
# Spec mode (default)
./autocode.sh /repo spec.md --agent engineering-senior-developer

# Program mode with metric-driven keep/discard
./autocode.sh /repo program.md --mode program --metric "npm run bench | tail -1" --metric-direction lower_is_better

# With time budget per iteration
./autocode.sh /repo program.md --mode program --time-budget 300
```

**Key features:**
- **Metric-driven keep/discard**: run a metric command after each change, auto-rollback if metric worsens
- **Time budget**: cap each iteration to N seconds (default 300s = 5 minutes)
- **Experiment log**: all iterations (kept + discarded) logged in `.autocode-state/experiment-log.md`
- **Auto-detect**: files named `program*.md` auto-switch to program mode

### Execution Strategies (ATLAS-inspired)

Use `--strategy` to control how AutoCode approaches the task:

| Strategy | Behavior | When to use |
|---|---|---|
| `standard` | Single attempt, fix-and-retry on failure | Simple features, bug fixes (default) |
| `plansearch` | Generate k candidate plans, score & rank, implement best | Complex features, ambiguous specs |
| `resilient` | PlanSearch + PR-CoT self-repair on repeated failures | Critical code, high-risk changes |
| `explore` | Program mode + metric-driven keep/discard | Performance optimization, research |

**PlanSearch** (inspired by ATLAS): before writing code, agent generates N different solution plans, scores each on correctness/simplicity/performance, and implements only the winning plan. If it fails, switches to next-best plan instead of patching blindly.

**PR-CoT** (Plan-Repair Chain of Thought): when fix-and-retry fails 2+ times, agent stops and analyzes from 3 perspectives (logic error, integration error, assumption error), writes its own diagnostic tests, and pivots to a completely different approach if needed.

```bash
# Standard (v1 behavior, default)
./autocode.sh /repo spec.md

# PlanSearch — 3 candidate plans, pick best
./autocode.sh /repo spec.md --strategy plansearch

# Resilient — PlanSearch + structured self-repair
./autocode.sh /repo spec.md --strategy resilient --candidates 5

# Explore — metric-driven optimization
./autocode.sh /repo program.md --strategy explore --metric "npm run bench | tail -1"
```

### Token Optimization Stack
```
Repomix (static)  → pack codebase ~70% compression
Headroom (dynamic) → compress runtime ~70-95%
Combined           → 80-90% total savings
```
