# Quality Checklist — 20 điểm validate một Use Case

Chạy checklist này TRƯỚC khi handover UC. Mỗi mục có: định nghĩa, cách check, ví dụ pass/fail. Ví dụ trong domain home-service (ECareHome).

> Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition.

## Cách dùng

1. Sau khi viết UC, rà từng mục C1-C20
2. Đánh Status: ✅ Pass / ❌ Fail / ⚠️ Cần review
3. Fail → sửa hoặc flag cho user
4. Output bảng tổng kết ở cuối

```
| Item | Status | Note |
| C1   | ✅     | UC Name "Đặt thợ sửa chữa thiết bị" đúng format |
| C2   | ⚠️     | UC có thể tách thêm — xác nhận với PO |
| ...  | ...    | ... |
```

---

## NHÓM A: Scope & Identification (C1-C5)

### C1. UC Name theo "động từ + tân ngữ", active voice
**Định nghĩa**: UC Name bắt đầu bằng động từ hành động + danh từ tân ngữ, không nhồi tên actor.
**Cách check**: Parse UC Name → xác định động từ đầu → kiểm tra là động từ hành động.
**Pass**: "Đặt thợ sửa chữa thiết bị", "Duyệt yêu cầu hoàn tiền", "Xác minh chứng chỉ tay nghề"
**Fail**: "Đặt dịch vụ" (chưa rõ object), "Khách hàng đặt thợ" (nhồi actor), "Quản lý booking" (động từ mơ hồ)

### C2. UC ở user-goal level (qua coffee-break test)
**Định nghĩa**: Sau khi hoàn thành UC, actor có thể dừng nghỉ — goal đã đạt.
**Cách check**: Đọc Postconditions → tự hỏi "Đây có phải kết quả có ý nghĩa nghiệp vụ không?"
- Kết quả chỉ là sub-step (vd "OTP đã verify") → UC quá nhỏ
- Kết quả trải nhiều session → UC quá lớn
**Pass**: "Đặt thợ sửa chữa thiết bị" → postcondition: booking matched, thợ đã nhận đơn. "Rút tiền từ ví thợ" → postcondition: yêu cầu rút đã submit, gateway đã nhận lệnh.
**Fail**: "Verify OTP" (quá nhỏ — chỉ là sub-step) → nên là Includes. "Quản lý toàn bộ vòng đời khách hàng" (quá lớn) → tách nhiều UC.

### C3. UC ID duy nhất, theo naming convention
**Cách check**: Check UC list — ID có duy nhất không? Format có khớp `UC-<module>-<seq>`?
**Pass**: "UC-BOOK-01", "UC-PAYOUT-03"
**Fail**: "UC1" (không module), "UseCase_DatTho" (nhồi tên)

### C4. Đúng 1 primary actor + business goal rõ
**Cách check**: Field Actor có "Primary: [X]"? Description có nêu goal rõ? Thấy 2 primary actor → flag tách.
**Pass**: Primary: Khách hàng. Goal: đặt được thợ tới sửa thiết bị và nhận xác nhận.
**Fail**: Primary: Khách hàng + CS Agent (2 actor) → Tách: "Khách tự đặt thợ" và "CS đặt thợ hộ khách".

### C5. System boundary rõ ràng
**Định nghĩa**: UC mô tả tương tác với một system cụ thể, không trộn nhiều system.
**Cách check**: Đọc Normal Course → các bước "System…" có nhất quán trỏ về một system?
**Pass**: Mọi bước trỏ "app ECareHome". Payment Gateway, eSMS là secondary actor.
**Fail**: Trộn app khách + app thợ + admin web như thể là một system → tách theo boundary hoặc làm rõ system chính.

---

## NHÓM B: Actor & Context (C6-C8)

### C6. Actor là role/class cụ thể
**Cách check**: Actor là role cụ thể hay "User"?
**Pass**: "Khách hàng (đã verify OTP)", "Thợ (đã verify chứng chỉ, ví đã liên kết)"
**Fail**: "User", "Người dùng", "Actor 1"

### C7. Description trả lời WHY + WHAT + OUTCOME
**Cách check**: Đọc Description → kiểm tra đủ 3 yếu tố.
**Pass**: "Khi thiết bị hỏng và khách cần thợ [WHY], khách mở app chọn dịch vụ và đặt thợ [WHAT]. UC kết thúc khi booking được tạo status='matched', thợ đã nhận đơn, khách nhận SMS xác nhận [OUTCOME]."
**Fail**: "UC này về đặt thợ." (thiếu WHY và OUTCOME)

### C8. Frequency of Use có con số
**Cách check**: Field Frequency có CON SỐ không?
**Pass**: "~800 booking/ngày toàn nền tảng; peak ~120/giờ buổi tối và cuối tuần"
**Fail**: "Thường xuyên", "Hằng ngày" (không volume)
⚠️ Chấp nhận: "TBD — chờ số liệu analytics từ ops" + ghi vào Notes là [TBD-N]

---

## NHÓM C: Pre/Post Conditions (C9-C11)

### C9. Preconditions verify được
**Cách check**: Mỗi precondition có verify được bằng query / boolean test không?
**Pass**: "Khách đã đăng nhập và verify OTP" (DB query), "Payment Gateway sẵn sàng" (health check)
**Fail**: "Khách có nhu cầu sửa đồ" (động cơ — không verify), "System sẵn sàng" (quá mơ hồ)

### C10. Postconditions phủ trạng thái thành công + mọi thay đổi
**Cách check**: Postconditions có mô tả mọi thay đổi sau khi UC chạy không?
- Thay đổi data (bản ghi nào, field nào)
- Trạng thái ngoài (thông báo gửi, lịch chặn, file sinh)
- Trạng thái với user (màn hình mới, badge)
**Pass**:
```
1. Booking được tạo với status='matched', worker_id đã gán
2. Thợ nhận push notification và xem được chi tiết đơn
3. Khách thấy màn hình "Đã tìm được thợ" + ETA
4. Sự kiện booking.matched ghi vào audit log (I-04)
5. SMS xác nhận gửi tới khách trong 60s
```
**Fail**: Chỉ "Đặt thợ thành công" → thiếu chi tiết trạng thái.

### C11. Không nhầm Preconditions với Assumptions
**Cách check**: Phân biệt — Precondition: PHẢI ĐÚNG, system check được. Assumption: TIN là đúng, không verify.
**Lỗi hay gặp**: Đặt "Khách biết dùng smartphone cơ bản" vào Precondition → SAI, đó là Assumption. System không check được.

---

## NHÓM D: Normal Course (C12-C15)

### C12. Danh sách đánh số, mỗi bước một hành động
**Cách check**: Mỗi bước có bắt đầu bằng số? Chỉ một hành động chính? Không có "và" nối hai loại hành động khác nhau?
**Pass**: "3. Khách hàng nhập mô tả sự cố, khung giờ và địa chỉ." (cùng loại — điền form)
**Fail**: "3. Khách nhập mô tả và bấm Tìm thợ và chờ kết quả." (3 hành động một bước)

### C13. Xen kẽ Actor / System, chủ ngữ rõ
**Cách check**: Các bước có pattern xen kẽ Actor/System?
**Pass**:
```
1. Khách hàng bấm Đặt thợ              ← Actor
2. System hiển thị màn hình Tóm tắt đơn ← System
3. Khách hàng chọn phương thức thanh toán ← Actor
4. System tạo booking và gửi đề nghị tới thợ ← System
```
(OK có 2 bước Actor liên tiếp khi cả hai là input — vẫn rõ)
**Fail**: Chỉ "Khách làm X, rồi Y, rồi Z" không có system response.

### C14. KHÔNG nhúng if/else/loop trong Normal Course
**Cách check**: Tìm "nếu", "trong trường hợp", "ngược lại" trong Normal Course → flag.
**Pass**:
```
5. System validate hạn mức rút tiền còn lại của thợ.
6. System tạo yêu cầu rút với status='pending_review'.
```
**Fail**:
```
5. Nếu thợ hạng VIP, system tự duyệt; nếu thợ thường, chuyển CS duyệt; nếu hạn mức = 0, system chặn.
```
→ Tách: Normal Course (flow mặc định) + AC (nhánh khác) + Exception (chặn).

### C15. Flow chạy từ trigger tới postcondition
**Cách check**: Bước 1 có khớp trigger trong Description? Bước cuối có đạt postcondition? Có bước lửng không?
**Pass**: Bước 1 "Khách bấm Đặt thợ" (trigger) → bước 9 "System gửi SMS xác nhận" (postcondition đạt).
**Fail**: Bước cuối là "System lưu booking" nhưng postcondition nói "SMS xác nhận đã gửi" → flow chưa trọn.

---

## NHÓM E: Alternative & Exception (C16-C18)

### C16. Mỗi AC ghi rõ "tại bước N" + điều kiện
**Cách check**: Mỗi Alternative Course có: ID `UC-XX.AC.N`; câu mở "Tại bước Y…, nếu [điều kiện]…"; bước con đánh số 5a, 5b…; câu chốt "tiếp tục từ bước Z".
**Pass**:
```
UC-BOOK-01.AC.1: Để hệ thống tự ghép thợ
Tại bước 5 của Normal Course, nếu khách bấm "Để ECareHome chọn thợ giúp tôi":
5a. System hiển thị "Đang tìm thợ phù hợp nhất…".
5b. System chạy thuật toán matching theo điểm số.
5c. System chọn thợ điểm cao nhất → tiếp tục từ bước 6 của Normal Course.
```
**Fail**: "AC1: Nếu khách có voucher thì dùng voucher." (mơ hồ, không tham chiếu bước, không bước con, không câu nối lại)

### C17. Mỗi Exception có trigger + response + final state
**Cách check**: Mỗi exception có đủ 3 phần?
**Pass**:
```
UC-BOOK-01.EX.2: Không tìm được thợ trong khu vực
Trigger: Tại bước 6, sau 3 vòng đề nghị không thợ nào nhận.
Response: System hiển thị "Chưa có thợ rảnh — để lại nhu cầu, tổng đài gọi lại trong 15 phút?".
Final state: Không tạo booking matched. Nếu khách bấm "Báo nhu cầu", tạo sales lead ưu tiên SLA 15 phút.
```
**Fail**: "EX1: Nếu có lỗi, system hiện thông báo lỗi." (mơ hồ — không trigger, không response chi tiết, không final state)

### C18. Phủ các failure mode thường gặp
**Cách check**: UC có phủ tối thiểu các loại failure liên quan home-service?

| Loại failure | Bắt buộc cho UC home-service? |
|---|---|
| Lỗi validate (input sai) | ✅ |
| Vi phạm business rule (hết thợ, vượt hạn mức) | ✅ |
| Lỗi service ngoài (Payment Gateway, eSMS, Cert Partner timeout) | ✅ |
| Lỗi xác thực/phân quyền | ✅ nếu UC có auth |
| Lỗi mạng/kết nối | ✅ cho flow mobile |
| Concurrency conflict (thợ nhận đơn khác cùng lúc) | ✅ cho UC booking/matching |
| Session timeout | ✅ cho UC có flow review dài |

**Mẹo**: UC chỉ có 1-2 Exception → đáng ngờ. UC booking/payout thường cần 3-5.

---

## NHÓM F: Completeness (C19-C20)

### C19. Includes (nếu có) trỏ tới UC đang tồn tại
**Cách check**: Mỗi UC trong Includes có ID hợp lệ + UC đó tồn tại thật?
**Pass**: "Includes: UC-PAY-01 (Xử lý thanh toán)" → UC-PAY-01 đã viết, có trong UC register.
**Fail**: "Includes: UC thanh toán" → ID không cụ thể, hoặc UC tham chiếu chưa tồn tại.

### C20. Special Requirements không lặp functional requirement
**Cách check**: Mỗi mục trong Special Requirements có phải non-functional không?
**Pass** (non-functional): "Danh sách thợ load ≤ 2s khi 5.000 khách đồng thời" · "Audit log lưu 3 năm" · "Tuân thủ quy định hóa đơn VAT".
**Fail** (functional — thuộc Normal Course / Business Rule): "Validate mã voucher đúng 16 ký tự" → logic validate, thuộc bước Normal Course hoặc BR. "Khách chỉ được đặt 10 đơn/tháng" → business rule.

---

## Validation Report

Sau khi check 20 mục, output report theo format:

```markdown
## Kết quả validation cho UC-BOOK-01

| # | Item | Status | Note |
|---|------|--------|------|
| C1 | UC Name format | ✅ | "Đặt thợ sửa chữa thiết bị" — động từ + tân ngữ |
| C2 | User-goal level | ✅ | Qua coffee-break test |
| C3 | UC ID duy nhất | ✅ | Theo convention |
| C4 | 1 primary actor | ✅ | Khách hàng |
| C5 | System boundary | ✅ | App ECareHome |
| C6 | Actor cụ thể | ✅ | |
| C7 | Description WHY+WHAT+OUTCOME | ✅ | |
| C8 | Frequency có số | ⚠️ | TBD — chờ analytics từ ops |
| C9 | Preconditions verify được | ✅ | 4/4 verify được |
| C10 | Postconditions phủ trạng thái | ✅ | 5 postcondition |
| C11 | Không lẫn Pre/Assumption | ✅ | |
| C12 | Đánh số, 1 hành động/bước | ✅ | 9 bước |
| C13 | Xen kẽ Actor/System | ✅ | |
| C14 | Không nhúng if/else | ✅ | |
| C15 | Flow trọn vẹn | ✅ | |
| C16 | AC ghi "tại bước N" | ✅ | 1 AC, anchor đúng |
| C17 | Exception đủ 3 phần | ✅ | 3 exception đầy đủ |
| C18 | Phủ failure mode | ✅ | Lỗi thanh toán, hết thợ, gateway timeout |
| C19 | Includes hợp lệ | ✅ | UC-PAY-01, UC-NOTI-01 |
| C20 | Special Req non-functional | ✅ | |

**Tổng kết**: 19/20 ✅ + 1 ⚠️. UC sẵn sàng cho stakeholder review.
**Follow-up**: C8 — Frequency of Use chờ số liệu analytics từ ops [TBD-3].
```

---
*Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition.*
