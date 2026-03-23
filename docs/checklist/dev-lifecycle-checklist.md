# Software Development Lifecycle Checklist

A comprehensive checklist for setting up a production-grade software project. Derived from real-world experience building multi-service systems.

## Pre-Phase: Business Documentation

> **Complete business documentation BEFORE starting technical phases.**
> See [business-docs-checklist.md](business-docs-checklist.md) for the full 7-group, 42-item checklist covering: Vision & Strategy, Product Requirements, UX Design, Technical Architecture, Operations, Legal, and Testing & Quality.

- [ ] Business documentation checklist reviewed and prioritized for project scope (MVP/Startup/Production/Enterprise)

---

## Phase 0: Foundation

### Project Identity
- [ ] `CLAUDE.md` — project master guide (what, why, how)
- [ ] `.claude/bootstrap.prompt` — reasoning anchor (constraints, golden rules)
- [ ] `README.md` — quick start, overview, links

### Architecture
- [ ] Architecture Decision Records (ADRs) — document key decisions
- [ ] System overview & data flow diagram
- [ ] Entity Relationship Diagram (ERD) & database schema
- [ ] State machine definitions (if applicable)
- [ ] API contracts & shared type definitions
- [ ] Inter-service communication map (sync/async)

### Repository Structure
- [ ] Repository layout decided (monorepo vs multi-repo)
- [ ] Package manager & workspace config (Turborepo, pnpm, Go workspaces)
- [ ] `.gitignore` configured for all languages
- [ ] `.editorconfig` for consistent formatting

---

## Phase 1: Standards & Process

### Coding Standards
- [ ] Language-specific coding standards documented
- [ ] Linter configs set up per language (ESLint, golangci, Clippy, Ruff)
- [ ] Formatter configs (Prettier, gofmt, rustfmt, Black/Ruff)
- [ ] Pre-commit hooks (lint-staged, commitlint)
- [ ] Conventional Commits enforced

### Git Workflow
- [ ] Branch strategy documented (trunk-based, GitFlow, etc.)
- [ ] Branch naming convention (feat/, fix/, chore/)
- [ ] PR template with checklist
- [ ] Code review guidelines

### Testing Strategy
- [ ] Test pyramid defined (unit/integration/E2E ratios)
- [ ] Coverage targets per language/service
- [ ] Test naming conventions
- [ ] Mock/stub strategy
- [ ] Performance test benchmarks

### Security
- [ ] Security guidelines documented
- [ ] Secret management strategy (env vars, vault, HSM)
- [ ] Authentication/authorization patterns
- [ ] Input validation strategy
- [ ] Dependency scanning enabled

### Process
- [ ] Bug fix process documented
- [ ] Release process documented (versioning, changelog, tagging)
- [ ] Incident response procedure

---

## Phase 2: Specifications

### Product
- [ ] User personas defined
- [ ] Business workflow diagrams (main flows)
- [ ] Feature specifications (SDD format)

### Testing
- [ ] Test scenarios documented (by flow)
- [ ] Edge cases identified
- [ ] Performance benchmarks defined
- [ ] Security test scenarios

---

## Phase 3: Infrastructure

### Local Development
- [ ] Docker Compose for local dev
- [ ] Environment variable templates (`.env.example`)
- [ ] Database migration setup
- [ ] Seed data scripts
- [ ] Local deployment guide (step-by-step)

### CI/CD
- [ ] CI pipeline per language (test, lint, build)
- [ ] Security scanning pipeline (SAST, SCA)
- [ ] Build & publish pipeline (Docker images, packages)
- [ ] Deployment pipeline (staging → production)

### Configuration
- [ ] Makefile per language (common targets)
- [ ] Docker Compose for services (messaging, databases)
- [ ] Linter/formatter configs centralized

---

## Phase 4: Operations

### Deployment
- [ ] Deployment runbook (step-by-step)
- [ ] Rollback procedures
- [ ] Health check endpoints
- [ ] Smoke test scripts

### Monitoring & Alerting
- [ ] Logging standards (structured logging)
- [ ] Metrics collection (Prometheus, Grafana, etc.)
- [ ] Alerting rules (SLOs, error rates)
- [ ] Dashboard setup

### Recovery
- [ ] Backup strategy
- [ ] Disaster recovery plan
- [ ] Incident recovery runbooks

---

## Phase 5: Team & Community

### Onboarding
- [ ] New developer setup guide
- [ ] Architecture overview walkthrough
- [ ] Key codebase tour (critical paths)
- [ ] Access & permissions guide

### Templates
- [ ] PR template
- [ ] Bug report template
- [ ] Feature request template
- [ ] Root cause analysis (RCA) template
- [ ] Changelog template

### Community
- [ ] Contributing guide
- [ ] Code of conduct
- [ ] Security disclosure policy

---

## Phase 6: AI-Augmented Development

### Skills Framework
- [ ] Claude Code skills configured (`.claude/skills/`)
- [ ] `bootstrap.prompt` created and validated
- [ ] AutoCode system configured (`autocode/autocode.config`)
- [ ] Spec template available (`SPEC_TEMPLATE.md`)

### Token Optimization
- [ ] Repomix configured for codebase packing
- [ ] Headroom configured for dynamic compression
- [ ] `.repomix-output.*` in `.gitignore`

### Automation
- [ ] Doc sync automation ready
- [ ] Spec-driven development workflow established
- [ ] Phase-based execution plan (if multi-phase project)

---

## Usage

Copy this checklist to your project and check off items as you complete them:
```bash
cp docs/checklist/dev-lifecycle-checklist.md your-project/docs/checklist.md
```

Not every project needs every item. Use judgment:
- **Solo project / MVP**: Phase 0 + minimal Phase 1 + Phase 6
- **Small team (2-5)**: Phase 0-2 + Phase 5 + Phase 6
- **Production system**: All phases
- **Enterprise**: All phases + compliance addendum
