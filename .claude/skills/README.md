# AI Agent Skills — Skills Framework

Curated agent personas from [agency-agents](https://github.com/msitarzewski/agency-agents) (MIT license), extended with meta-skills for AI-augmented development.

## How to use

These skills are available as Claude Code slash commands when working in this repository. Each provides specialized expertise for a specific development role.

## Included Agents (25)

### Engineering (11)
| Agent | Use for |
|-------|---------|
| `engineering-backend-architect` | Go/Rust API design, service architecture |
| `engineering-software-architect` | System design, DDD, architectural patterns |
| `engineering-database-optimizer` | PostgreSQL query tuning, indexing, scaling |
| `engineering-sre` | Monitoring, SLOs, incident response |
| `engineering-devops-automator` | CI/CD pipelines, K8s/Helm, infrastructure |
| `engineering-security-engineer` | Security audits, key rotation, audit logging |
| `engineering-code-reviewer` | PR review for Go/Rust/TypeScript/Python |
| `engineering-frontend-developer` | Next.js, React, UI/UX implementation |
| `engineering-senior-developer` | General full-stack development |
| `engineering-technical-writer` | Documentation, ADRs, API docs |
| `engineering-data-engineer` | Data pipelines, event streaming, ETL |

### Testing (3)
| Agent | Use for |
|-------|---------|
| `testing-api-tester` | API contract tests, endpoint validation |
| `testing-performance-benchmarker` | Latency, throughput, load testing |
| `testing-workflow-optimizer` | E2E workflow testing, integration tests |

### Domain-Specific (5)
| Agent | Use for |
|-------|---------|
| `supply-chain-strategist` | Supply chain domain logic, traceability flows |
| `compliance-auditor` | Regulatory compliance, audit trails |
| `blockchain-security-auditor` | ZK circuits, blockchain security review |
| `agents-orchestrator` | Multi-agent project coordination |
| `specialized-workflow-architect` | Business process automation |

### Audit (1)
| Agent | Use for |
|-------|---------|
| `saas-project-auditor` | Full-stack SaaS project audit: feature inventory, security gaps, infra readiness, strategic GTM |

### Meta Skills (6)
| Agent | Use for |
|-------|---------|
| `business-analyst` | Create PRD, user stories, business rules, personas, journey maps |
| `doc-sync-automator` | Auto-update docs when code changes |
| `bootstrap-architect` | Create/maintain bootstrap.prompt |
| `repomix-headroom-optimizer` | Token optimization with Repomix + Headroom |
| `spec-writer` | Convert ideas to SDD-format specifications |
| `project-scaffolder` | Bootstrap new projects with skills framework |

## Customization

- **Add skills:** Create new `.md` files with YAML frontmatter (name, description, emoji, color)
- **Remove skills:** Delete files you don't need
- **Domain skills:** The 5 domain-specific skills may need customization for non-supply-chain projects

## Source
MIT License — https://github.com/msitarzewski/agency-agents
