# AI Agent Baseline — Universal Guidelines

> **Purpose:** Behavioral baseline cho mọi AI coding agent (Claude Code, Cursor, Codex, Windsurf, Antigravity) làm việc trong project áp dụng skills framework này.
>
> **Sources distilled:**
> - [Andrej Karpathy CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills) — 4 light principles.
> - **Universal Engineering Task Protocol** (5-section pre-task) — heavy code-task discipline.
> - [Rune skill mesh](https://github.com/rune-kit/rune) — workflow chains + INVARIANTS pattern.
>
> **How to apply:**
> 1. Copy hoặc reference file này từ project root `CLAUDE.md`.
> 2. Layer 1 (luôn áp dụng): §1 Karpathy 4 principles.
> 3. Layer 2 (khi code task có test suite): §2 Universal Protocol.
> 4. Layer 3 (large project có core module): §3 INVARIANTS.md + workflow chains.

---

## §1 · Karpathy 4 Principles (Universal — always apply)

### 1.1 Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. Uncertain → ask.
- Multiple interpretations → present, don't pick silently.
- Simpler approach exists → say so. Push back when warranted.
- Unclear → STOP. Name what's confusing. Ask.

### 1.2 Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" not requested.
- No error handling for impossible scenarios.
- 200 lines that could be 50 → rewrite.

Test: "Would a senior engineer say this is overcomplicated?"

### 1.3 Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code/comments/formatting.
- Don't refactor things that aren't broken.
- Match existing style.
- Notice unrelated dead code → mention, don't delete.
- Remove imports/vars/funcs YOUR changes orphaned. Don't remove pre-existing dead code.

Test: every changed line traces to user request.

### 1.4 Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

Multi-step → state plan with verify check per step.

---

## §2 · Universal Engineering Task Protocol (Code task with test suite)

Áp dụng khi: project có code thật + test suite + CI. KHÔNG áp dụng cho doc-only edits.

### 2.1 Impact Analysis

**Files affected:**
- List tất cả files thay đổi (source, config, migration, test, infra).
- Mỗi file: confirm tồn tại + read exact content trước khi viết anchor/patch.
- Không assume path/content — verify thực tế.

**I/O of mọi function mới/sửa:**
- Signature đầy đủ: input types, output types, exceptions.
- Import pattern (top-level vs lazy → ảnh hưởng mock target).
- Fail-open behavior: mọi error path có kết quả rõ ràng.
- Side effects: storage write (DB, cache key, file, queue).

### 2.2 Before / After Flow + Risk Check

**Flow BEFORE:** mô tả với code evidence.
**Flow AFTER:** mô tả, chỉ rõ điểm đổi.

**Risk check 5 điểm bắt buộc:**
- **RC-1** Race condition / concurrency hot path?
- **RC-2** Breaking change với caller hiện tại?
- **RC-3** Backward compatibility (DB schema, API contract, config)?
- **RC-4** Performance overhead (CPU, memory, latency)?
- **RC-5** Fail-open hay fail-closed khi dependency lỗi?

Mỗi điểm: ✅ safe / ⚠️ risk + mitigation cụ thể.

### 2.3 Verify Before Apply

Thứ tự bắt buộc:

1. **Logic test (no I/O)** — unit test thuần logic.
2. **Dependency mock** — verify interaction với external (DB, cache, queue, API). Đúng key/query/payload?
3. **Integration** — end-to-end với mock, đúng output?
4. **Anchor verification** — anchor xuất hiện đúng 1 lần trong file target.
   - Count ≠ 1 → ABORT, tìm anchor mới.
5. **Syntax check** sau apply — parse/lint file đã patch.

Tất cả PASS → apply. Fail → fix logic trước.

### 2.4 Validate After Apply

- Run test mới riêng → pass hoàn toàn.
- Run full test suite → số test tăng = số mới thêm, zero regression.
- Regression → không commit, root cause ngay.
- Kiểm tra invariants quan trọng (xem INVARIANTS.md).

### 2.5 Commit + Recovery Plan

**Commit:** conventional commits (`<type>(<scope>): <title>`). Body: functions mới/sửa, files thay đổi, wire points, invariants preserved. Footer: `Tests: +N | Total: XXXX passed`.

**Recovery plan (phải có cho mọi task):**
- Trước khi bắt đầu: `git stash` hoặc `git tag checkpoint-<name>`.
- File corrupt: `git checkout HEAD -- <file>`.
- Migration fail: rollback script viết sẵn TRƯỚC apply.
- Infra/config fail: feature flag để disable.
- Test regression sau commit: `git revert` ngay.

---

## §3 · INVARIANTS + Workflow Chains (Large project layer)

### 3.1 INVARIANTS.md is Source of Truth

Project có file `docs/INVARIANTS.md` (template tại [INVARIANTS_TEMPLATE.md](INVARIANTS_TEMPLATE.md)) → load nó làm hard rule. Conflict với memory/context → trust INVARIANTS.md.

### 3.2 Workflow Chains (inspired by Rune)

Khi task large/complex, follow chain:

| User intent | Chain | Skip rules |
|-------------|-------|-----------|
| "implement feature X" | scout → plan → test → cook → verify | Skip plan chỉ nếu <50 LOC + 1 file |
| "fix bug X" | reproduce-test → debug → fix → verify | Không skip reproduce-test |
| "refactor X" | tests-pass-before → refactor → tests-pass-after | Bắt buộc full chain |
| "deploy/ship" | verify → security-check → preflight → launch | Không skip security |
| "research X" | triangulate ≥2 source → cite → summarize | 1-source = noise |

### 3.3 User Intent → Skill Routing

Project có sub-agents (Explore, Plan, etc.) → invoke trước khi tự làm:
- "explore", "find", "search broad" → Explore agent
- "plan implementation", "design architecture" → Plan agent
- "review code" → Code Reviewer
- "security check" → Security Review

Không "mentally apply" — invoke thật để có dedicated context window.

## §4 · AI Session Management (Handoff Workflow)

Đối với các dự án lớn (Monorepo/Multi-services), AI có nguy cơ mất ngữ cảnh (context) khi làm việc trong thời gian dài hoặc chuyển đổi giữa các task. Để giải quyết, hãy thiết lập **Session Handoff**:

### 4.1 Local `.ai-sessions` in Active Repos
- **KHÔNG** lưu tập trung ở Workspace/Root Folder của toàn bộ hệ sinh thái.
- **BẮT BUỘC** mỗi repository con (VD: `frontend-app`, `backend-api`) phải có thư mục `.ai-sessions/` riêng lẻ để đảm bảo bảo mật mã nguồn và phân quyền.

### 4.2 End of Session (Kết thúc ca làm việc)
- Tự động sinh hoặc cập nhật file `SESSION_SUMMARY_<date>.md` tại `.ai-sessions/` của repo hiện tại.
- Ghi chú rõ: Task đang in-progress, Invariants bị ảnh hưởng, bug đang fix.
- (Xem mẫu: `templates/ai-session-summary.md`)

### 4.3 Start of Session (Bắt đầu ca làm việc)
- User sẽ dùng prompt mồi để AI đọc lại `CLAUDE.md` và `SESSION_SUMMARY`.
- Tự động xác định lại Persona (Frontend, Backend, BA...) trước khi nhận lệnh mới.
- (Xem mẫu: `templates/ai-session-prompt.txt`)

---

## §5 · Anti-Patterns (always avoid)

- ❌ "Let me also clean up while I'm here" (vi phạm Surgical Changes).
- ❌ Add config/flag/abstraction for hypothetical future need.
- ❌ Defensive try/catch quanh code không thể fail.
- ❌ Comment giải thích WHAT (code đã nói rồi). Chỉ comment WHY non-obvious.
- ❌ Skip pre-commit hook bằng `--no-verify`.
- ❌ Force push protected branch.
- ❌ Run destructive command (drop, reset --hard, rm -rf) không user confirm.
- ❌ Edit file mà không Read trước.
- ❌ Trust memory > current code state khi conflict.

---

## §6 · How to Reference From Project CLAUDE.md

Trong `<project>/CLAUDE.md`:

```markdown
## AI Agent Baseline

This project follows [AI_AGENT_BASELINE.md](D:/Code/skills/docs/guidelines/AI_AGENT_BASELINE.md):

- **§1 Karpathy 4 principles** — always.
- **§2 Universal Protocol** — applies for code edits in `<paths>` (skip for `docs/`).
- **§3 INVARIANTS** — see [docs/INVARIANTS.md](./docs/INVARIANTS.md).
```

---

## §7 · Changelog

| Date | Version | Change |
|------|---------|--------|
| 2026-04-25 | v1.0 | Initial — distill Karpathy + Universal Protocol + Rune patterns |
| 2026-04-28 | v1.1 | Bổ sung quy trình AI Session Management (Handoff) phân tán theo repo |
