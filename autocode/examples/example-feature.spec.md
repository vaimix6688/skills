# User Authentication — Spec (SDD v1.0)

> **Principle**: This file describes the EXPECTED RESULT, not HOW to implement it.
> The AI reads this file and decides the implementation approach autonomously.

---

## 1. Objective

Implement a user authentication module that supports email/password login, JWT token issuance, token refresh, and session management. The module must enforce rate limiting, password complexity rules, and account lockout after failed attempts.

**Module:** `auth-service`
**Repo:** `myproject-core`
**Language:** `TypeScript`
**Port:** `3001`

---

## 2. Input / Output Schema

### Input

```typescript
interface LoginRequest {
  email: string;       // User email address
  password: string;    // Plain-text password (will be hashed)
}

interface RegisterRequest {
  email: string;       // Must be unique
  password: string;    // Min 8 chars, 1 upper, 1 number, 1 special
  name: string;        // Display name, 2-100 chars
}

interface RefreshRequest {
  refreshToken: string;  // Valid refresh token from prior login
}
```

### Output

```typescript
interface AuthResponse {
  accessToken: string;    // JWT, 15 min expiry
  refreshToken: string;   // Opaque token, 7 day expiry
  expiresIn: number;      // Seconds until access token expires
  user: UserProfile;
}

interface UserProfile {
  id: string;             // UUID v4
  email: string;
  name: string;
  createdAt: string;      // ISO 8601
}

interface ErrorResponse {
  code: string;           // Machine-readable error code
  message: string;        // Human-readable description
}
```

### API Endpoints

| Method | Path | Request | Response | Status |
|--------|------|---------|----------|--------|
| POST | /api/v1/auth/register | RegisterRequest | AuthResponse | 201 |
| POST | /api/v1/auth/login | LoginRequest | AuthResponse | 200 |
| POST | /api/v1/auth/refresh | RefreshRequest | AuthResponse | 200 |
| POST | /api/v1/auth/logout | - (Bearer token) | `{ success: true }` | 200 |
| GET | /api/v1/auth/me | - (Bearer token) | UserProfile | 200 |

---

## 3. Business Logic

1. **RULE-01**: Password must be at least 8 characters with 1 uppercase, 1 number, and 1 special character.
   - Input: `password = "abc"` -> Expected: Reject with `WEAK_PASSWORD`
   - Input: `password = "Str0ng!Pass"` -> Expected: Accept

2. **RULE-02**: After 5 failed login attempts within 15 minutes, the account is locked for 30 minutes.
   - Input: 5 failed logins -> Expected: 6th attempt returns `ACCOUNT_LOCKED` even with correct password
   - Input: Wait 30 min -> Expected: Account unlocks automatically

3. **RULE-03**: Access tokens expire after 15 minutes. Refresh tokens expire after 7 days.
   - Input: Expired access token -> Expected: 401 Unauthorized
   - Input: Valid refresh token -> Expected: New access + refresh token pair

4. **RULE-04**: Email addresses must be unique (case-insensitive).
   - Input: Register `User@Example.com` when `user@example.com` exists -> Expected: Reject with `EMAIL_EXISTS`

5. **RULE-05**: Logout invalidates the current refresh token.
   - Input: Logout, then use old refresh token -> Expected: Reject with `TOKEN_REVOKED`

### Edge Cases

- **EDGE-01**: Concurrent registration with same email — only one should succeed, the other gets `EMAIL_EXISTS`
- **EDGE-02**: Malformed JWT token — return 401, not 500
- **EDGE-03**: Empty request body — return 400 with validation errors
- **EDGE-04**: SQL injection in email field — must be sanitized, no DB error exposed

---

## 4. Dependencies

### Internal

| Package | Import | Purpose |
|---------|--------|---------|
| `@myproject/shared-types` | `User, AuthToken` | Type definitions |
| `@myproject/db` | `pgPool` | Database connection pool |

### External

| Package | Version | Purpose |
|---------|---------|---------|
| `bcryptjs` | `^2.4.3` | Password hashing |
| `jsonwebtoken` | `^9.0.0` | JWT signing/verification |
| `zod` | `^3.22.0` | Request validation |
| `uuid` | `^9.0.0` | UUID generation |

### Services called

| Service | Endpoint | Timeout |
|---------|----------|---------|
| PostgreSQL | localhost:5432 | 5s |
| Redis | localhost:6379 | 1s |

---

## 5. Database

### Tables affected

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  email_lower VARCHAR(255) UNIQUE NOT NULL,  -- lowercase for case-insensitive lookup
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  failed_login_attempts INT DEFAULT 0,
  locked_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Refresh tokens table
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_users_email_lower ON users(email_lower);
```

### Migration needed?

- [x] New migration: `001_create_auth_tables.sql`

---

## 6. Definition of Done (DoD)

> **CRITICAL**: AI may only commit when ALL items below PASS.

### Required tests

| # | Test | Command | Expected |
|---|------|---------|----------|
| T1 | Unit tests pass | `pnpm test` | exit code 0 |
| T2 | Lint pass | `pnpm lint` | 0 errors |
| T3 | Type check | `pnpm tsc --noEmit` | exit code 0 |
| T4 | Build pass | `pnpm build` | exit code 0 |

### Business rule tests

| # | Rule | Test function | Expected |
|---|------|--------------|----------|
| B1 | RULE-01 | `test('rejects weak password')` | PASS |
| B2 | RULE-01 | `test('accepts strong password')` | PASS |
| B3 | RULE-02 | `test('locks account after 5 failures')` | PASS |
| B4 | RULE-02 | `test('unlocks after 30 minutes')` | PASS |
| B5 | RULE-03 | `test('rejects expired access token')` | PASS |
| B6 | RULE-03 | `test('refresh returns new token pair')` | PASS |
| B7 | RULE-04 | `test('rejects duplicate email case-insensitive')` | PASS |
| B8 | RULE-05 | `test('revoked refresh token is rejected')` | PASS |
| B9 | EDGE-01 | `test('concurrent registration race condition')` | PASS |
| B10 | EDGE-02 | `test('malformed JWT returns 401')` | PASS |
| B11 | EDGE-03 | `test('empty body returns 400')` | PASS |
| B12 | EDGE-04 | `test('SQL injection is sanitized')` | PASS |

---

## 7. File Structure (Suggested)

```
apps/auth-service/
├── src/
│   ├── index.ts              # Entry point, Express app setup
│   ├── routes/
│   │   └── auth.routes.ts    # Route definitions
│   ├── controllers/
│   │   └── auth.controller.ts # Request handlers
│   ├── services/
│   │   └── auth.service.ts   # Business logic
│   ├── middleware/
│   │   ├── auth.middleware.ts # JWT verification middleware
│   │   └── validate.ts       # Zod validation middleware
│   ├── models/
│   │   └── user.model.ts     # Database queries
│   └── config/
│       └── index.ts          # Environment config
├── tests/
│   ├── auth.service.test.ts  # Unit tests
│   └── auth.routes.test.ts   # Integration tests
├── migrations/
│   └── 001_create_auth_tables.sql
├── package.json
└── tsconfig.json
```

---

## 8. Constraints

- [ ] Passwords must be hashed with bcrypt (cost factor 12)
- [ ] JWT secret must come from environment variable, never hardcoded
- [ ] All database queries must use parameterized statements (no string concatenation)
- [ ] Rate limiting: max 10 requests/minute per IP on auth endpoints
- [ ] Logging: structured JSON with requestId, userId (when available)
- [ ] No sensitive data (passwords, tokens) in logs
- [ ] Performance: login endpoint P99 < 200ms
