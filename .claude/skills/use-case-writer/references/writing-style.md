# Writing Style Guide

Tổng hợp từ Alistair Cockburn ("Writing Effective Use Cases") + IIBA BABOK + thực hành BA Zone, đổi ví dụ sang domain home-service.

> Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition.

## Nguyên tắc tối thượng: READABILITY FIRST

Câu nổi tiếng của Cockburn: "Write clearly. Readability is the most important thing."

Một UC tốt là UC mà:
- Stakeholder không kỹ thuật vẫn nắm được
- Dev có đủ thông tin để code
- QA có đủ thông tin để viết test case
- Một BA mới có thể cập nhật khi mọi thứ thay đổi

---

## Rule 1: Active Voice + Thì hiện tại

### Active voice — chủ ngữ thực hiện hành động
- ✅ "Khách hàng bấm nút **Đặt thợ**"
- ❌ "Nút **Đặt thợ** được bấm bởi khách hàng"
- ✅ "System lưu bản ghi booking vào database"
- ❌ "Bản ghi booking được lưu vào database bởi system"

### Thì hiện tại
- ✅ "System hiển thị màn hình xác nhận booking"
- ❌ "System sẽ hiển thị màn hình xác nhận booking"
- ❌ "System đã hiển thị màn hình xác nhận booking"

---

## Rule 2: Chủ ngữ rõ — Subject + Verb + Object

Mỗi bước phải bắt đầu bằng **chủ ngữ cụ thể**: tên actor hoặc "System".

- ✅ "Khách hàng chọn khung giờ mong muốn"
- ❌ "Chọn khung giờ mong muốn" (không có chủ ngữ)
- ✅ "System kiểm tra hạn mức rút tiền còn lại của thợ"
- ❌ "Kiểm tra hạn mức còn lại" (passive, không rõ ai làm)

---

## Rule 3: Một bước = một hành động

Mỗi bước trong Normal Course làm đúng một việc. Thấy "và" nối hai loại hành động khác nhau → tách bước.

- ✅ "3. Khách hàng nhập địa chỉ, khung giờ và mô tả sự cố." (cùng loại — điền form)
- ❌ "3. Khách hàng nhập mô tả sự cố và bấm Xác nhận." → tách 2 bước:
  - "3. Khách hàng nhập mô tả sự cố (tối đa 500 ký tự)."
  - "4. Khách hàng bấm nút **Tìm thợ**."

**Vì sao**: "Bấm Tìm thợ" thường kích hoạt system validate → cần là bước riêng để Exception "không tìm được thợ" gắn vào được.

---

## Rule 4: Tránh động từ mơ hồ

| ❌ Mơ hồ | ✅ Cụ thể |
|---------|----------|
| Quản lý | Tạo / Cập nhật / Lưu trữ / Xem |
| Xử lý | Validate / Process / Từ chối / Escalate |
| Làm | Submit / Duyệt / Gán / Sinh |
| Thực hiện | Xuất / Dựng / Render / Tính toán |
| Lấy | Truy xuất / Fetch / Query / Tải về |
| Dùng | Áp dụng / Invoke / Execute / Redeem |

**Áp dụng cho cả UC Name lẫn nội dung bước.**

---

## Rule 5: Tránh implementation detail

UC mô tả **WHAT** (hành động), không mô tả **HOW** (cơ chế). Để HOW cho design phase.

- ❌ "System gọi POST /api/v1/bookings với header Authorization Bearer {token}, body {service_id, customer_id}…"
- ✅ "System tạo bản ghi booking trong hệ thống đặt lịch"
- ❌ "System insert một row vào bảng bookings với các field: booking_id, service_id, customer_id, created_at…"
- ✅ "System lưu booking vào database"
- ❌ "System render component <BookingSuccessModal> với prop serviceTitle='Sửa điều hòa'…"
- ✅ "System hiển thị màn hình Đặt thợ thành công kèm tên dịch vụ và thông tin thợ"

**Ngoại lệ**: Nếu UC là integration spec, có thể chi tiết hơn — nhưng vẫn dùng ngôn ngữ nghiệp vụ.

---

## Rule 6: Đánh số nhất quán

- **Normal Course**: Danh sách đánh số bắt đầu từ 1.
- **Alternative Course**: Đánh số con theo bước gốc + chữ cái: AC tại bước 5 → 5a, 5b, 5c. Sau AC ghi "tiếp tục từ bước N của Normal Course".
- **Exception ID**: Format `UC-XX.EX.N` (đánh số độc lập, không gắn với bước).
- **Pre/Postconditions**: Danh sách đánh số từ 1.

---

## Rule 7: Đặt tên UI element

Khi nhắc UI element trong một bước, dùng **in đậm** và đúng nhãn hiển thị trên màn hình:

- ✅ "Khách hàng bấm nút **Đặt thợ**"
- ✅ "System hiển thị màn hình **Tóm tắt đơn**"
- ✅ "Khách hàng chọn **MoMo** trong danh sách phương thức thanh toán"

Lý do: dễ truy ngược về wireframe/mockup khi handoff design.

---

## Rule 8: Tránh từ mơ hồ

| ❌ Mơ hồ | ✅ Cụ thể |
|---------|----------|
| Trong một số trường hợp | Khi điều kiện X xảy ra |
| Có thể | Khi [điều kiện], system [hành động] |
| Thỉnh thoảng | X% số lần / Y lần mỗi Z |
| Nếu cần | Khi [trigger cụ thể] |
| Hợp lệ | Thỏa tiêu chí: … (liệt kê ra) |
| Phù hợp | Theo chính sách [tham chiếu] |
| Nhanh | Trong vòng X giây |
| Người dùng | Khách hàng / Thợ / CS Agent / Admin |

---

## Rule 9: Không nhúng business rule vào bước

Một bước Normal Course mô tả **flow**. Business rule (rule validate, hạn mức, logic nghiệp vụ) nên:
- Tham chiếu Special Requirements theo rule ID
- Hoặc nằm trong tài liệu Business Rule riêng (`BR-XX`)

- ❌ "5. System validate: mô tả ≤ 500 ký tự, khách phải có ≥ 1 booking chưa quá hạn, thợ phải còn rảnh trong 2 giờ tới…"
- ✅ "5. System validate yêu cầu đặt thợ theo business rule BR-BOOK-001."
  - (Rồi liệt kê BR-BOOK-001 ở Special Requirements hoặc tài liệu BR — trong ECareHome là `02-requirements/2.4_Business_Rules.md`)

---

## Rule 10: Hướng dẫn độ dài

- **UC Name**: 3-7 từ
- **Description**: 2-4 câu, ~50-100 từ
- **Normal Course**: 5-15 bước (thường 7-10)
- **Mỗi bước**: 1 câu, tối đa 2 câu, < 30 từ
- **Alternative Courses**: 1-5 AC mỗi UC (nhiều hơn → cân nhắc tách UC)
- **Exceptions**: 3-7 cho một UC điển hình
- **Tổng UC**: 2-5 trang A4

Nếu vượt hướng dẫn: UC quá dài → tách qua Includes; quá nhiều AC/EX → xem lại scope, UC có thể đang ôm quá nhiều.

---

## Rule 11: Nhất quán toàn dự án

Nhất quán xuyên suốt bộ tài liệu:
- Tên actor (đừng lúc "Khách hàng" lúc "Người dùng" lúc "User")
- Tên component system (chọn một cách gọi)
- Tên màn hình/menu (phải khớp wireframe hoặc product spec)
- Naming convention cho UC ID

Mẹo: duy trì một **Glossary** ở đầu bộ tài liệu. Trong ECareHome, đối chiếu actor với `02-requirements/2.3_Use_Case_Diagram.md`.

---

## Rule 12: Internationalization

Nếu nền tảng có yêu cầu i18n:
- Tên màn hình/nút trong UC có thể dùng key thay vì text cứng
- VD thay "bấm nút **Đặt thợ**" bằng "bấm nút {btn.book_worker}"
- Với hầu hết UC spec, nhãn text thường (Việt) là đủ.

---

## Anti-pattern — 10 lỗi hay gặp nhất

### 1. UC là UI spec từng pixel
❌ "System hiển thị modal header màu #14B8A6 'Đặt thợ thành công', icon dấu tích, ảnh thợ bên trái…"
→ Đó là wireframe annotation. UC viết: "System hiển thị màn hình Đặt thợ thành công kèm tên thợ và nút Xem chi tiết."

### 2. Trộn actor và system trong một bước
❌ "3. Khách hàng chọn thợ và system validate hạn mức."
→ Tách thành 2 bước.

### 3. Bỏ system response
❌ "1. Khách bấm Đặt thợ. 2. Khách nhập thông tin. 3. Khách xác nhận."
→ Thiếu system response giữa các bước. UC phải thể hiện DIALOG actor ↔ system.

### 4. Nhúng logic điều kiện
❌ "5. Nếu khách là thành viên VIP, system cho chọn thợ VIP; không thì chỉ hiện thợ thường."
→ Tách thành Normal Course (case mặc định) + AC (nhánh VIP) hoặc Exception.

### 5. Trigger mơ hồ
❌ "Khi khách hàng muốn lấy hóa đơn, họ…"
→ Cụ thể: "Khi khách hàng vào tab **Hóa đơn** sau khi hoàn tất dịch vụ…"

### 6. Postcondition là action thay vì state
❌ "System gửi hóa đơn cho khách" (action)
→ "Hóa đơn điện tử đã được gửi tới email đã đăng ký của khách hàng" (state) ← verify được

### 7. UC có 2 primary actor
❌ Primary: Khách hàng + CS Agent (cả hai cùng khởi tạo UC)
→ Tách 2 UC: một cho khách tự đặt, một cho CS đặt hộ.

### 8. "System xử lý" mơ hồ
❌ "5. System xử lý booking."
→ Cụ thể: "System tạo bản ghi booking với status='matched' và gán worker_id."

### 9. Lặp lại Description trong Normal Course
Nếu Description đã nêu cả flow, đừng copy vào Normal Course. Description là tóm tắt 2-3 câu; Normal Course là từng bước chi tiết.

### 10. Quên failure mode
UC chỉ có Normal Course + 1 Exception "lỗi" chung chung → không đủ.
Với UC home-service, luôn phủ: lỗi thanh toán, hết thợ trong khu vực, service ngoài timeout (Payment Gateway/eSMS), concurrency conflict (thợ nhận đơn khác cùng lúc), và permission/role mismatch.

---
*Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition.*
