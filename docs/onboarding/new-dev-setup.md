# New Developer Setup Guide

> From zero to running the full Project stack locally.

---

## Prerequisites

Install these tools before starting:

| Tool | Version | Install |
|------|---------|---------|
| Git | Latest | `winget install Git.Git` |
| Docker Desktop | 24+ | `winget install Docker.DockerDesktop` |
| Node.js | 20 LTS | `winget install OpenJS.NodeJS.LTS` |
| pnpm | 9+ | `npm install -g pnpm` |
| Go | 1.22+ | `winget install GoLang.Go` |
| Rust | 1.76+ stable | `winget install Rustlang.Rustup` → `rustup default stable` |
| Python | 3.11+ | `winget install Python.Python.3.12` |
| uv | Latest | `pip install uv` |

Optional (for crypto work):
| Tool | Version | Notes |
|------|---------|-------|
| Circom | 2.1.5+ | `npm install -g circom` |
| snarkjs | 0.7+ | `npm install -g snarkjs` |

---

## Step 1: Clone Repositories

Clone in this order (infra first — other repos depend on it):

```bash
mkdir -p ~/Code/Project && cd ~/Code/Project

# 1. Infrastructure (FIRST — shared types, SDK)
git clone git@github.com:myproject/myproject-infra.git

# 2. Core backend
git clone git@github.com:myproject/myproject-core.git

# 3. Frontend
git clone git@github.com:myproject/myproject-frontend.git

# 4. Others (clone as needed)
git clone git@github.com:myproject/myproject-compliance.git
git clone git@github.com:myproject/myproject-crypto.git
git clone git@github.com:myproject/myproject-ingestion.git
git clone git@github.com:myproject/myproject-ai.git
git clone git@github.com:myproject/myproject-docs.git
```

---

## Step 2: Setup myproject-infra

```bash
cd myproject-infra
pnpm install
```

This installs shared-types and nbc-sdk that other repos import.

---

## Step 3: Start Shared Infrastructure (Docker)

```bash
cd myproject-core
docker compose up -d
```

This starts:
- **PostgreSQL** (port 5432) — main database
- **TimescaleDB** (port 5433) — event time-series
- **Redis** (port 6379) — cache
- **Kafka** (port 9092) — event streaming
- **NATS** (port 4222) — lightweight pub/sub

Verify all containers are running:
```bash
docker compose ps
```

---

## Step 4: Setup Environment Variables

```bash
# In each repo you're working on:
cp .env.example .env
# Edit .env with your local values
```

Key variables for local development:
```bash
DATABASE_URL=postgresql://myproject:password@localhost:5432/myproject
TIMESCALE_URL=postgresql://myproject:password@localhost:5433/events
REDIS_URL=redis://localhost:6379
KAFKA_BROKERS=localhost:9092
NATS_URL=nats://localhost:4222
```

For External API access, ask the team lead for sandbox credentials:
```bash
External_API_BASE_URL=https://quantri.truyxuatnguongoc.gov.vn/gwdev
External_CLIENT_ID=<ask team lead>
External_CLIENT_SECRET=<ask team lead>
```

---

## Step 5: Run Database Migrations

```bash
cd myproject-infra
pnpm run db:migrate
pnpm run db:seed    # Optional: load sample data
```

---

## Step 6: Start Core Services

```bash
cd myproject-core
pnpm install
pnpm run dev
```

This starts all 6 core services via Turborepo. Or start individually:
```bash
pnpm run dev --filter=api-gateway      # Port 8000
pnpm run dev --filter=event-chain      # S1
pnpm run dev --filter=lineage-graph    # S2
pnpm run dev --filter=import-gate      # S3
```

---

## Step 7: Start Frontend (optional)

```bash
cd myproject-frontend
pnpm install
pnpm run dev --filter=web-app          # Port 3000
```

Open http://localhost:3000 to see the dashboard.

---

## Step 8: Run Your First Test

```bash
# Core tests
cd myproject-core
pnpm run test

# Frontend tests
cd myproject-frontend
pnpm run test
```

---

## Which Repo Should I Work On?

| Your task | Start with |
|-----------|-----------|
| Backend API development | myproject-core |
| Frontend/dashboard | myproject-frontend |
| Add shared TypeScript types | myproject-infra |
| Add new FTA or market adapter | myproject-compliance |
| ZK proofs or signing | myproject-crypto (need crypto-core access) |
| Zalo chatbot or IoT sensors | myproject-ingestion |
| AI/ML features | myproject-ai |
| Documentation | myproject-docs |

---

## Common Troubleshooting

| Problem | Solution |
|---------|----------|
| Docker containers won't start | Check Docker Desktop is running. Check ports 5432/5433/6379/9092/4222 are free. |
| `@myproject/shared-types` not found | Run `pnpm install` in myproject-infra first |
| Database connection refused | Check PostgreSQL container: `docker compose logs postgres` |
| External API returns 401 | Check External_CLIENT_ID and External_CLIENT_SECRET in .env |
| Kafka consumer not receiving messages | Check KAFKA_BROKERS in .env. Verify topic exists: `docker compose exec kafka kafka-topics --list --bootstrap-server localhost:9092` |
| Rust build fails on Windows | Install Visual Studio Build Tools with C++ workload |

---

## Useful Links

- **Architecture docs:** `myproject-docs/v1.0/docs/02_PhuLucKyThuat_DevTeam.md`
- **Business workflows:** `myproject-docs/v1.0/docs/03_LuongNghiepVu_22Luong.md`
- **Shared types spec:** `myproject-docs/docs/api/shared-types.md`
- **API contracts:** `myproject-docs/docs/api/internal-api-contracts.md`
- **ADRs:** `myproject-docs/docs/adr/`
- **Coding standards:** `myproject-docs/docs/guidelines/coding-standards.md`

---

## AutoCode System (Autonomous Development)

Project có hệ thống AutoCode cho phép tự động code từ spec:

### Quick Start
1. Viết spec theo template: `myproject-docs/autocode/SPEC_TEMPLATE.md`
2. Chạy autocode:
   ```powershell
   cd D:\Code\Project\myproject-core
   copy D:\Code\Project\myproject-docs\autocode\specs\phase1\1.1-core-event-chain-tests.spec.md spec.md
   powershell -ExecutionPolicy Bypass -File D:\Code\Project\myproject-docs\autocode\autocode.ps1 spec.md
   ```
3. Claude tự đọc spec → code → test → fix → commit

### Chạy cả phase
```powershell
powershell -ExecutionPolicy Bypass -File D:\Code\Project\myproject-docs\autocode\run-phase.ps1 -Phase 1
```

### Tài liệu
- Hướng dẫn đầy đủ: `myproject-docs/autocode/HUONG_DAN_CHAY.md`
- Master plan: `myproject-docs/autocode/MASTER_PLAN.md`
- Spec template: `myproject-docs/autocode/SPEC_TEMPLATE.md`
