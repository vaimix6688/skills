# [MODULE_NAME] — Spec (SDD v1.0)

> **Nguyên tắc**: File này mô tả KẾT QUẢ, không phải CÁCH LÀM.
> AI đọc file này và tự quyết định cách implement.

---

## 1. Mục tiêu (Objective)

<!-- Mô tả ngắn gọn module này làm gì, tại sao cần nó -->

**Module:** `[tên package/service]`
**Repo:** `[repo-name]`
**Ngôn ngữ:** `[Go | Rust | TypeScript | Python]`
**Port:** `[nếu là service]`

---

## 2. Input / Output Schema

### Input

```typescript
// Mô tả cấu trúc dữ liệu đầu vào
interface InputData {
  field1: string;    // Mô tả
  field2: number;    // Mô tả
}
```

### Output

```typescript
// Mô tả cấu trúc dữ liệu đầu ra
interface OutputData {
  result: string;
  success: boolean;
}
```

### API Endpoints (nếu là service)

| Method | Path | Request | Response | Status |
|--------|------|---------|----------|--------|
| POST | /api/v1/xxx | InputData | OutputData | 201 |
| GET | /api/v1/xxx/:id | - | OutputData | 200 |

---

## 3. Business Logic (Quy tắc xử lý)

<!-- Liệt kê TẤT CẢ quy tắc. Mỗi quy tắc = 1 test case -->

1. **RULE-01**: [Mô tả quy tắc]
   - Input: [ví dụ]
   - Expected: [kết quả mong đợi]

2. **RULE-02**: [Mô tả quy tắc]
   - Input: [ví dụ]
   - Expected: [kết quả mong đợi]

3. **RULE-03**: [Mô tả quy tắc]
   - Input: [ví dụ]
   - Expected: [kết quả mong đợi]

### Edge Cases

- **EDGE-01**: [Trường hợp biên]
- **EDGE-02**: [Trường hợp lỗi]

---

## 4. Dependencies (Phụ thuộc)

### Internal

| Package | Import | Dùng cho |
|---------|--------|----------|
| `@project/shared-types` | `Entity, Config` | Type definitions |

### External

| Package | Version | Dùng cho |
|---------|---------|----------|
| `example-lib` | `^1.0.0` | Mô tả |

### Services gọi đến

| Service | Endpoint | Timeout |
|---------|----------|---------|
| proof-server | POST /api/v1/proofs/generate | 30s |

---

## 5. Database (nếu có)

### Tables affected

```sql
-- Bảng nào bị ảnh hưởng, cột nào cần đọc/ghi
SELECT col1, col2 FROM table_name WHERE tenant_id = $1;
INSERT INTO table_name (col1, col2) VALUES ($1, $2);
```

### Migration needed?

- [ ] Không cần migration
- [ ] Cần migration mới: `XXX_description.sql`

---

## 6. Definition of Done (DoD)

> **CRITICAL**: AI chỉ được commit khi TẤT CẢ items dưới đây PASS.

### Tests bắt buộc

| # | Test | Command | Expected |
|---|------|---------|----------|
| T1 | Unit tests pass | `[go test / cargo test / pnpm test / pytest]` | exit code 0 |
| T2 | Lint pass | `[golangci-lint / cargo clippy / eslint]` | 0 warnings |
| T3 | Type check | `[go vet / tsc --noEmit]` | exit code 0 |
| T4 | Build pass | `[go build / cargo build / pnpm build]` | exit code 0 |

### Business rule tests

| # | Rule | Test function | Expected |
|---|------|--------------|----------|
| B1 | RULE-01 | `TestRule01` | PASS |
| B2 | RULE-02 | `TestRule02` | PASS |
| B3 | EDGE-01 | `TestEdge01` | PASS |

### Integration (nếu cần)

| # | Test | Cần | Expected |
|---|------|-----|----------|
| I1 | API endpoint responds | Docker up | 200 OK |

---

## 7. File Structure (Gợi ý)

<!-- AI tự quyết định cấu trúc, đây chỉ là gợi ý -->

```
apps/[service-name]/
├── cmd/main.go          # Entry point
├── internal/
│   ├── handler/         # HTTP handlers
│   ├── service/         # Business logic
│   └── config/          # Configuration
├── go.mod
└── Dockerfile
```

---

## 8. Constraints (Ràng buộc)

- [ ] Multi-tenant: Mọi query phải có `tenant_id`
- [ ] Logging: Structured JSON với `traceId`, `tenantId`
- [ ] Error handling: Không panic, wrap errors với context
- [ ] Security: Không hardcode secrets
- [ ] Performance: [target cụ thể nếu có]

---

## 9. Kafka Events (nếu có)

### Publish

| Topic | Key | Payload | Khi nào |
|-------|-----|---------|---------|
| `trace.xxx` | `tenantId:entityId` | `{...}` | Sau khi tạo thành công |

### Subscribe

| Topic | Consumer Group | Hành động |
|-------|---------------|-----------|
| `trace.xxx` | `service-name-group` | Mô tả |

---

<!--
HƯỚNG DẪN SỬ DỤNG:
1. Copy template này, đổi tên thành spec.md
2. Điền tất cả sections
3. Chạy: ./autocode.sh [repo-path]
4. AI sẽ tự đọc spec → code → test → fix → commit
-->
