# CLAUDE.md — Skills Framework

## What is this?

This is a **reusable skills framework** for AI-augmented software development. It provides:

- **26 Claude Code skills** — specialized AI agent personas for every development role
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
│   └── skills/                   # 24 AI agent skills
├── autocode/                     # Spec-driven code generation
│   ├── autocode.config.example   # Project-specific configuration
│   ├── SPEC_TEMPLATE.md          # Standard spec format
│   └── examples/                 # Example specs
├── bootstrap/                    # Bootstrap prompt templates & examples
├── integrations/                 # Repomix + Headroom setup
│   ├── repomix/                  # Static codebase compression
│   └── headroom/                 # Dynamic context compression
└── docs/                         # Development lifecycle templates
    ├── guidelines/               # Coding standards, testing, git, security
    ├── ci/                       # CI/CD pipeline templates (Go, Rust, TS, Python)
    ├── configs/                  # Linter configs, Makefiles, docker-compose
    ├── templates/                # PR, bug report, feature request templates
    ├── runbooks/                 # Deploy & rollback procedures
    ├── onboarding/               # New developer setup guide
    └── checklist/                # Software dev lifecycle checklist
```

## Skills Catalog (25 skills)

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

### Audit (1)
| Skill | Purpose |
|-------|---------|
| `saas-project-auditor` | Full-stack SaaS project audit, feature inventory, gaps, launch roadmap |

### Meta Skills (6)
| Skill | Purpose |
|-------|---------|
| `business-analyst` | PRD, user stories, business rules, personas, journey maps |
| `doc-sync-automator` | Auto-update docs when code changes |
| `bootstrap-architect` | Create/maintain bootstrap.prompt |
| `repomix-headroom-optimizer` | Token optimization setup |
| `spec-writer` | Convert ideas to SDD-format specs |
| `project-scaffolder` | Bootstrap new projects |

## Key Concepts

### bootstrap.prompt vs CLAUDE.md
| | CLAUDE.md | bootstrap.prompt |
|---|---|---|
| Load | Every message | Once per session |
| Purpose | Project facts | Reasoning anchor |
| Content | Tech stack, repo map | Golden rules, constraints |
| Token cost | Per turn | One-time |

### AutoCode Workflow
```
Spec (SDD format) → Claude Code → Code → Test → Lint → Fix → Commit
```
Self-healing loop: if tests fail, Claude reads errors and fixes automatically.

### Token Optimization Stack
```
Repomix (static)  → pack codebase ~70% compression
Headroom (dynamic) → compress runtime ~70-95%
Combined           → 80-90% total savings
```
