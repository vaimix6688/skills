# Security Guidelines

This document defines the security practices that every Project developer must follow. Supply chain traceability involves sensitive trade data, cryptographic operations, and regulatory compliance — security is not optional.

## Secret Management

### Rules

- **Never commit secrets** to any repository. This includes `.env` files, API keys, private keys, database passwords, and tokens.
- Use **environment variables** for all secrets in application code.
- All secrets at rest must be **encrypted** (AES-256 or equivalent).
- Use a secret management service (e.g., AWS Secrets Manager, HashiCorp Vault) for production secrets.
- Rotate secrets on a regular schedule (at least quarterly) and immediately if a compromise is suspected.

### .env Files

- Every repo includes a `.env.example` with placeholder values. Never put real secrets in this file.
- `.env` is listed in `.gitignore` for every repository.
- Local development secrets must differ from staging and production secrets.

### Automated Secret Scanning

Secret scanning runs in CI on every PR and blocks merge if secrets are detected:

- Tool: `gitleaks` or equivalent.
- Scans the full diff for patterns matching API keys, passwords, tokens, and private keys.
- False positives should be added to the allowlist with a comment explaining why.

## Dependency Scanning

### Tools by Language

| Language | Tool | Command |
|---|---|---|
| Go | `govulncheck` | `govulncheck ./...` |
| Rust | `cargo audit` | `cargo audit` |
| TypeScript | `npm audit` | `npm audit --audit-level=high` |
| Python | `pip-audit` | `pip-audit` |

### Scanning Schedule

- **On every PR**: scan changed dependencies.
- **Weekly**: full scan of all dependencies in all repositories (scheduled CI job).
- **On security advisory**: immediate scan when a relevant CVE is published.

### Handling Vulnerabilities

| Severity | Action | Timeline |
|---|---|---|
| Critical | Stop and fix immediately | Same day |
| High | Fix before next release | Within 1 week |
| Medium | Schedule in current sprint | Within 2 weeks |
| Low | Add to backlog | Next sprint |

If a dependency has a known vulnerability with no fix available, document the risk and implement mitigating controls.

## OWASP Top 10 Review Checklist

Every PR review must consider the following OWASP Top 10 (2021) risks:

- [ ] **A01: Broken Access Control** — Are authorization checks in place? Is tenant isolation enforced?
- [ ] **A02: Cryptographic Failures** — Are secrets protected? Is data encrypted in transit and at rest?
- [ ] **A03: Injection** — Are all queries parameterized? Is user input sanitized?
- [ ] **A04: Insecure Design** — Does the design follow security principles (least privilege, defense in depth)?
- [ ] **A05: Security Misconfiguration** — Are default credentials removed? Are error messages safe?
- [ ] **A06: Vulnerable Components** — Are dependencies up to date? Any known vulnerabilities?
- [ ] **A07: Authentication Failures** — Are authentication mechanisms robust? Token expiry handled?
- [ ] **A08: Data Integrity Failures** — Are software updates verified? Is data integrity ensured?
- [ ] **A09: Logging Failures** — Are security events logged? Are logs protected from tampering?
- [ ] **A10: SSRF** — Are outbound requests validated? Are internal endpoints protected?

## SQL Injection Prevention

**Parameterized queries only.** No exceptions.

### Go

```go
// CORRECT
row := db.QueryRow("SELECT * FROM declarations WHERE id = $1 AND tenant_id = $2", id, tenantID)

// WRONG — never do this
row := db.QueryRow("SELECT * FROM declarations WHERE id = '" + id + "'")
```

### Rust (sqlx)

```rust
// CORRECT
let decl = sqlx::query_as!(Declaration, "SELECT * FROM declarations WHERE id = $1 AND tenant_id = $2", id, tenant_id)
    .fetch_one(&pool)
    .await?;
```

### TypeScript (Prisma / raw queries)

```typescript
// CORRECT — Prisma handles parameterization
const decl = await prisma.declaration.findUnique({ where: { id, tenantId } });

// CORRECT — tagged template for raw queries
const result = await prisma.$queryRaw`SELECT * FROM declarations WHERE id = ${id}`;

// WRONG — string interpolation in raw SQL
const result = await prisma.$queryRawUnsafe(`SELECT * FROM declarations WHERE id = '${id}'`);
```

## XSS Prevention

### Input Sanitization

- Sanitize all user input on the server side before storage.
- Use allowlists for expected input formats (e.g., HS codes match `^\d{4}\.\d{2}$`).
- Encode output when rendering user-provided data in HTML.

### Content Security Policy

All frontend applications must set CSP headers:

```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' https://api.myproject.vn
```

- No `unsafe-eval` in script-src.
- No wildcard (`*`) sources.
- Report violations to a CSP reporting endpoint.

### Additional Headers

All HTTP responses must include:

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
Referrer-Policy: strict-origin-when-cross-origin
```

## Vulnerability Disclosure

### Reporting

If you discover a security vulnerability in Project:

**Email: security@myproject.vn**

**Do NOT open a public GitHub issue.** Public disclosure before a fix is available puts users at risk.

### What to Include in a Report

- Description of the vulnerability.
- Steps to reproduce.
- Potential impact.
- Suggested fix (if any).

### Response Timeline

| Action | Timeline |
|---|---|
| Acknowledge receipt | Within 24 hours |
| Initial assessment | Within 48 hours |
| P0 fix deployed | Within 48 hours of confirmation |
| P1 fix deployed | Within 1 week |
| P2 fix deployed | Within 2 weeks |
| Reporter notified of fix | Same day as deployment |

### Safe Harbor

Project will not pursue legal action against security researchers who:

- Act in good faith.
- Report vulnerabilities privately via the process above.
- Do not access, modify, or delete data belonging to other users.
- Do not disrupt service availability.

## HSM Key Handling (`myproject-crypto`)

The `myproject-crypto` repository handles cryptographic keys and requires additional security measures:

### Rules

- Private keys must **never** leave the HSM boundary in plaintext.
- All signing operations are performed within the HSM.
- Key generation uses HSM-provided entropy only.
- Key backup and recovery follow the documented key ceremony process.
- Access to HSM configuration requires two-person authorization.
- HSM audit logs are immutable and retained for 7 years.

### ZK Proof Security

- Zero-knowledge proof circuits must be reviewed by at least two members of the `@crypto-core` team.
- Proof parameters (trusted setup, if applicable) are generated in a multi-party ceremony.
- Verification keys are published and pinned in application configuration.

### Key Rotation

- Signing keys are rotated annually or immediately upon suspected compromise.
- Old keys remain available for verification of previously signed data.
- Key rotation is a planned event with its own checklist and rollback plan.

## Audit Logging

### Requirements

Every write operation in Project must produce an audit log entry:

```json
{
  "timestamp": "2026-03-22T10:30:00Z",
  "traceId": "abc-123-def-456",
  "action": "declaration.create",
  "actor": {
    "userId": "user-789",
    "tenantId": "tenant-001",
    "role": "customs_officer"
  },
  "resource": {
    "type": "ImportDeclaration",
    "id": "decl-456"
  },
  "changes": {
    "status": { "from": null, "to": "draft" }
  },
  "ip": "192.168.1.100",
  "userAgent": "Project-Web/1.2.0"
}
```

### Rules

- Audit logs are **append-only** and **immutable**.
- Logs must not contain sensitive data (passwords, full private keys, PII beyond user ID).
- Audit logs are retained for a minimum of 7 years (regulatory requirement).
- Audit log writes must not block the primary operation — use asynchronous publishing (Kafka).
- Audit log integrity is verified periodically via hash chains.

## Tenant Isolation

Project is a multi-tenant system. Tenant isolation is a security-critical requirement.

### Code Review Checklist

Every PR that touches data access must verify:

- [ ] All database queries include `tenant_id` in the WHERE clause.
- [ ] API endpoints validate that the requesting user belongs to the target tenant.
- [ ] Background jobs and event handlers carry tenant context.
- [ ] Test cases cover cross-tenant access attempts (must be denied).
- [ ] Caching keys are namespaced by tenant ID.
- [ ] File storage paths are namespaced by tenant ID.

### Common Mistakes

```go
// WRONG — missing tenant isolation
func GetDeclaration(id string) (*Declaration, error) {
    return db.Query("SELECT * FROM declarations WHERE id = $1", id)
}

// CORRECT — tenant-scoped
func GetDeclaration(tenantID, id string) (*Declaration, error) {
    return db.Query("SELECT * FROM declarations WHERE id = $1 AND tenant_id = $2", id, tenantID)
}
```

## Hardcoded Credentials

**No hardcoded credentials. Zero tolerance.**

Automated checks in CI:

- `gitleaks` scans every PR for credential patterns.
- Custom rules detect Project-specific patterns (External API keys, HSM PINs).
- Violations block the PR from merging.

If a credential is accidentally committed:

1. **Rotate the credential immediately** — assume it is compromised.
2. Rewrite Git history to remove the credential (coordinate with the team lead).
3. File a security incident report.
4. Add the pattern to the secret scanning rules to prevent recurrence.
