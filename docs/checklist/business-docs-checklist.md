# Business Documentation Checklist

Complete these documents **BEFORE** starting technical implementation. This ensures the development team (human or AI) has clear requirements, reducing rework and miscommunication.

## Scope Guide

Not every project needs every document. Use this guide:

| Level | When | Groups needed |
|-------|------|---------------|
| **MVP** | Solo/small team, testing market fit | 1 (partial) + 2 (core) + 4 (minimal) |
| **Startup** | Seed/Series A, building v1 | 1 + 2 + 3 (partial) + 4 + 7 (partial) |
| **Production** | Revenue-generating, real users | All groups |
| **Enterprise** | Compliance-heavy, regulated industry | All groups + extra in 6 |

---

## Group 1 — Vision & Strategy

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 1.1 | [ ] **Product Vision Document** | Define: what is this, what problem does it solve, for whom, how is it different — in 1 page | ✅ | ✅ |
| 1.2 | [ ] **Business Model Canvas** | 1-page diagram: customers, value proposition, channels, revenue, costs, partners | ✅ | ✅ |
| 1.3 | [ ] **Competitive Analysis** | Detailed comparison vs competitors: features, pricing, weaknesses, differentiation | | ✅ |
| 1.4 | [ ] **Go-to-Market Plan (GTM)** | Launch strategy: target region, marketing channels, KPIs for first month | | ✅ |

---

## Group 2 — Product Requirements (Most Critical)

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 2.1 | [ ] **Product Requirements Document (PRD)** | Detailed description of every feature: who uses it, what it does, expected outcome | ✅ | ✅ |
| 2.2 | [ ] **User Stories** | Rewrite features as: "As [who], I want [what], so that [goal]" — standard format for dev and AI | ✅ | ✅ |
| 2.3 | [ ] **Acceptance Criteria** | Pass/fail criteria for each user story: when is a feature "done correctly"? | ✅ | ✅ |
| 2.4 | [ ] **Use Case Diagram** | Visual: which actors (Customer/Worker/Admin) interact with which functions | | ✅ |
| 2.5 | [ ] **Business Rules Document** | Hard rules: deposit amounts, penalty rates, warranty periods, permissions per role | ✅ | ✅ |
| 2.6 | [ ] **Feature Priority Matrix** | Rank features by: business value × technical complexity → decide Phase 1/2/3 | ✅ | ✅ |

---

## Group 3 — User Experience Design

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 3.1 | [ ] **User Personas** | 3-4 representative user profiles with demographics, goals, pain points, tech comfort | | ✅ |
| 3.2 | [ ] **User Journey Maps** | Step-by-step journey per persona: discover → engage → complete task — with emotions and pain points | | ✅ |
| 3.3 | [ ] **Information Architecture (IA)** | App navigation tree: which screens exist, how they connect, what's in each tab | ✅ | ✅ |
| 3.4 | [ ] **User Flow Diagrams** | Detailed flow for each key task: booking, payment, dispute resolution, withdrawal | ✅ | ✅ |
| 3.5 | [ ] **Wireframes (Lo-fi)** | Rough layout of each screen — not pretty, just correct placement of elements | ✅ | ✅ |
| 3.6 | [ ] **UI Design System** | Colors, fonts, sizes, button styles, icon set — consistent across entire app | | ✅ |
| 3.7 | [ ] **Hi-fi Mockups (Figma)** | Pixel-perfect design of every screen, including light/dark mode | | ✅ |
| 3.8 | [ ] **Interactive Prototype** | Clickable Figma prototype to test with real users before coding | | ✅ |

---

## Group 4 — Technical Architecture

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 4.1 | [ ] **System Architecture Document** | Overall diagram: App → API Gateway → Services → DB → Cache → Queue. Justify each tech choice | ✅ | ✅ |
| 4.2 | [ ] **Database Schema** | All tables, columns, data types, relationships, indexes, enums | ✅ | ✅ |
| 4.3 | [ ] **Entity Relationship Diagram (ERD)** | Visual diagram of tables and relationships — faster to understand than raw SQL | ✅ | ✅ |
| 4.4 | [ ] **API Design (OpenAPI/Swagger)** | Full API endpoint definitions: URL, method, request body, response, error codes | ✅ | ✅ |
| 4.5 | [ ] **Sequence Diagrams** | Interaction sequences for complex flows: booking, matching, payment, AI diagnosis | | ✅ |
| 4.6 | [ ] **State Machine Diagrams** | State transitions: Order (pending → assigned → in_progress → completed), User statuses | | ✅ |
| 4.7 | [ ] **AI/ML Agent Design** *(if applicable)* | Each AI agent: purpose, input/output, tools, prompts, fallback behavior | | ✅ |
| 4.8 | [ ] **Infrastructure Design** | Cloud diagram: servers, capacity, networking, firewall, CDN, backup strategy | | ✅ |
| 4.9 | [ ] **Security Design Document** | Security model: authentication, authorization, encryption, API protection, compliance | | ✅ |
| 4.10 | [ ] **Data Flow Diagram (DFD)** | Where data flows from/to — critical for AI features and data privacy | | ✅ |
| 4.11 | [ ] **Integration Specifications** | Third-party integrations: payment APIs, SMS, maps, AI APIs — format, auth, webhooks | ✅ | ✅ |

---

## Group 5 — Operations & Processes

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 5.1 | [ ] **Operational Runbook** | Daily ops: how to handle complaints, approve new workers, process refunds | | ✅ |
| 5.2 | [ ] **Incident Response Plan** | When things go wrong (outage, security breach, major incident): who does what at 0/1/4/24h | | ✅ |
| 5.3 | [ ] **SLA & KPI Document** | Service level commitments: response time, uptime, complaint resolution time — how to measure | | ✅ |
| 5.4 | [ ] **Onboarding Playbook** | Step-by-step process to onboard workers/partners: documents, verification, training, mentoring | | ✅ |
| 5.5 | [ ] **Customer Support Playbook** | Scripts for handling each situation type: complaints, delays, errors, refund requests | | ✅ |
| 5.6 | [ ] **Fraud & Risk Policy** | Detection and handling: fraudulent accounts, off-platform transactions, fake reviews | | ✅ |

---

## Group 6 — Legal & Contracts

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 6.1 | [ ] **Terms of Service** | User rights and obligations when using the app — requires legal review | ✅ | ✅ |
| 6.2 | [ ] **Privacy Policy** | What data is collected, retention period, sharing, user rights — required by data protection laws | ✅ | ✅ |
| 6.3 | [ ] **Partner/Contractor Agreements** | Collaboration terms: deposits, violations, non-solicitation, penalty mechanisms | | ✅ |
| 6.4 | [ ] **AI Disclosure Statement** *(if applicable)* | Clear disclosure: where AI is used, AI limitations, complaint process for AI errors | | ✅ |
| 6.5 | [ ] **Payment/Escrow Agreements** | Contract with payment providers for escrow/holding mechanisms | | ✅ |
| 6.6 | [ ] **Insurance/Partnership Agreements** *(if applicable)* | Insurance agency contracts: rights, obligations, commission rates, claims process | | ✅ |

---

## Group 7 — Testing & Quality

| # | Document | Purpose | MVP | Prod |
|---|----------|---------|-----|------|
| 7.1 | [ ] **Test Strategy Document** | Overall test approach: unit, integration, UAT, performance — who does what, which tools | ✅ | ✅ |
| 7.2 | [ ] **Test Cases** | Detailed test scenarios per feature — typically 3-5 test cases per feature | | ✅ |
| 7.3 | [ ] **UAT Plan** | User acceptance testing: who participates, what to test, feedback format, pass/fail criteria | | ✅ |
| 7.4 | [ ] **Performance Benchmarks** | Performance targets: API response < 200ms, app load < 2s, search < 1s — measured with k6/Lighthouse | | ✅ |
| 7.5 | [ ] **Security Audit Checklist** | OWASP checklist, JWT validation, SQL injection, rate limiting, API key exposure | ✅ | ✅ |
| 7.6 | [ ] **AI Quality Evaluation** *(if applicable)* | AI accuracy testing: test with real data, measure precision/recall, compare with human experts | | ✅ |

---

## Execution Order

```
1. Vision & Strategy (Group 1)     ← Start here: know WHAT you're building
   ↓
2. Product Requirements (Group 2)  ← Most critical: define EVERY feature clearly
   ↓
3. UX Design (Group 3)            ← Design BEFORE coding
   ↓
4. Technical Architecture (Group 4) ← Now plan HOW to build it
   ↓
5. Legal & Contracts (Group 6)     ← In parallel with Group 4
   ↓
6. Operations (Group 5)            ← Before launch
   ↓
7. Testing & Quality (Group 7)     ← Throughout development, formalized before launch
```

## Usage

Copy this checklist to your project:
```bash
cp docs/checklist/business-docs-checklist.md your-project/docs/business-checklist.md
```

Mark items as you complete them: `- [ ]` → `- [x]`
