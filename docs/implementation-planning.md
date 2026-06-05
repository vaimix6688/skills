# Implementation Planning Guide

How to write comprehensive implementation plans that AI agents can execute autonomously. Adapted from the "writing-plans" methodology.

## Core Principle

> Write plans assuming the engineer has **zero context** for your codebase and questionable taste. Document everything they need: which files to touch, code, testing, docs to check, how to test. Give them the whole plan as bite-sized tasks. **DRY. YAGNI. TDD. Frequent commits.**

## When to Write a Plan

- After a spec is approved and ready for implementation
- Before any multi-step task involving code changes
- When coordinating work across multiple files or modules

## Plan Document Structure

### Header (Required)

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

### Scope Check

If the spec covers multiple independent subsystems, suggest breaking into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

### File Structure Map

Before defining tasks, map out which files will be created or modified:

```markdown
## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `src/auth/handler.ts` | Modify | Add JWT validation |
| `src/auth/service.ts` | Create | Auth business logic |
| `tests/auth/auth.test.ts` | Create | Unit tests |
```

**Design principles:**
- Each file should have one clear responsibility
- Prefer smaller, focused files over large ones
- Files that change together should live together
- Follow existing patterns in the codebase

## Task Granularity

**Each step is one action (2-5 minutes):**

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

\`\`\`python
def test_specific_behavior():
    result = function(input)
    assert result == expected
\`\`\`

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

\`\`\`python
def function(input):
    return expected
\`\`\`

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

\`\`\`bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
\`\`\`
```

## No Placeholders — Ever

Every step must contain the actual content an engineer needs. These are **plan failures**:

| ❌ Plan Failure | ✅ What to Write Instead |
|----------------|------------------------|
| "TBD", "TODO", "implement later" | Complete code or specification |
| "Add appropriate error handling" | Exact error types, messages, and handling code |
| "Add validation" | Specific validation rules with code |
| "Write tests for the above" | Actual test code with assertions |
| "Similar to Task N" | Repeat the code (reader may read out of order) |
| "Handle edge cases" | Enumerate each edge case with code |
| Steps without code blocks | Show the code for every code step |

## Self-Review Checklist

After writing the complete plan, review against the spec:

### 1. Spec Coverage
Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

### 2. Placeholder Scan
Search your plan for red flags — any of the patterns from "No Placeholders" above. Fix them.

### 3. Type Consistency
Do types, method signatures, and property names used in later tasks match what you defined in earlier tasks?

**Common mistakes:**
- Function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7
- Parameter type is `string` in definition but `number` in usage
- Import path differs between tasks

If you find issues, fix inline. If you find a spec requirement with no task, add the task.

## TDD Integration

Every task should follow Red-Green-Refactor:

```
Write failing test → Run (FAIL) → Write minimal code → Run (PASS) → Refactor → Commit
```

**Requirements per task:**
- Exact file paths always
- Complete code in every step
- Exact commands with expected output
- One commit per task

## Execution Handoff

After saving the plan, offer execution options:

### Option 1: Subagent-Driven (Recommended)
- Dispatch a fresh subagent per task
- Two-stage review between tasks (spec compliance → code quality)
- Fast iteration, no context pollution

### Option 2: Inline Execution
- Execute tasks in current session
- Batch execution with checkpoints
- Lighter weight, suitable for simple plans

### Option 3: Manual Execution
- Human developer follows the plan
- Each step is self-contained and executable
- Good for learning or pair programming

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Steps too large (>10 min) | Break into 2-5 min steps |
| Missing file paths | Always include exact paths |
| Code references without code | Show the actual code |
| Missing test commands | Include exact run commands with expected output |
| No commit steps | Add commit after each logical unit |
| Implicit dependencies | State prerequisites explicitly |
| Vague "cleanup" tasks | Enumerate specific cleanup actions |
