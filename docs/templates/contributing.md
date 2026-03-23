# Contributing to Project

Thank you for your interest in contributing to Project. This guide covers everything you need to get started.

## Prerequisites

Before you begin, install the following tools:

| Tool | Version | Purpose |
|---|---|---|
| **Git** | 2.40+ | Version control |
| **Go** | 1.23+ | Backend services (`myproject-core`) |
| **Rust** | 1.78+ (stable) | Crypto and compliance (`myproject-crypto`, `myproject-compliance`, `myproject-core`) |
| **Node.js** | 22 LTS | Frontend and infra (`myproject-frontend`, `myproject-infra`, `myproject-ingestion`) |
| **Python** | 3.12+ | AI services (`myproject-ai`) |
| **Docker** | 24+ | Local development and integration tests |
| **Docker Compose** | 2.20+ | Multi-container orchestration |
| **PostgreSQL client** | 16+ | Database access (psql) |

### Optional but Recommended

| Tool | Purpose |
|---|---|
| **golangci-lint** | Go linting |
| **cargo-watch** | Rust auto-rebuild |
| **pnpm** | Fast Node.js package manager |
| **Playwright** | Frontend E2E testing |

## Getting Started

### 1. Clone the Repository

```bash
git clone git@github.com:myproject/<repo-name>.git
cd <repo-name>
```

### 2. Install Dependencies

**Go:**
```bash
go mod download
```

**Rust:**
```bash
cargo build
```

**TypeScript:**
```bash
npm install
# or
pnpm install
```

**Python:**
```bash
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with your local settings. Never commit `.env` to version control. See the repo's README for required environment variables.

### 4. Start Local Services

```bash
docker compose up -d
```

This starts PostgreSQL, Kafka, Redis, and any other dependencies defined in the repo's `docker-compose.yml`.

### 5. Run Database Migrations

```bash
# From myproject-infra
cd ../myproject-infra
make migrate-up
```

### 6. Verify Your Setup

```bash
# Run the test suite
make test
# or
go test ./...
# or
npm test
# or
cargo test
# or
pytest
```

If all tests pass, your environment is ready.

## Branch Naming Convention

Create feature branches from `main`:

```bash
git checkout main
git pull origin main
git checkout -b <type>/<description>
```

| Type | Use Case | Example |
|---|---|---|
| `feat/` | New feature | `feat/IM-01-import-declaration` |
| `fix/` | Bug fix | `fix/QR-verify-cache` |
| `chore/` | Maintenance | `chore/update-deps` |
| `refactor/` | Restructuring | `refactor/event-chain-storage` |
| `docs/` | Documentation | `docs/api-versioning-guide` |
| `test/` | Test changes | `test/co-engine-edge-cases` |

See [git-workflow.md](../guidelines/git-workflow.md) for the complete branching strategy.

## Commit Message Format

Project uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Examples

```
feat(event-chain): add Business Event validation for import events
fix(qr-verify): handle expired tokens gracefully
chore(deps): bump Go to 1.23
test(hs-classifier): add edge cases for ambiguous codes
```

### Rules

- Use imperative mood: "add" not "added" or "adds".
- Lowercase first letter of the description.
- No period at the end.
- Max 72 characters for the subject line.

See [git-workflow.md](../guidelines/git-workflow.md) for the full commit convention.

## Running Tests

### Unit Tests

```bash
# Go
go test ./...

# Rust
cargo test

# TypeScript
npm test

# Python
pytest
```

### Integration Tests

Integration tests require Docker services to be running:

```bash
docker compose -f docker-compose.test.yml up -d

# Go
go test -tags=integration ./...

# TypeScript
npm run test:integration

# Python
pytest -m integration
```

### End-to-End Tests (Frontend)

```bash
cd myproject-frontend
npx playwright test
```

See [testing-strategy.md](../guidelines/testing-strategy.md) for the complete testing guidelines.

## Submitting a Pull Request

### 1. Push Your Branch

```bash
git push -u origin feat/your-feature
```

### 2. Open a PR

Open a pull request against `main` on GitHub. Fill in the [PR template](pr-template.md) completely:

- Describe **what** changed and **why**.
- Explain the **technical approach**.
- List the **testing** you performed.
- Complete the **checklist**.

### 3. Address Review Feedback

- Respond to all reviewer comments.
- Push additional commits to address feedback (do not force-push during review).
- Re-request review when ready.

### 4. Merge

Once approved and CI passes, the PR is merged via **squash merge**. The branch is deleted automatically.

## Code Review Expectations

### As an Author

- Keep PRs small: 400 lines max (excluding generated code).
- Write a clear PR description.
- Include tests for new code.
- Self-review your diff before requesting review.

### As a Reviewer

- Respond within 4 business hours.
- Focus on correctness, security, and test quality.
- Use GitHub suggestions for small changes.
- Approve only when confident the code is production-ready.
- Be constructive and respectful.

## Coding Standards

Follow the coding standards documented in [coding-standards.md](../guidelines/coding-standards.md). Key highlights:

- **Go**: `gofmt`, `golangci-lint`, error wrapping with `fmt.Errorf`.
- **Rust**: `cargo fmt`, `clippy`, error types with `thiserror`.
- **TypeScript**: `prettier`, `eslint`, strict TypeScript mode.
- **Python**: `ruff`, `mypy`, type hints required.

## Where to Ask Questions

- **General questions**: Post in the `#dev-general` channel.
- **Architecture questions**: Post in `#dev-architecture`.
- **Security questions**: Post in `#security` or email security@myproject.vn.
- **Onboarding help**: Reach out to your assigned onboarding buddy.
- **Bug in docs**: Open a PR or issue on `myproject-docs`.

## Code of Conduct

All contributors must follow the [Code of Conduct](code-of-conduct.md). We are committed to providing a welcoming and respectful environment for everyone.
