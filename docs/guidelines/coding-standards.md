# Coding Standards

> Applies to all project repositories. Customize per your team size and tech stack.

---

## 1. Language-Specific Conventions

### Go

- **Version:** Go 1.22+
- **Project layout:** Follow [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
- **Error handling:** Always wrap errors with context: `fmt.Errorf("service: operation: %w", err)`. Never use `panic()` in library code — reserve for truly unrecoverable situations in `main()`.
- **Context:** Every function that does I/O takes `ctx context.Context` as first parameter.
- **Logging:** Use `log/slog` (structured JSON). Always include `traceId`, `tenantId` where available.
- **Naming:** `snake_case` for file names, `PascalCase` for exported types/funcs, `camelCase` for unexported.
- **Testing:** Table-driven tests. Test file next to source: `handler.go` → `handler_test.go`.

```go
// Good
if err := s.repo.Save(ctx, batch); err != nil {
    return fmt.Errorf("save batch %s: %w", batch.ID, err)
}

// Bad
result, _ := s.repo.Save(ctx, batch)  // Never ignore errors
```

### Rust

- **Version:** Rust 1.76+ (stable)
- **Error handling:** `thiserror` for library crates, `anyhow` for binary crates. Define domain-specific error enums.
- **Async runtime:** `tokio` (multi-threaded). Use `#[tokio::main]` for binaries.
- **Unsafe:** Never in application code. Requires explicit security review for crypto primitives.
- **Naming:** `snake_case` for files/functions/variables, `PascalCase` for types/traits/enums.
- **Testing:** `#[cfg(test)] mod tests` in same file for unit tests. Integration tests in `tests/` directory.

```rust
// Good — thiserror for library errors
#[derive(Debug, thiserror::Error)]
pub enum DomainError {
    #[error("invalid input: {reason}")]
    InvalidInput { reason: String },
    #[error("entity not found: {0}")]
    NotFound(String),
}
```

### TypeScript

- **Version:** Node.js 20 LTS, TypeScript 5.x strict mode
- **No `any`:** Use `unknown` + type narrowing. If you think you need `any`, use a generic or Zod parser instead.
- **Validation:** `zod` at all system boundaries (API input, Kafka consumption, external API responses).
- **Import ordering:** 1) node built-ins, 2) external packages, 3) `@project/*` packages, 4) relative imports. Enforced by ESLint.
- **Naming:** `camelCase` for variables/functions, `PascalCase` for types/interfaces/classes, `UPPER_SNAKE_CASE` for constants.
- **React (frontend):** Functional components only. App Router only (no Pages Router). Use `'use client'` / `'use server'` directives explicitly.

```typescript
// Good — Zod at boundary
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  role: z.enum(['admin', 'member', 'viewer']),
});
type CreateUser = z.infer<typeof CreateUserSchema>;

// Bad
function process(data: any) { ... }  // Never use any
```

### Python

- **Version:** Python 3.11+
- **Type hints:** Required on all function signatures. Use `pydantic` for data models.
- **Package manager:** `uv` (faster than pip)
- **Linting:** `ruff` (replaces flake8 + isort + black)
- **Web framework:** FastAPI with Pydantic v2 models
- **Naming:** `snake_case` for files/functions/variables, `PascalCase` for classes, `UPPER_SNAKE_CASE` for constants.

---

## 2. Cross-Language Standards

### Logging
All services emit structured JSON logs:
```json
{
  "level": "info",
  "msg": "entity created",
  "traceId": "abc-123-def",
  "tenantId": "uuid",
  "entityId": "uuid",
  "service": "my-service",
  "timestamp": "2026-03-22T10:30:00Z"
}
```

### Trace ID Propagation
- OpenTelemetry W3C Trace Context (`traceparent` header)
- Every HTTP request, Kafka message, and gRPC call carries trace context
- Trace IDs logged in every log line

### Error Codes
Services return structured errors:
```json
{
  "error": {
    "code": "ENTITY_NOT_FOUND",
    "message": "Entity with ID xyz-001 does not exist",
    "traceId": "abc-123-def"
  }
}
```
Error code format: `UPPER_SNAKE_CASE`, domain-prefixed when ambiguous (e.g., `AUTH_TOKEN_EXPIRED`).

---

## 3. Git Conventions

### Branch Naming
```
feat/user-authentication            # New feature
fix/login-session-timeout          # Bug fix
chore/update-dependencies-v2       # Maintenance
docs/add-adr-011                   # Documentation
refactor/api-handler-cleanup       # Refactoring
```

### Commit Messages
[Conventional Commits](https://www.conventionalcommits.org/) format:
```
feat(auth): add OAuth2 login flow
fix(api): prevent race condition in session handling
docs(adr): add ADR-005 caching strategy
chore(deps): bump dependencies to latest
```

### PR Rules
- Max 400 lines changed (excluding generated code)
- At least 1 reviewer approval required
- CI must pass (tests + lint)
- Security-critical changes require dedicated team review

---

## 4. Testing Standards

### Coverage Expectations
| Component | Unit | Integration | E2E |
|-----------|------|-------------|-----|
| Backend services | 80%+ | Required (Docker) | — |
| Frontend apps | 70%+ | — | Required (Playwright) |
| Security-critical | 90%+ | Required | — |
| Business logic | 85%+ | Required | — |
| AI/ML services | 75%+ | Required | — |

### Test Naming
```
Go:     TestUserService_InvalidEmail_ReturnsError
Rust:   fn test_handler_validates_input()
TS:     it('should reject request with missing required field')
Python: def test_classifier_returns_top_predictions():
```

---

## 5. Security Standards

- **No hardcoded secrets.** Use environment variables. Never commit `.env` files.
- **Dependency scanning:** `govulncheck` (Go), `cargo audit` (Rust), `npm audit` (TS), `pip-audit` (Python). Run in CI.
- **SQL injection:** Use parameterized queries only. No string concatenation for SQL.
- **Input validation:** Validate at every system boundary with Zod (TS) or struct validation (Go/Rust).
- **Audit logging:** Every write operation logged to audit trail (immutable, append-only).
- **Secrets:** Never logged, never in error messages, never in stack traces.
- **Tenant isolation:** If multi-tenant, every query includes `tenant_id` filter via RLS.

---

## 6. API Design

- **Versioning:** URL path versioning (`/api/v1/...`)
- **Pagination:** Cursor-based for large datasets, offset-based for small admin lists
- **Dates:** ISO-8601 with timezone (`2026-03-22T10:30:00Z`)
- **IDs:** UUID v7 (time-ordered) for new records
- **HTTP status codes:** 200 OK, 201 Created, 202 Accepted (async), 400 Bad Request, 401/403 Auth, 404 Not Found, 409 Conflict, 500 Internal Error
