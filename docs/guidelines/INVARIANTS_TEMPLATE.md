# INVARIANTS.md — Hard Invariants Registry (Template)

> **Purpose:** Liệt kê **hard invariants** không được phá. Áp dụng cho mọi PR, ADR, code review, AI agent. Vi phạm = blocking gate.
>
> **Inspired by:** [rune-kit](https://github.com/rune-kit/rune) `logic-guardian` pattern + ECareHome adaptation.
>
> **How to use this template:**
> 1. Copy file này vào `<project>/docs/INVARIANTS.md` (hoặc `04-technical/INVARIANTS.md` nếu theo schema docs).
> 2. Replace placeholder `<PROJECT>`, `<MODULE>`, `<PATH>` bằng giá trị thực.
> 3. Xóa invariant không áp dụng. Thêm domain-specific invariant.
> 4. Reference từ `CLAUDE.md` của project.

---

## Cách dùng

1. **Mọi PR đụng critical path** → đọc file này trước khi viết code.
2. **AI agent (Claude Code, Cursor, Codex)** → load như context rule. Task có khả năng vi phạm → DỪNG, ASK người dùng, KHÔNG silent override.
3. **Reviewer** → checklist invariant cho code review, finding phải reference `I-XX`.
4. **CI** → grep enforcement chặn merge.
5. Invariant số hoá `I-XX` — dùng exact ID khi reference, không paraphrase.

---

## Categories — Pick what applies

### A. Architecture Invariants

#### I-01 · Core Module Immutability

**Rule:** Liệt kê các module core của `<PROJECT>`. Chỉ sửa trong N trường hợp (CVE / P0 prod bug / Perf regression / Compliance / Capability evolution).

**Cores:** `<list>`

**Cấm:**
- Thêm business logic biến động vào core → đi qua Rules Engine / Feature Service.
- Cross-module direct import.
- Hardcode rules đáng lẽ là config.

**Bắt buộc khi vi phạm:** ADR `docs/adr/ADR-YYYY-MM-DD-<slug>.md`, ≥2 reviewer, label gate trên CI.

---

#### I-02 · State Machine Transition Integrity

**Rule:** Mọi FSM transition phải đi qua `<service>.Transition()`. Không raw `UPDATE` status column.

**Cấm:**
- Skip state.
- Bypass FSM bằng admin override không qua audit.
- Thêm trạng thái mới mà không update spec.

**Test gate:** Property test N concurrent transitions, FSM invariant holds.

---

### B. Data Integrity Invariants

#### I-03 · Transactional Outbox / Saga for Side-Effects

**Rule:** Mọi side-effect (DB + external API + queue + notification) PHẢI đi qua **transactional outbox + saga**.

**Cấm:**
- Naked external call từ HTTP handler.
- Mutation ngoài saga boundary.
- Bỏ qua idempotency table khi user-facing.

**Bắt buộc:**
- Composite idempotency key, window ≥24h cho payment/critical action.
- Stuck-state reaper cron.
- Daily reconciliation external vs internal ledger.

---

#### I-04 · Money Math Integer Smallest Unit

**Rule:** Mọi monetary value lưu/transmit dưới dạng **integer (smallest unit)**. KHÔNG `float`/`decimal` parse trong API contract.

**Cấm:**
- `float64 amount` trong struct.
- `parseFloat` trên payment payload.
- Làm tròn ở DB layer (chỉ ở UI).

**Lý do:** Float drift → reconciliation sai → audit fail.

---

#### I-05 · Audit Log Hash-Chain Append-Only

**Rule:** `audit_log` phải có:
- Hash-chain `SHA256(prev_hash || payload_hash)`.
- DB-level append-only (RLS + trigger + revoked GRANT).
- Retention tier per event class.
- Verify CLI weekly.

**Cấm:**
- Bất kỳ raw `DELETE FROM audit_log`.
- Soft delete bằng cột flag.
- Bỏ qua audit cho high-priority class: auth, RBAC, financial, admin actions, core data change.

---

### C. Security & Privacy Invariants

#### I-06 · Data Classification Boundaries

**Rule:** Mọi field phân loại tier (Public / Internal / Confidential / Restricted / Location / Financial). Tier quyết định:
- Encryption at-rest (Confidential+).
- Access logging (Confidential+ → audit).
- RBAC scope.
- Retention.

**Cấm:**
- Log Restricted (PII, KYC) ra stdout/file/Sentry.
- Cache Financial trong Redis không TTL.
- Trả Location ngoài geofence cho phép.

---

#### I-07 · Idempotency for All User-Facing Mutations

**Rule:** Mọi POST/PUT/DELETE từ user app accept `Idempotency-Key`, lưu DB, replay response trong window ≥24h.

**Cấm:**
- Mutation endpoint không idempotency check.
- Generate key server-side cho user action.
- Window <24h cho payment.

---

### D. Process Invariants

#### I-08 · No Skip-Hooks / No --no-verify

**Rule:** Mọi commit qua pre-commit hook (lint + test + secret scan). Bypass cần CTO approve.

**Cấm:**
- `--no-verify`, `--no-gpg-sign`.
- Bypass CI status check.
- Force push vào protected branch.

---

#### I-09 · ADR Required for Core Touch

**Rule:** PR đụng core path → ADR file `docs/adr/ADR-YYYY-MM-DD-<slug>.md` trước merge. Label gate chặn merge.

**Cấm:**
- Merge core PR không ADR (kể cả "trivial fix" — vẫn cần expedited ADR).
- ADR backdated sau merge.

---

### E. Domain-Specific Slots (fill per project)

#### I-10 · `<DOMAIN>` Specific

**Rule:** _(define per project — e.g., DD SOS 3-Tier, Robot remote diagnosis, Escrow window, ML model rollback)_

---

## §10 · CI Enforcement Hooks

CI checks chặn merge nếu phát hiện vi phạm:

| Check | Tool | Invariant |
|-------|------|-----------|
| Forbidden cross-module imports | `<lang>` analyzer | I-01 |
| Raw SQL on FSM column | grep + AST | I-02 |
| Direct external call outside saga | grep | I-03 |
| `float` in money struct | linter | I-04 |
| `DELETE FROM audit_log` | grep | I-05 |
| Restricted data in logger | grep + AST | I-06 |
| Mutation endpoint without idempotency middleware | route registry scan | I-07 |
| `--no-verify` in commit metadata | git hook | I-08 |
| Core path PR without ADR label | branch protection | I-09 |

---

## §11 · How AI Agents Should Use This

**Trước khi viết code:**

1. Đọc invariants tương ứng domain task.
2. Task có khả năng phá invariant → STOP, hỏi user, đề xuất alternative (Rules Engine, Feature Service, ADR path).
3. PR description list invariant nào preserved hoặc cần re-validate.

**Trong code review:**

- Mỗi finding reference `I-XX` cụ thể.
- "Looks risky" không đủ — phải nói "vi phạm I-03 vì gọi external ngoài saga".

**Khi memory/context conflict với INVARIANTS.md:**

- File này là **single source of truth** cho hard rules.
- Conflict → trust file này, update memory.

---

## §12 · Changelog

| Ngày | Version | Thay đổi | Owner |
|------|---------|----------|-------|
| YYYY-MM-DD | v1.0 | Initial draft | `<owner>` |

**Next review:** sau milestone X — re-validate dựa trên incident log + chaos drill report.
