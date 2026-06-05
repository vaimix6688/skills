---
name: use-case-writer
description: Soạn đặc tả Use Case theo chuẩn IT BA template 13-field (Karl Wiegers / IIBA), output Markdown song ngữ Việt-Anh (Việt là chính). Dùng skill này khi BA cần scope, phân tích, soạn, refine hoặc review một Use Case. Trigger gồm "viết use case", "viết UC", "draft UC", "đặc tả use case", "phân tích use case", "tách feature thành use case", "review UC của tôi", "viết normal course / alternative course / exceptions", "định nghĩa actor", và các biến thể tiếng Anh "write a use case", "use case specification", "split feature into use cases", "review my UC". Cũng trigger khi user paste một feature/BRD/PRD và yêu cầu chuyển thành UC. Skill enforce guideline Cockburn (coffee-break test, goal levels) và chạy checklist chất lượng 20 điểm. Output Markdown 13 field (Actor, Description, Pre/Postconditions, Priority, Frequency, Normal/Alternative Courses, Exceptions, Includes, Special Req, Assumptions, Notes). KHÔNG dùng cho Agile User Story, PRD/URD/SRS, hay sơ đồ UML.
author: Phúc NT @ BA Zone (ECareHome edition — Việt-hoá fork)
source: https://github.com/ba-zone
---

# Use Case Writer — Skill cho IT Business Analyst
> Gốc by **Phúc NT** · BA Zone · Digital School — bản ECareHome edition đã Việt-hoá output + đổi ví dụ sang domain home-service.

Skill này giúp IT BA **scope, phân tích, và soạn Use Case** dưới dạng Markdown song ngữ (Việt là chính), theo template 13-field chuẩn (Karl Wiegers / IIBA), kèm best practice từ "Writing Effective Use Cases" của Alistair Cockburn và IIBA BABOK Guide.

Phương pháp gốc do **Phúc NT** xây dựng trong chương trình **Digital School** của **BA Zone** — cộng đồng Business Analyst & Product Owner Việt Nam. Bản này chỉ sửa ngôn ngữ output và bộ ví dụ; giữ nguyên toàn bộ phương pháp.

## Khi nào dùng skill này

Trigger skill này khi user cần:
- Soạn UC mới từ mô tả feature, BRD, hoặc PRD
- Refine / review một UC đã có (completeness, correctness)
- Tách một feature lớn thành nhiều UC nhỏ (scope identification)
- Viết riêng một mục: Normal Course, Alternative Course, Exceptions
- Validate UC theo checklist chất lượng

## Output rules (bất di bất dịch)

1. **Ngôn ngữ — Việt-first song ngữ.** UC artifact viết **tiếng Việt là chính**, dùng tiếng Anh cho **technical term**. KHÔNG dịch các term: `UC`, `Actor`, `FSM`, `Saga`, `Outbox`, `Idempotency`, `RBAC`, `ADR`, `SLO`, `MCP`, `Normal Course`, `Alternative Course`, `Exception`, `Precondition`, `Postcondition`, `Trigger`. **Field label giữ nguyên tiếng Anh** (Use Case ID, Actor, Description, …) vì đó là thuật ngữ chuẩn BA. Đây là quy ước của repo `ech-docs` (xem `CLAUDE.md` §Doc Editing Conventions #4). Nếu user yêu cầu rõ output tiếng Anh thì làm theo.
2. **Format**: Markdown (`.md`). Dùng layout bảng 2 cột giống template gốc.
3. **Mode**: Tuần tự — sinh từng nhóm mục một, **dừng và chờ user xác nhận** trước khi sang nhóm tiếp. KHÔNG dump cả UC một lần trừ khi user nói rõ "cho tôi cả UC luôn".

---

## Workflow: 4 bước

```
Bước 1: CLASSIFY INPUT     →  xác định user đang ở mode nào
Bước 2: SCOPE THE UC       →  áp 4 scoping rule + coffee-break test
Bước 3: WRITE THE UC       →  điền 13 field, MỖI LẦN 1 NHÓM
Bước 4: VALIDATE           →  chạy checklist 20 điểm trước khi handover
```

---

## Bước 1: Classify input và chọn mode

Trước khi viết gì, xác định user đang ở mode nào:

| Mode | Tín hiệu | Hành động |
|------|----------|-----------|
| **Mode A: Viết mới từ feature** | User paste mô tả feature, BRD, PRD, hoặc nói "viết UC cho feature X" | Sang Bước 2 (scope) → Bước 3 (viết tuần tự) |
| **Mode B: Tách feature lớn thành UC list** | User nói "tách thành danh sách UC", "feature này cần bao nhiêu UC", upload PRD lớn | Đào sâu Bước 2 (áp 3 kỹ thuật identification), output **UC List trước**, rồi hỏi user muốn viết chi tiết UC nào |
| **Mode C: Refine / review UC có sẵn** | User paste UC có sẵn và hỏi "review giúp", "đủ chưa", "thiếu gì" | Bỏ qua Bước 2, sang thẳng Bước 4 (validate checklist) |
| **Mode D: Viết riêng 1 mục** | User nói "viết Normal Course cho UC này", "thêm Exceptions" | Đọc context UC, nhảy tới phần liên quan của Bước 3 |

**Golden rule**: Nếu input mơ hồ (chỉ 1 dòng), **HỎI trước khi viết** — không bịa. Hỏi tối đa 3 câu:
1. Primary actor là ai? (role / user class cụ thể)
2. Goal cụ thể của actor trong UC này là gì?
3. UC này thuộc system / module nào?

Trao đổi với user bằng ngôn ngữ của họ (Việt hoặc Anh), nhưng UC artifact luôn theo quy ước Output rule #1.

---

## Bước 2: Scope the Use Case

Đây là phần **quan trọng nhất và dễ sai nhất**. Đọc kỹ.

### 2.1. Bốn scoping rule

**Rule 1 — Coffee-break test (Alistair Cockburn)**
Sau khi hoàn thành UC, actor có thể đi nghỉ uống cà phê mà không thấy việc còn dang dở không? Nếu KHÔNG → UC quá thấp (sub-function), gộp lại. Nếu CÓ → scope đúng (user-goal level).

**Rule 2 — Goal Level (3 mức của Cockburn)**
- **Summary level (cloud)**: UC trải nhiều session. VD "Quản lý vòng đời đặt dịch vụ" → quá cao, KHÔNG viết thành 1 UC.
- **User-goal level (sea level)** ✅: 1 actor, 1 session, đạt 1 business goal. VD "Đặt thợ sửa điều hòa" → đúng mức cho 1 UC.
- **Sub-function level (fish)**: 1 bước nhỏ bên trong UC khác. VD "Verify OTP" → quá thấp, để làm Includes trong UC khác.

**Rule 3 — One Actor, One Goal, One Session**
Mỗi UC có ĐÚNG: 1 primary actor + 1 business goal + hoàn thành trong 1 session liên tục. Thấy 2 goal khác nhau → tách thành 2 UC.

**Rule 4 — System Boundary**
UC mô tả **tương tác** giữa actor và system, KHÔNG mô tả nội bộ system. Mỗi bước phải là một trong:
- Actor làm gì đó với system (input)
- System phản hồi actor (output)
Nếu một bước không có actor lẫn UI → đó là design detail, không thuộc UC.

### 2.2. Ba kỹ thuật identify UC (cho Mode B)

Khi tách feature lớn thành UC list:

**Kỹ thuật 1: Goal-driven (top-down)**
Liệt kê mọi goal của từng actor → mỗi goal = 1 UC ứng viên.

**Kỹ thuật 2: Event-driven (trigger ngoài + trong)**
- External event: hành động user (click, submit, đến giờ hẹn)
- Internal event: system tự kích (cron job, batch process)
Mỗi event sinh ra một system response → UC ứng viên.

**Kỹ thuật 3: CRUD-driven (data-centric)**
Với mỗi business entity (Booking, Worker, Wallet, Dispute, …), kiểm tra system có cần Create / Read / Update / Delete không. Mỗi cái = 1 UC ứng viên (có thể gộp R-U-D cùng entity nếu logic giống nhau).

### 2.3. Output của Bước 2

**Mode A**: Một câu chốt scope, rồi YÊU CẦU USER XÁC NHẬN trước khi sang Bước 3:
> "Scope đã chốt: UC ở user-goal level. Primary actor: [X]. Goal: [Y]. System boundary: [Z]. Xác nhận để sang Bước 3?"

**Mode B**: Một bảng UC List:
```
| UC ID      | UC Name (verb + noun)              | Primary Actor | Goal | Priority |
| UC-BOOK-01 | Đặt thợ sửa chữa thiết bị          | Khách hàng    | ...  | High     |
| UC-BOOK-02 | Đặt lịch bảo trì định kỳ           | Khách hàng    | ...  | Medium   |
| UC-PAYOUT-01 | Rút tiền từ ví thợ               | Thợ           | ...  | High     |
```
Rồi hỏi: "Anh/chị muốn tôi viết chi tiết UC nào trước?"

---

## Bước 3: Viết Use Case — từng mục một

**QUAN TRỌNG**: Sinh MỖI LẦN 1 NHÓM MỤC, rồi **DỪNG và hỏi user xác nhận** trước khi tiếp. Không dump cả UC.

Đọc `references/template-guide.md` để biết hướng dẫn điền từng field.
Đọc `references/writing-style.md` để biết quy ước viết (active voice, đánh số, anti-pattern).

### 3.1. Template (cấu trúc output)

```markdown
| **Use Case ID:**        | UC-XX-YY                                   |
| **Use Case Name:**      | [Động từ hành động + danh từ]               |
| **Created By:**         |          | **Last Updated By:**   |       |
| **Date Created:**       |          | **Date Last Updated:** |       |

| **Actor:**              | [Primary actor] / [Secondary actors]       |
| **Description:**        | [2-3 câu: WHY + WHAT + OUTCOME]            |
| **Preconditions:**      | 1. ... 2. ...                              |
| **Postconditions:**     | 1. ... 2. ...                              |
| **Priority:**           | High / Medium / Low                        |
| **Frequency of Use:**   | [X lần / đơn vị thời gian]                  |
| **Normal Course of Events:** | 1. Actor... 2. System... 3. ...       |
| **Alternative Courses:**| UC-XX-YY.AC.1: [tên]                       |
| **Exceptions:**         | UC-XX-YY.EX.1: [tên]                       |
| **Includes:**           | UC-AA-BB                                   |
| **Special Requirements:**| [Non-functional: perf, security…]         |
| **Assumptions:**        | 1. ...                                     |
| **Notes and Issues:**   | TBD-1: [câu hỏi mở] / Owner / Due          |
```

Template copy-ready nằm ở `assets/uc-template.md`.

### 3.2. Sinh tuần tự — 5 nhóm mục

Sinh **đúng thứ tự này**, dừng và hỏi xác nhận sau mỗi nhóm:

> **Nhóm 1 — Identification + Actor + Description**
> Output: Use Case ID, Name, History (Created By / Date), Actor, Description.
> Rồi nói: *"Nhóm 1 xong. Xác nhận để sang preconditions, postconditions, priority, frequency?"*

> **Nhóm 2 — Conditions + Priority + Frequency**
> Output: Preconditions, Postconditions, Priority, Frequency of Use.
> Rồi nói: *"Nhóm 2 xong. Xác nhận để sang Normal Course?"*

> **Nhóm 3 — Normal Course of Events**
> Output: happy path đánh số từng bước.
> Rồi nói: *"Normal Course xong. Xác nhận để sang Alternative Courses và Exceptions?"*

> **Nhóm 4 — Alternative Courses + Exceptions**
> Output: AC.1, AC.2…, EX.1, EX.2…
> Rồi nói: *"Nhóm 4 xong. Xác nhận để sang nhóm cuối (Includes, Special Req, Assumptions, Notes)?"*

> **Nhóm 5 — Includes + Special Requirements + Assumptions + Notes and Issues**
> Output: các field còn lại.
> Rồi nói: *"Đã xong tất cả. Chạy validation 20 điểm luôn nhé?"*

**Nếu user yêu cầu sửa** một nhóm trước đó, áp thay đổi và xác nhận lại trước khi tiếp.

**Nếu user nói "viết hết luôn"** hoặc "cho tôi cả UC một lần", làm theo — nhưng cảnh báo ngắn rằng mode tuần tự bắt lỗi tốt hơn.

### 3.3. Quy tắc điền field QUAN TRỌNG (lỗi hay gặp nhất)

**Use Case ID**: Format `UC-<module>-<seq>`, vd `UC-BOOK-01`. Phân cấp X.Y nếu có nhóm UC.

**Use Case Name**: PHẢI là "**Động từ + Tân ngữ**" (active voice).
- ✅ "Đặt thợ sửa điều hòa", "Rút tiền từ ví thợ", "Duyệt yêu cầu hoàn tiền"
- ❌ "Đặt dịch vụ" (thiếu rõ object), "Khách hàng đặt thợ" (lẫn actor), "Quản lý đơn hàng" (động từ mơ hồ)

**Actor**: Phân biệt:
- *Primary actor*: khởi tạo UC, hưởng lợi từ kết quả
- *Secondary actor*: system/người hỗ trợ (Payment Gateway, eSMS, Cert Partner)
Không bao giờ viết "User" — phải cụ thể (Khách hàng, Thợ, CS Agent, CS Manager, Worker Care, Admin…).

**Preconditions**: Điều kiện PHẢI đúng trước khi UC bắt đầu. Phân biệt với business rule!
- ✅ "Khách hàng đã đăng nhập và có tài khoản đã verify OTP"
- ❌ "Khách hàng có nhu cầu sửa đồ" (động cơ — không verify được)

**Postconditions**: Trạng thái system SAU khi UC hoàn thành thành công. Phải verify được.
- ✅ "Bản ghi booking được tạo với status='matched'; khách nhận thông báo thợ đã nhận đơn"
- ❌ "Khách hàng hài lòng" (không verify được)

**Normal Course of Events** (quan trọng nhất):
- Danh sách đánh số, mỗi bước một hành động
- Xen kẽ bước Actor / System (chủ ngữ phải rõ)
- Mỗi bước bắt đầu bằng chủ ngữ rõ + động từ chủ động
- **KHÔNG nhúng if/else, vòng lặp, hay exception** — cho vào mục Alternative/Exception
- Kể chuyện: từ trigger đến goal đạt được
- ✅ "1. Khách hàng chọn loại dịch vụ trên app.  2. System hiển thị danh sách thợ gần nhất kèm giá.  3. Khách hàng bấm 'Đặt thợ'."
- ❌ "1. Nếu khách có voucher thì nhập mã, không thì sang bước thanh toán…" (nhúng nhánh rẽ)

**Alternative Courses**: Đường đi khác mà **vẫn dẫn tới thành công**. VD thanh toán bằng MoMo thay vì tiền mặt. Format `UC-XX.AC.N` + "Tại bước Y của Normal Course, nếu [điều kiện], thực hiện alternative: …"

**Exceptions**: Trường hợp **goal thất bại** (lỗi, validate fail, timeout). Format `UC-XX.EX.N`. Mỗi exception cần: trigger condition + system response + final state.

**Includes**: Danh sách sub-UC được UC này "gọi" (chức năng dùng chung). VD UC "Đặt thợ" includes UC "Xử lý thanh toán".

**Special Requirements**: Non-functional requirement riêng cho UC này:
- Performance: "Trang danh sách thợ load ≤ 2s khi 5.000 khách đồng thời"
- Security: "Dữ liệu thanh toán mã hóa khi truyền (TLS 1.3)"
- Usability, Reliability, Compliance…

**Assumptions**: Điều giả định khi phân tích. Khác Precondition — precondition là yêu cầu cứng; assumption là niềm tin chưa được verify.

**Notes and Issues**: Danh sách TBD theo format `[TBD-N] | Owner | Due date | Resolution`.

---

## Bước 4: Validate theo checklist 20 điểm

**LUÔN chạy checklist này TRƯỚC khi handover UC.** Mục nào fail thì sửa hoặc flag cho user.

Đọc `references/quality-checklist.md` để xem checklist đầy đủ kèm ví dụ. 20 mục, theo nhóm:

### Scope & Identification (5 mục)
- [ ] **C1**: UC Name theo "động từ + tân ngữ", active voice
- [ ] **C2**: UC ở user-goal level (qua coffee-break test)
- [ ] **C3**: UC ID duy nhất, theo naming convention
- [ ] **C4**: Đúng 1 primary actor + 1 business goal rõ
- [ ] **C5**: System boundary rõ ràng (không lẫn với UC khác)

### Actor & Context (3 mục)
- [ ] **C6**: Actor là role/class cụ thể, không phải "User"
- [ ] **C7**: Description trả lời WHY (lý do) + WHAT (hành động) + OUTCOME (kết quả)
- [ ] **C8**: Frequency of Use có con số (không "thỉnh thoảng")

### Pre/Post Conditions (3 mục)
- [ ] **C9**: Preconditions verify được (không phải business rule trá hình)
- [ ] **C10**: Postconditions phủ trạng thái thành công và mọi thay đổi system
- [ ] **C11**: Không nhầm Preconditions với Assumptions

### Normal Course (4 mục)
- [ ] **C12**: Danh sách đánh số, mỗi bước một hành động
- [ ] **C13**: Xen kẽ Actor / System, chủ ngữ rõ
- [ ] **C14**: KHÔNG nhúng if/else/loop trong Normal Course
- [ ] **C15**: Flow chạy từ trigger tới postcondition (không bước lửng)

### Alternative & Exception (3 mục)
- [ ] **C16**: Mỗi AC ghi rõ "tại bước N" + điều kiện
- [ ] **C17**: Mỗi Exception có trigger + system response + final state
- [ ] **C18**: Phủ các failure mode thường gặp (timeout, input sai, network, permission denied, concurrency conflict)

### Completeness (2 mục)
- [ ] **C19**: Includes (nếu có) trỏ tới UC đang tồn tại
- [ ] **C20**: Special Requirements không lặp lại functional requirement

**Output validation**: Bảng `Item | Status | Note` với marker ✅ ❌ ⚠️.

---

## Chi tiết format output

- Output Markdown song ngữ (Việt là chính) theo Output rule #1
- Dùng layout bảng 2 cột khớp template gốc
- Lưu file `.md` nếu user muốn file tải về; nếu không thì hiển thị inline trong chat
- Quy ước đặt tên file: `<UC-ID>_<UC-Name-kebab>.md`, vd `UC-BOOK-01_dat-tho-sua-chua-thiet-bi.md`

---

## Tích hợp với repo ECareHome `ech-docs`

Skill này dùng cho **requirement-UC** (UC theo actor, user-goal level). LƯU Ý phân biệt với artifact UC sẵn có trong `ech-docs`:

| Artifact | File | Bản chất | Skill này có viết không? |
|----------|------|----------|--------------------------|
| Use Case Diagram | `02-requirements/2.3` | Sơ đồ mermaid liệt kê **tên** UC | Không — chỉ tham chiếu ID |
| Comprehensive User Cases | `02-requirements/2.7` | Roleplay persona × scenario | Không — đó là persona matrix |
| **Đặc tả requirement-UC chi tiết** | (chưa có) | 13-field theo actor | **CÓ — đây là output của skill** |
| Cross-Module Design Flow | `04-technical/4.108` | UC-chain orchestration kỹ thuật | KHÔNG — đó là design flow, vi phạm system-boundary rule của UC |

→ Khi viết UC trong context ECareHome: lấy UC ID/tên từ `2.3`, đối chiếu persona ở `2.7`, tham chiếu Business Rule ở `2.4` (`BR-XX`), và **không** lẫn sang phong cách `4.108`. Giữ technical term theo `CLAUDE.md` §Doc Editing Conventions #4.

---

## References

- `references/template-guide.md` — Hướng dẫn chi tiết từng field (ví dụ home-service)
- `references/writing-style.md` — Quy ước viết (active voice, đánh số, anti-pattern)
- `references/quality-checklist.md` — Checklist 20 điểm kèm ví dụ pass/fail
- `references/examples-home-service.md` — 2 UC home-service hoàn chỉnh (Đặt thợ, Duyệt hoàn tiền)
- `assets/uc-template.md` — Template Markdown copy-ready

---

## Anti-pattern (TUYỆT ĐỐI tránh)

1. **UC = UI flow**: Mô tả từng cú bấm nút và popup → đó là wireframe spec, không phải UC
2. **UC = User Story**: UC mô tả tương tác chi tiết; US là một dòng "Là… tôi muốn… để…"
3. **UC = Business Process**: BP phủ cả quy trình nghiệp vụ (nhiều người, nhiều system); UC phủ 1 actor + 1 system
4. **Động từ mơ hồ trong UC Name**: "Quản lý", "Xử lý", "Thực hiện" — quá chung. Dùng động từ hành động cụ thể
5. **Trộn concern**: Nhồi đặt thợ + thanh toán + thông báo vào một UC khổng lồ → tách bằng Includes
6. **Quên exception**: Chỉ viết happy path, không có failure mode → không đủ cho dev/QA
7. **Precondition mơ hồ**: "System sẵn sàng" → vô nghĩa. Phải verify được

---
*Phương pháp gốc by **Phúc NT** · BA Zone · Digital School*
*Bản ECareHome edition: Việt-hoá output + đổi ví dụ sang home-service. Giữ nguyên attribution theo LICENSE.*
