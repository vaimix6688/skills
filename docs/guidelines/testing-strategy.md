# Testing Strategy

This document defines the testing strategy for all project repositories. Every developer is expected to follow these conventions to maintain consistent quality across the platform.

## Test Naming Conventions

Each language has its own idiomatic naming style. Follow these strictly so test output is readable and grep-friendly.

### Go

Use the three-part pattern `TestSubject_Scenario_Expected`:

```go
func TestCreateUser_MissingEmail_ReturnsValidationError(t *testing.T) { ... }
func TestOrderService_DuplicateOrder_IsRejected(t *testing.T) { ... }
func TestAuthHandler_ExpiredToken_Returns401(t *testing.T) { ... }
```

### Rust

Use snake_case with `test_` prefix:

```rust
#[test]
fn test_handler_valid_input_succeeds() { ... }

#[test]
fn test_service_invalid_key_returns_error() { ... }

#[test]
fn test_rule_engine_matching_logic() { ... }
```

### TypeScript

Use `describe` / `it` blocks with human-readable sentences:

```typescript
describe('UserService', () => {
  it('should reject users with invalid email', () => { ... });
  it('should create user with valid input', () => { ... });
});
```

### Python

Use `test_` prefix with descriptive snake_case:

```python
def test_classifier_returns_top_predictions():
    ...

def test_router_falls_back_on_timeout():
    ...
```

## Coverage Targets

These are minimum thresholds enforced in CI. Coverage must not decrease on any PR.

| Component | Target | Rationale |
|---|---|---|
| Backend services | 80% | Core business logic — high reliability required |
| Frontend apps | 70% | UI has visual testing coverage too; logic-heavy code must be tested |
| Security-critical | 90% | Correctness is critical; near-complete coverage required |
| Business rules | 85% | Domain logic must be thoroughly verified |
| AI/ML services | 75% | ML pipelines are harder to unit-test; focus on core logic |
| Shared libraries | 70% | Shared types and SDK; tested via consumers too |

## Integration Tests

### Infrastructure Requirements

Integration tests run against real service dependencies via Docker Compose. Every repo that has integration tests must include a `docker-compose.test.yml` with the following services as needed:

- **PostgreSQL 16** — primary database
- **Apache Kafka** — event streaming
- **Redis 7** — caching and rate limiting

### Running Integration Tests

```bash
# Start dependencies
docker compose -f docker-compose.test.yml up -d

# Run integration tests (Go example)
go test -tags=integration ./...

# Run integration tests (TypeScript example)
npm run test:integration

# Tear down
docker compose -f docker-compose.test.yml down -v
```

### Rules

- Integration tests are tagged/separated from unit tests so they can run independently.
- Go: use build tag `//go:build integration`.
- Rust: use `#[cfg(feature = "integration")]`.
- TypeScript: place in `__tests__/integration/` directories.
- Python: mark with `@pytest.mark.integration`.
- Always clean up test data after each test (use transactions with rollback or truncate).

## End-to-End Tests

### Frontend (Playwright)

Frontend apps use Playwright for E2E testing:

- Tests live in `e2e/` at the app root.
- Run against a staging environment or local Docker stack.
- Cover critical user flows: login, core workflows, dashboard rendering.
- Visual regression tests for key pages.

### Backend (Contract Tests)

Backend services validate their API integration through contract tests:

- Contract definitions live in a shared package (e.g., `packages/contracts/`).
- Each service verifies it can produce/consume the expected message formats.
- Contract tests run as part of CI on every PR that touches API boundaries.

## Test Data

### Seed Scripts

Canonical seed data lives in a shared infrastructure package (e.g., `packages/db/seeds/`). These scripts populate:

- Reference data (lookup tables, categories, codes)
- Test organizations and tenants
- Sample business data
- Mock external API responses

### Fixtures

Each repo maintains its own fixtures for unit and integration tests:

- Go: `testdata/` directories adjacent to the package under test.
- Rust: `tests/fixtures/` at crate root.
- TypeScript: `__fixtures__/` directories.
- Python: `tests/fixtures/` directory.

Fixtures must not contain real production data or secrets. Use obviously fake data (e.g., `test-org-001`, `HS-CODE-9999`).

## Mock Strategy

### External Services

Mock all external service calls in unit tests:

| External Service | Mock Approach |
|---|---|
| External APIs | Mock client or HTTP stub server (WireMock or equivalent) |
| Third-party SDKs | Interface-based mock |
| Messaging services | In-memory fake |
| SMTP/email | In-memory mailbox |

### Internal Services

- **Unit tests**: mock inter-service calls via interfaces (Go), traits (Rust), or dependency injection (TypeScript/Python).
- **Integration tests**: use real database connections; do NOT mock the database.

### Database in Tests

- **Unit tests**: mock the repository layer.
- **Integration tests**: connect to a real PostgreSQL instance (Docker). Use per-test transactions that roll back, or truncate tables between tests.
- **Never** use SQLite as a stand-in for PostgreSQL — behavior differences cause false confidence.

## TDD Policy

### Bug Fixes — TDD Required

Every bug fix **must** follow TDD:

1. Write a failing test that reproduces the bug.
2. Verify the test fails for the right reason.
3. Implement the fix.
4. Verify the test passes.
5. Submit both the test and the fix in the same PR.

### New Features — Test-After Accepted

For new feature development, writing tests after implementation is acceptable, provided:

- Tests are included in the same PR as the feature code.
- Coverage does not decrease.
- Critical paths have tests before the PR is approved.

## CI Gates

The following gates are enforced on every pull request. A PR cannot be merged unless all pass:

1. **All tests pass** — unit, integration, and E2E (where applicable).
2. **Coverage does not decrease** — compared to the base branch.
3. **Linting passes** — `golangci-lint` (Go), `clippy` (Rust), `eslint` (TS), `ruff` (Python).
4. **Type checking passes** — `tsc --noEmit` (TS), `mypy` (Python).
5. **Security scan passes** — no new critical/high vulnerabilities.

### Flaky Test Policy

- A flaky test is a bug. If a test fails intermittently, file a P2 issue immediately.
- Do not skip or retry flaky tests as a workaround. Fix the root cause.
- If a flaky test blocks the entire team, it may be temporarily quarantined with a tracking issue, but must be fixed within the current sprint.
