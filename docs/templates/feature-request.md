# Feature Request Template

Use this template when proposing new features for any Project repository.

---

**Title format:** `[FEATURE] Short description of the feature`

---

## User Story

As a **[role]**,
I want **[feature/capability]**,
so that **[benefit/value]**.

<!-- Example: As a customs officer, I want to scan a QR code on a shipment, so that I can verify the certificate of origin in real time. -->

## Problem Statement

<!-- What problem does this feature solve? Why is it needed now? -->

## Proposed Solution

<!-- Describe the feature at a high level. How should it work from the user's perspective? -->

## Acceptance Criteria

<!-- Define what "done" looks like. Use checkboxes. -->

- [ ] <!-- Criterion 1: e.g., User can upload a CSV of HS codes -->
- [ ] <!-- Criterion 2: e.g., System validates each HS code against the reference database -->
- [ ] <!-- Criterion 3: e.g., Invalid codes are highlighted with error messages -->
- [ ] <!-- Criterion 4: e.g., Valid import generates an event on the event chain -->
- [ ] <!-- Add more as needed -->

## Affected Services / Repositories

<!-- Which Project components will need changes? Select all that apply. -->

- [ ] myproject-core
- [ ] myproject-frontend
- [ ] myproject-crypto
- [ ] myproject-compliance
- [ ] myproject-ingestion
- [ ] myproject-ai
- [ ] myproject-infra
- [ ] myproject-docs

**Specific services/modules:**
<!-- e.g., event-chain-service, co-engine, QR verify app -->

## Design Mockup

<!-- For UI features, attach wireframes, mockups, or screenshots of the proposed design. -->
<!-- For API features, include example request/response payloads. -->

## Technical Considerations

<!-- Optional: Any known technical constraints, dependencies, or architectural decisions. -->
<!-- e.g., "Requires a new Kafka topic", "Needs External API v2 support" -->

## Priority Suggestion

<!-- Select one -->
- [ ] **Critical** — Blocks a major workflow or customer commitment
- [ ] **High** — Important for upcoming release
- [ ] **Medium** — Valuable but not time-sensitive
- [ ] **Low** — Nice to have

## Alternatives Considered

<!-- What other approaches were considered? Why is the proposed solution preferred? -->

---

**Requester:** <!-- Your name or GitHub handle -->
**Date:** <!-- YYYY-MM-DD -->
