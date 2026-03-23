# AutoCode — Autonomous Coding System

AutoCode is a spec-driven autonomous coding system that uses Claude Code to implement features from start to finish without human intervention. It reads a spec file, writes code, runs tests, fixes failures, and commits the result.

## The Golden Triangle: Spec -> Agent -> Environment

```
+---------------+     +----------------+     +----------------+
|   SPEC.md     |---->|  Claude Code   |---->|  Terminal      |
|  (Blueprint)  |     |  (Brain)       |     |  (Hands)       |
|               |     |                |     |                |
| - Schema      |     | - Read spec    |     | - go test      |
| - Rules       |     | - Write code   |     | - cargo test   |
| - DoD tests   |     | - Fix errors   |     | - pnpm test    |
+---------------+     +----------------+     +----------------+
                             |
                      +------+------+
                      | LOOP until  |
                      | all PASS    |
                      | then COMMIT |
                      +-------------+
```

## Quick Start

### 1. Configure

Copy the example config and customize for your project:

```bash
cp autocode.config.example autocode.config
# Edit autocode.config with your project settings
```

Key settings in `autocode.config`:
- `PROJECT_NAME` — Your project name (used in display and default repo names)
- `PROJECT_ROOT` — Root directory containing all your repos
- `REPO_MAP_*` — Map short names to actual repo folder names
- `MAX_TURNS`, `MAX_RETRIES`, `MAX_COST_USD` — Safety guardrails

### 2. Write a Spec

Copy the template and fill in your feature details:

```bash
cp SPEC_TEMPLATE.md /path/to/your-repo/spec.md
# Edit spec.md for the module you want to build
```

See `examples/example-feature.spec.md` for a complete example.

### 3. Run AutoCode

**Option A: Terminal / VPS**
```bash
./autocode.sh /path/to/your-repo spec.md
```

**Option B: VSCode Terminal**
```bash
cd /path/to/your-repo
bash /path/to/autocode/autocode-vscode.sh spec.md
```

**Option C: Docker Sandbox (safest)**
```bash
./autocode-docker.sh your-repo-name spec.md
```

**Option D: Batch — run multiple specs**
```bash
./autocode-batch.sh specs-directory/
```

### 4. Choose an Agent (optional)

```bash
# Use backend architect for system design
./autocode.sh /path/to/repo spec.md --agent engineering-backend-architect

# Use SRE for monitoring/infra
./autocode.sh /path/to/repo spec.md --agent engineering-sre

# Available agents:
#   engineering-senior-developer (default)
#   engineering-backend-architect
#   engineering-frontend-developer
#   engineering-software-architect
#   engineering-database-optimizer
#   engineering-sre
#   engineering-devops-automator
#   engineering-security-engineer
#   engineering-code-reviewer
```

## The Self-Healing Loop

```
START
  |
  v
+-----------+
| Read Spec |
+-----+-----+
      |
      v
+-----------+
| Code      |<------------------+
+-----+-----+                   |
      |                         |
      v                         |
+-----------+    FAIL     +-----+-----+
| Test      |------------>| Fix Error |
+-----+-----+             +-----------+
      |
      | PASS
      v
+-----------+    FAIL     +-----------+
| Lint      |------------>| Fix Lint  |--+
+-----+-----+             +-----------+  |
      |                                  |
      | PASS                             |
      v                                  |
+-----------+    FAIL     +-----------+  |
| Build     |------------>| Fix Build |--+
+-----+-----+             +-----------+
      |
      | PASS
      v
+----------+
| Commit   |
+----------+
```

## Safety Guardrails

| Risk | Mitigation |
|------|------------|
| Infinite loop | `MAX_TURNS` setting (default: 200 turns) |
| Token cost | `MAX_COST_USD` setting (default: $10/session) |
| Code damage | Docker sandbox + checkpoint commits |
| Deleted files | Git restore if needed |

## Files

```
autocode/
├── README.md                  # This file
├── autocode.config.example    # Example configuration (copy to autocode.config)
├── SPEC_TEMPLATE.md           # Standard spec template
├── autocode.sh                # Main script (terminal/VPS)
├── autocode.ps1               # PowerShell version (Windows)
├── autocode-vscode.sh         # Script for VSCode terminal
├── autocode-docker.sh         # Docker sandbox runner
├── autocode-batch.sh          # Batch runner for multiple specs
├── run-phase.ps1              # Phase runner (PowerShell, runs all specs in a phase)
└── examples/
    └── example-feature.spec.md  # Example spec
```

## Phase Runner (PowerShell)

For running all specs in a phase directory automatically:

```powershell
# Run all specs in phase 1
.\run-phase.ps1 -Phase 1

# Resume from spec #5
.\run-phase.ps1 -Phase 2 -StartFrom 5
```

The phase runner reads `REPO_MAP_*` entries from `autocode.config` to map spec filenames to repository directories.

## Writing Good Specs

A good spec should contain:

1. **Objective** — What the module does and why
2. **Input/Output Schema** — Data structures with types
3. **Business Rules** — Numbered rules (RULE-01, RULE-02, ...) with examples
4. **Edge Cases** — Boundary conditions and error scenarios
5. **Dependencies** — Internal and external packages
6. **Definition of Done** — Test commands, lint commands, build commands
7. **Constraints** — Performance targets, security requirements

Each business rule becomes a test case. The more precise the spec, the better the output.

---

## Tieng Viet

### Huong dan nhanh

1. Copy `autocode.config.example` thanh `autocode.config`, sua cau hinh cho du an cua ban
2. Viet spec theo `SPEC_TEMPLATE.md`
3. Chay: `./autocode.sh /duong-dan/repo spec.md`
4. AI se tu dong doc spec, viet code, chay test, sua loi, va commit

### Vong lap tu sua loi

AutoCode chay vong lap: Code -> Test -> Fix -> Lint -> Build -> Commit. Neu test fail, no tu doc loi va sua cho den khi pass hoac het so lan thu (MAX_RETRIES).

### An toan

- `MAX_TURNS=200`: Gioi han so luot tuong tac
- `MAX_COST_USD=10`: Gioi han chi phi moi phien
- Docker sandbox: Chay trong container de khong anh huong moi truong
- Checkpoint commits: Commit sau moi module thanh cong
