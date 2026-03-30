# AI Agent Skills — Skills Framework

Curated agent personas from [agency-agents](https://github.com/msitarzewski/agency-agents) (MIT license), extended with meta-skills for AI-augmented development.

## How to use

These skills are available as Claude Code slash commands when working in this repository. Each provides specialized expertise for a specific development role.

## Included Agents (32)

### Engineering (15)
| Agent | Model | Use for |
|-------|-------|---------|
| `engineering-backend-architect` | opus | Go/Rust API design, service architecture |
| `engineering-software-architect` | opus | System design, DDD, architectural patterns |
| `engineering-rust-developer` | sonnet | Idiomatic Rust, async services, axum/sqlx, multi-crate workspaces |
| `engineering-debugger` | opus | Systematic debugging, root cause analysis, Rust async diagnosis |
| `engineering-migration-agent` | sonnet | Database migrations, dependency upgrades, breaking changes |
| `engineering-incident-responder` | opus | Active incident management, mitigation playbooks, post-mortems |
| `engineering-database-optimizer` | sonnet | PostgreSQL query tuning, indexing, scaling |
| `engineering-sre` | sonnet | Monitoring, SLOs, reliability engineering |
| `engineering-devops-automator` | sonnet | CI/CD pipelines, K8s/Helm, infrastructure |
| `engineering-security-engineer` | opus | Security audits, key rotation, audit logging |
| `engineering-code-reviewer` | sonnet | PR review for Go/Rust/TypeScript/Python |
| `engineering-frontend-developer` | sonnet | Next.js, React, UI/UX implementation |
| `engineering-senior-developer` | sonnet | General full-stack development (Laravel/Livewire/FluxUI) |
| `engineering-technical-writer` | haiku | Documentation, ADRs, API docs |
| `engineering-data-engineer` | sonnet | Data pipelines, event streaming, ETL |

### Testing (3)
| Agent | Model | Use for |
|-------|-------|---------|
| `testing-api-tester` | sonnet | API contract tests, endpoint validation |
| `testing-performance-benchmarker` | sonnet | Latency, throughput, load testing |
| `testing-workflow-optimizer` | sonnet | E2E workflow testing, integration tests |

### Domain-Specific (5)
| Agent | Model | Use for |
|-------|-------|---------|
| `supply-chain-strategist` | sonnet | Supply chain domain logic, traceability flows |
| `compliance-auditor` | sonnet | Regulatory compliance, audit trails |
| `blockchain-security-auditor` | opus | ZK circuits, blockchain security review |
| `agents-orchestrator` | opus | Multi-agent project coordination |
| `specialized-workflow-architect` | sonnet | Business process automation |

### Research (1)
| Agent | Model | Use for |
|-------|-------|---------|
| `deep-research` | opus | Multi-angle web research (4-phase: Broad → Deep → Diversity → Synthesis) |

### Audit (1)
| Agent | Model | Use for |
|-------|-------|---------|
| `saas-project-auditor` | opus | Full-stack SaaS audit: features, security, infra, GTM |

### Meta Skills (7)
| Agent | Model | Use for |
|-------|-------|---------|
| `business-analyst` | sonnet | Create PRD, user stories, business rules, personas, journey maps |
| `doc-sync-automator` | haiku | Auto-update docs when code changes |
| `bootstrap-architect` | haiku | Create/maintain bootstrap.prompt |
| `repomix-headroom-optimizer` | haiku | Token optimization with Repomix + Headroom |
| `spec-writer` | sonnet | Convert ideas to SDD-format specifications |
| `agent-bootstrap` | sonnet | Create agent personas/CLAUDE.md through adaptive onboarding |
| `project-scaffolder` | sonnet | Bootstrap new projects with skills framework |

---

## Magic Keyword Registry

Start a message with one of these keywords to auto-trigger the corresponding skill.

| Keyword | Triggers Skill | Priority | Model |
|---------|---------------|----------|-------|
| `autopilot` | agents-orchestrator | 1 | opus |
| `debug` | engineering-debugger | 2 | opus |
| `incident` | engineering-incident-responder | 2 | opus |
| `architect` | engineering-software-architect | 3 | opus |
| `rust` | engineering-rust-developer | 3 | sonnet |
| `migrate` | engineering-migration-agent | 3 | sonnet |
| `review` | engineering-code-reviewer | 4 | sonnet |
| `test` | testing-api-tester | 4 | sonnet |
| `optimize` | engineering-database-optimizer | 4 | sonnet |
| `research` | deep-research | 5 | opus |
| `spec` | spec-writer | 5 | sonnet |
| `secure` | engineering-security-engineer | 5 | opus |
| `audit` | saas-project-auditor | 5 | opus |
| `devops` | engineering-devops-automator | 5 | sonnet |
| `analyze` | business-analyst | 5 | sonnet |

### Conflict Resolution
When multiple keywords appear in a message:
1. **Highest priority wins** (lower number = higher priority)
2. **At same priority**, the most specific keyword wins (e.g., `debug` beats `optimize` if both present)
3. **Orchestrator override**: when running in `autopilot` mode, the orchestrator selects agents, not keywords

### Model Fallback Strategy
| Situation | Action |
|-----------|--------|
| opus unavailable/rate-limited | Fall back to sonnet with warning: "⚠️ Running at reduced reasoning tier" |
| sonnet unavailable | Fall back to haiku for non-critical tasks only; block critical tasks (debug, incident, security) and notify user |
| All models available | Use assigned tier from keyword registry |

---

## Customization

- **Add skills:** Create new `.md` files with YAML frontmatter (name, description, emoji, color, vibe, model)
- **Remove skills:** Delete files you don't need
- **Domain skills:** The 5 domain-specific skills may need customization for non-supply-chain projects
- **Model routing:** Override model tier in frontmatter (`model: opus/sonnet/haiku`)

## Source
MIT License — https://github.com/msitarzewski/agency-agents
