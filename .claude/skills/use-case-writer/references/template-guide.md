# Template Guide — Cách điền từng field

Hướng dẫn chi tiết điền 13 field, kèm ví dụ pass/fail trong domain **home-service (ECareHome)**.

> Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition đổi ví dụ sang home-service.

## Mục lục
1. [Use Case ID](#1-use-case-id)
2. [Use Case Name](#2-use-case-name)
3. [Use Case History](#3-use-case-history)
4. [Actor](#4-actor)
5. [Description](#5-description)
6. [Preconditions](#6-preconditions)
7. [Postconditions](#7-postconditions)
8. [Priority](#8-priority)
9. [Frequency of Use](#9-frequency-of-use)
10. [Normal Course of Events](#10-normal-course-of-events)
11. [Alternative Courses](#11-alternative-courses)
12. [Exceptions](#12-exceptions)
13. [Includes](#13-includes)
14. [Special Requirements](#14-special-requirements)
15. [Assumptions](#15-assumptions)
16. [Notes and Issues](#16-notes-and-issues)

---

## 1. Use Case ID

**Mục đích**: Định danh duy nhất để truy vết requirement về UC.

**Quy tắc**:
- Format: `UC-<module>-<seq>` hoặc `UC-X.Y` (phân cấp)
- Dùng naming convention nhất quán toàn dự án
- Với nhóm UC liên quan, dùng X.Y (vd UC-3.1, UC-3.2 thuộc nhóm "Đặt thợ")
- Pad seq 2-3 chữ số: `UC-BOOK-01`, `UC-PAYOUT-003`

**Ví dụ tốt** (ECareHome): `UC-BOOK-01` (module Booking, UC #1) · `UC-PAYOUT-03` (module Payout, UC #3) · `UC-3.2` (phân cấp, sub-UC #2 của nhóm 3)

**Ví dụ xấu**: `UC1` (không có scheme) · `UseCase_DatTho` (nhồi tên vào ID — khó bảo trì khi tên đổi)

---

## 2. Use Case Name

**Mục đích**: Nhãn ngắn mô tả goal của UC.

**Quy tắc QUAN TRỌNG**:
- PHẢI theo dạng **"Động từ hành động + Tân ngữ"**
- 3-7 từ, không quá dài
- KHÔNG bắt đầu bằng tên actor
- KHÔNG dùng động từ mơ hồ ("quản lý", "xử lý", "thực hiện", "làm")
- Phản ánh goal của actor, không phải implementation

**Pattern**: `<Động từ> <Tân ngữ trực tiếp> [<bổ ngữ>]`

**Ví dụ tốt** (ECareHome): ✅ "Đặt thợ sửa chữa thiết bị" · ✅ "Rút tiền từ ví thợ" · ✅ "Duyệt yêu cầu hoàn tiền tranh chấp" · ✅ "Xác minh chứng chỉ tay nghề thợ" · ✅ "Đặt lịch bảo trì định kỳ"

**Ví dụ xấu → cách sửa**:
- ❌ "Đặt dịch vụ" → ✅ "Đặt thợ sửa chữa thiết bị"
- ❌ "Khách hàng đặt thợ" (lẫn actor) → ✅ "Đặt thợ sửa chữa thiết bị"
- ❌ "Quản lý booking" (động từ mơ hồ) → tách thành "Tạo booking", "Cập nhật booking", "Hủy booking"
- ❌ "Hoàn tiền được duyệt" (passive) → ✅ "Duyệt yêu cầu hoàn tiền"

---

## 3. Use Case History

**Mục đích**: Audit trail (Created By, Date Created, Last Updated By, Date Last Updated).

**Quy tắc**:
- Created By: tên đầy đủ + role (vd "Nguyễn Văn A - BA")
- Date Created: format YYYY-MM-DD
- Last Updated By + Date Last Updated: cập nhật mỗi lần sửa
- Nếu chưa rõ, dùng placeholder `<TBD>` thay vì để trống

---

## 4. Actor

**Mục đích**: Xác định ai/cái gì tương tác với system.

**Loại actor**:
- **Primary actor**: Khởi tạo UC, hưởng lợi từ kết quả
- **Secondary actor**: System/người hỗ trợ (Payment Gateway, eSMS, Cert Partner)
- **Off-stage stakeholder**: Có lợi ích nhưng không tương tác trực tiếp (cơ quan quản lý, auditor) — thường KHÔNG ghi trong field Actor

**Quy tắc**:
- Primary actor PHẢI là role/class cụ thể — không bao giờ viết "User" chung chung
- Một UC nên có 1 primary actor (hiếm khi 2+)
- Có secondary actor thì ghi rõ nhãn

**Ví dụ tốt** (ECareHome):
- ✅ "Primary: Khách hàng (đã đăng ký, verify OTP). Secondary: Payment Gateway (MoMo/VNPay), eSMS."
- ✅ "Primary: Thợ (đã verify chứng chỉ, ví đã liên kết tài khoản). Secondary: Payment Gateway."
- ✅ "Primary: CS Manager (quyền duyệt tranh chấp). Secondary: Worker Care, Audit Log."

**Ví dụ xấu**: ❌ "User" (quá chung) · ❌ "Người dùng" (mơ hồ — khách hay thợ?) · ❌ "System" (system là đối tượng của UC, không phải actor)

---

## 5. Description

**Mục đích**: Tóm tắt UC trong 2-3 câu để người đọc nắm nhanh.

**Quy tắc — phải trả lời 3 câu hỏi**:
1. **WHY**: Lý do/trigger dẫn tới UC này
2. **WHAT**: Actor làm gì với system
3. **OUTCOME**: Kết quả cuối (trạng thái system mới / giá trị cho actor)

**Pattern**: `[Khi/Để] <trigger/lý do>, <actor> <hành động> nhằm <outcome>.`

**Ví dụ tốt** (ECareHome):
> "Khi thiết bị trong nhà hỏng và khách hàng cần thợ tới sửa, khách mở app, chọn loại dịch vụ và đặt thợ gần nhất. UC kết thúc khi một booking được tạo với status='matched', thợ được gán đã nhận đơn, và khách nhận thông báo xác nhận."

**Ví dụ xấu**:
> ❌ "UC này về đặt thợ." (quá ngắn, thiếu WHY và OUTCOME)
> ❌ "Module booking có các bước: chọn dịch vụ, chọn thợ, thanh toán…" (mô tả flow, không phải description)

---

## 6. Preconditions

**Mục đích**: Liệt kê điều kiện PHẢI đúng trước khi UC bắt đầu.

**Quy tắc QUAN TRỌNG**:
- Mỗi precondition phải **verify được** (boolean check)
- Đánh số: 1, 2, 3…
- Phân biệt với Business Rule:
  - Precondition: check TRƯỚC khi UC bắt đầu
  - Business Rule: áp DỤNG trong lúc UC chạy
- Phân biệt với Assumption:
  - Precondition: BẮT BUỘC để UC chạy
  - Assumption: TIN là đúng nhưng không verify

**Ví dụ tốt** (ECareHome):
```
1. Khách hàng đã đăng nhập bằng số điện thoại đã verify OTP.
2. Loại dịch vụ được chọn đang ở trạng thái 'active' và có thợ phục vụ khu vực đó.
3. Khách hàng không có booking nào đang treo chưa thanh toán quá hạn.
4. Payment Gateway (MoMo/VNPay) đang sẵn sàng.
```

**Ví dụ xấu**: ❌ "System đang hoạt động" (quá chung, không verify) · ❌ "Khách muốn sửa đồ" (động cơ, không phải điều kiện) · ❌ "Khách phải có phương thức thanh toán hợp lệ" (thuộc UC thanh toán, không thuộc UC đặt thợ)

---

## 7. Postconditions

**Mục đích**: Mô tả trạng thái system SAU khi UC hoàn thành thành công.

**Quy tắc**:
- Verify được (check qua DB query / API response)
- Phủ mọi loại thay đổi:
  - Trạng thái data (bản ghi mới, đổi status)
  - Trạng thái với user (thông báo đã gửi, file đã tạo)
  - Trạng thái system ngoài (API call thành công, lịch đã chặn)
- Đánh số

**Quan trọng**: Postcondition là một **state**, không phải **action**.
- ✅ State: "Bản ghi booking được lưu với status='matched' và worker_id đã gán"
- ❌ Action: "System lưu bản ghi booking" (đây là bước trong Normal Course)

**Ví dụ tốt** (ECareHome):
```
1. Bản ghi booking được tạo trong bảng bookings với status='matched', kèm worker_id và timestamp.
2. Thợ được gán nhận push notification và có thể xem chi tiết đơn.
3. Khách hàng thấy màn hình "Đã tìm được thợ" kèm thông tin thợ + ETA.
4. Sự kiện booking.matched được ghi vào audit log (hash chain, I-04).
5. Thông báo SMS xác nhận gửi tới khách hàng trong 60 giây.
```

---

## 8. Priority

**Mục đích**: Định độ ưu tiên triển khai UC.

**Scheme thường dùng**: MoSCoW (Must/Should/Could/Won't) · hoặc 3 mức (High/Medium/Low).

**Quy tắc**: Dùng CÙNG scheme với SRS / PRD của dự án. Kèm một câu giải thích vì sao priority đó.

**Ví dụ tốt** (ECareHome):
- "High — Feature cốt lõi; nằm trên happy path E2E, chặn go-live pilot Hà Nội."
- "Medium — Tăng trải nghiệm khách B2B; xếp Phase 2."

---

## 9. Frequency of Use

**Mục đích**: Ước lượng UC chạy bao thường xuyên → input cho capacity planning.

**Quy tắc**: Dùng CON SỐ CỤ THỂ (không "thỉnh thoảng", "thường xuyên"). Đơn vị thời gian phù hợp (giây/giờ/ngày/tháng). Có giờ cao điểm thì ghi rõ.

**Ví dụ tốt** (ECareHome):
- "~800 booking/ngày toàn nền tảng; peak ~120/giờ buổi tối và cuối tuần."
- "~5 yêu cầu rút tiền/ngày mỗi thợ; toàn hệ thống ~700/ngày; peak chiều thứ Sáu sau khi chốt tuần."

**Ví dụ xấu**: ❌ "Thường xuyên" · ❌ "Hằng ngày" (không có volume)

---

## 10. Normal Course of Events

**Mục đích**: Mô tả happy path — các bước từ trigger tới goal đạt được.

**Quy tắc QUAN TRỌNG** (field dễ sai nhất):

### 10.1. Format
- Danh sách đánh số (1, 2, 3…)
- Mỗi bước: một hành động đơn
- Bắt đầu bằng chủ ngữ rõ (Actor / System)
- Active voice + thì hiện tại
- Bước ngắn, 1-2 câu mỗi bước

### 10.2. Xen kẽ Actor / System
Pattern điển hình: Actor → System → Actor → System…
- Bước lẻ: actor input
- Bước chẵn: system response

### 10.3. KHÔNG nhúng:
- ❌ If/else → chuyển sang Alternative Course
- ❌ Vòng lặp → dùng "Bước X-Y lặp lại cho tới khi Z"
- ❌ Exception → chuyển sang Exceptions
- ❌ Logic nội bộ system → đó là design, không phải UC

### 10.4. Bắt đầu và kết thúc
- Bước 1: Trigger (sự kiện kích hoạt UC)
- Bước cuối: Goal đạt được (postcondition thỏa mãn)

**Ví dụ tốt** (ECareHome — đặt thợ sửa chữa):
```
1. Khách hàng mở app và chọn loại dịch vụ cần (vd "Sửa điều hòa").
2. System hiển thị màn hình mô tả sự cố: ô nhập text, nút tải ảnh, nút ghi âm.
3. Khách hàng mô tả sự cố và bấm "Tìm thợ".
4. System hiển thị danh sách thợ gần nhất kèm giá ước tính, đánh giá, khoảng cách.
5. Khách hàng chọn một thợ và bấm "Đặt thợ".
6. System tạo booking với status='matching' và gửi đề nghị tới thợ được chọn.
7. Khi thợ nhận đơn, system cập nhật booking sang status='matched'.
8. System hiển thị màn hình "Đã tìm được thợ" kèm thông tin thợ và ETA.
9. System gọi UC-NOTI-01 để gửi SMS xác nhận tới khách hàng.
```

**Ví dụ xấu → cách sửa**:
- ❌ "1. Nếu khách có gói thành viên thì hiện thợ VIP, không thì hiện thợ thường…" → Chuyển nhánh rẽ sang Alternative Course
- ❌ "3. System validate. Nếu sai hiện lỗi. Nếu đúng tiếp tục." → Nhánh validate-pass đi tiếp trong flow; validate-fail vào Exception
- ❌ "5. System gọi POST /api/v1/bookings với body {customer_id, worker_id, service_id}" → Quá kỹ thuật. Viết: "System tạo booking trong hệ thống đặt lịch"

---

## 11. Alternative Courses

**Mục đích**: Đường đi KHÁC mà vẫn dẫn tới goal (vẫn thành công), chỉ là route khác.

**Quy tắc**:
- Format ID: `UC-XX.AC.N` (AC = Alternative Course)
- Mỗi AC bắt đầu bằng: "Tại bước Y của Normal Course, nếu [điều kiện], thực hiện alternative: …"
- Sau AC, ghi rõ tiếp tục từ bước nào của Normal Course

**Ví dụ tốt** (ECareHome):
```
UC-BOOK-01.AC.1: Đặt thợ bằng cách để hệ thống tự ghép
Tại bước 5 của Normal Course, nếu khách hàng bấm "Để ECareHome chọn thợ giúp tôi":
5a. System ẩn danh sách thợ và hiển thị "Đang tìm thợ phù hợp nhất…".
5b. System chạy thuật toán matching theo điểm số (khoảng cách, đánh giá, tải).
5c. System chọn thợ điểm cao nhất → tiếp tục từ bước 6 của Normal Course.
```

---

## 12. Exceptions

**Mục đích**: Trường hợp UC THẤT BẠI (goal không đạt).

**Quy tắc**:
- Format ID: `UC-XX.EX.N` (EX = Exception)
- Mỗi exception cần 3 phần:
  1. **Trigger condition**: Khi nào exception xảy ra
  2. **System response**: System làm gì
  3. **Final state**: Trạng thái cuối (rollback? partial? log?)

**Failure mode thường gặp cần check** (đừng quên):
- Lỗi validate (sai format, thiếu field)
- Vi phạm business rule (vượt hạn mức, hết thợ)
- Lỗi service ngoài (Payment Gateway timeout, eSMS lỗi)
- Lỗi mạng / kết nối
- Permission denied / authorization fail
- Concurrency conflict (thợ nhận đơn khác cùng lúc)
- Session timeout

**Ví dụ tốt** (ECareHome):
```
UC-BOOK-01.EX.2: Không tìm được thợ trong khu vực
Trigger: Tại bước 6, sau 3 vòng đề nghị, không thợ nào nhận đơn.
Response: System hiển thị "Hiện chưa có thợ rảnh ở khu vực của bạn. Để lại nhu cầu, tổng đài gọi lại trong 15 phút?" kèm nút "Báo nhu cầu".
Final state: Không tạo booking 'matched'. Nếu khách bấm "Báo nhu cầu", system tạo sales lead ưu tiên (SLA 15 phút). Sự kiện no_worker_found ghi vào log.
```

---

## 13. Includes

**Mục đích**: Tái dùng chức năng chung giữa các UC.

**Quy tắc**:
- Liệt kê sub-UC được UC này "gọi" (ngữ nghĩa UML «include»)
- Sub-UC phải tồn tại (có spec riêng)
- KHÔNG dùng Includes chỉ để gom bước lặt vặt — chỉ cho logic được tái dùng ở UC khác

**Ví dụ tốt** (ECareHome):
```
- UC-PAY-01: Xử lý thanh toán post-pay (gọi ở bước 6 của Normal Course)
- UC-NOTI-01: Gửi thông báo đặt thợ (gọi ở bước 9)
```

---

## 14. Special Requirements

**Mục đích**: Non-functional requirement riêng cho UC này.

**Nhóm cần phủ**:
- **Performance**: Thời gian phản hồi, throughput, người dùng đồng thời
- **Security**: Xác thực, mã hóa, quyền riêng tư dữ liệu
- **Usability**: Accessibility, yêu cầu mobile-first
- **Reliability**: Uptime, chiến lược fallback async
- **Compliance**: Yêu cầu pháp lý (hóa đơn VAT, lưu trữ dữ liệu)

**Quy tắc**: KHÔNG lặp lại functional requirement — chỉ ghi non-functional.

**Ví dụ tốt** (ECareHome):
```
- Performance: Màn hình danh sách thợ load ≤ 2s khi 500 khách đặt đồng thời.
- Security: Dữ liệu thẻ không bao giờ lưu trên server ECareHome; xử lý qua Payment Gateway đạt PCI-DSS.
- Reliability: Nếu eSMS lỗi ở bước gửi SMS, booking KHÔNG bị rollback — retry async, fallback push notification.
- Compliance: Xuất hóa đơn VAT cho mọi giao dịch ≥ 200.000 VND theo luật thuế Việt Nam.
```

---

## 15. Assumptions

**Mục đích**: Điều giả định khi phân tích nhưng chưa verify.

**Khác Precondition**:
- Precondition: PHẢI ĐÚNG, system verify được
- Assumption: TIN LÀ ĐÚNG, không bắt buộc verify

**Ví dụ tốt** (ECareHome):
```
1. SLA của Payment Gateway ≥ 99,5% uptime trong giờ hành chính.
2. Dữ liệu khu vực phục vụ của thợ được ops cập nhật đúng trước khi mở dịch vụ.
3. Số điện thoại khách đã verify — SMS xác nhận không bị bounce.
4. Thuật toán matching trả kết quả < 3s trong điều kiện tải bình thường.
```

---

## 16. Notes and Issues

**Mục đích**: Câu hỏi mở, TBD, việc cần follow-up.

**Format**: `[TBD-N] | Owner | Due Date | Resolution`

**Ví dụ tốt** (ECareHome):
```
- [TBD-1] Khách có được đặt thợ hộ cho người thân (proxy booking) không? | Owner: Product Team | Due: 2026-06-01 | Resolution: TBD — cân nhắc Phase 2.
- [TBD-2] Chính sách hoàn tiền nếu khách hủy trong vòng bao lâu sau khi matched? | Owner: BA | Due: 2026-05-25 | Resolution: tham chiếu 2.11 Cancellation Policy.
- [NOTE] Template SMS xác nhận phải khớp brand guideline hiện hành — phối hợp Marketing.
```

---
*Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition đổi ví dụ sang home-service; giữ nguyên attribution.*
