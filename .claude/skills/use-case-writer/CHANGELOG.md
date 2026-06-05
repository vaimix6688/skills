# Changelog · Use Case Writer

Mọi thay đổi đáng chú ý của skill này được ghi tại đây.
Format theo [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

> Phương pháp gốc maintained by **Phúc NT** · BA Zone · Digital School.

---

## [1.1.0-ech] - 2026-05-17

### ECareHome edition — Việt-hoá fork

Fork bản địa hoá từ [1.0.0] để cài vào workspace `D:/Code/skills/.claude/skills/`,
phục vụ bộ tài liệu ECareHome `ech-docs`. **Giữ nguyên 100% phương pháp gốc** —
chỉ đổi ngôn ngữ output và bộ ví dụ.

#### Changed
- **Output language rule**: English-only → **Việt-first song ngữ**. UC artifact viết
  tiếng Việt là chính, giữ technical term tiếng Anh (UC, Actor, FSM, Saga, Outbox,
  Idempotency, RBAC, ADR, SLO, MCP, Normal Course…); field label giữ tiếng Anh.
  Khớp quy ước `ech-docs/CLAUDE.md` §Doc Editing Conventions #4.
- **Worked examples**: domain EdTech / Digital School → **home-service (ECareHome)**.
  - `references/examples-edtech.md` → `references/examples-home-service.md` với 2 UC mới:
    UC-BOOK-01 (Đặt thợ sửa chữa thiết bị) và UC-DISPUTE-03 (Duyệt yêu cầu hoàn tiền tranh chấp).
  - Ví dụ trong `SKILL.md`, `template-guide.md`, `writing-style.md`, `quality-checklist.md`,
    `assets/uc-template.md` đổi sang actor home-service (Khách hàng, Thợ, CS Agent,
    CS Manager, Worker Care, Admin) và pattern ECareHome (post-pay, saga/outbox,
    RBAC I-08, audit hash-chain I-04, MoMo/VNPay, eSMS).
- **SKILL.md**: thêm mục "Tích hợp với repo ECareHome `ech-docs`" phân biệt
  requirement-UC (skill này viết) với Use Case Diagram 2.3, Comprehensive User
  Cases 2.7, và Cross-Module Design Flow 4.108.

#### Unchanged
- Workflow 4 bước (Classify → Scope → Write → Validate)
- 4 mode vận hành, sinh tuần tự 5 nhóm mục
- Checklist chất lượng 20 điểm (C1-C20)
- Scoping rule Cockburn: coffee-break test, 3 goal level, system boundary
- 3 kỹ thuật identify UC: goal-driven, event-driven, CRUD-driven
- Template 13-field

#### Attribution
- Author phương pháp gốc: Phúc NT · BA Zone · Digital School
- License: MIT kèm yêu cầu attribution (xem `LICENSE`) — giữ nguyên.

---

## [1.0.0] - 2026-05-14

### Initial release — BA Zone Edition

#### Added
- Core `SKILL.md` với workflow 4 bước (Classify → Scope → Write → Validate)
- 4 mode vận hành: viết mới, tách thành UC list, refine UC có sẵn, viết riêng 1 mục
- Sinh tuần tự 5 nhóm mục kèm confirmation gate
- Checklist chất lượng 20 điểm (nhóm A-F)
- Scoping rule Cockburn: coffee-break test, 3 goal level, system boundary
- 3 kỹ thuật identify UC: goal-driven, event-driven, CRUD-driven
- `references/template-guide.md`, `references/writing-style.md`,
  `references/quality-checklist.md`, `references/examples-edtech.md` (2 UC EdTech)
- `assets/uc-template.md` — template Markdown copy-ready

#### Attribution
- Author: Phúc NT · BA Zone · Digital School
- License: MIT kèm yêu cầu attribution
