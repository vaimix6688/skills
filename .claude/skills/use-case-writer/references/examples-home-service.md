# Examples — 2 Use Case home-service hoàn chỉnh

Dùng làm tham chiếu khi viết UC. Cả hai ví dụ đã qua đủ checklist 20 điểm. Domain: ECareHome (đặt thợ dịch vụ tại nhà).

> Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition đổi ví dụ sang home-service.

---

## Ví dụ 1: UC-BOOK-01 — Đặt thợ sửa chữa thiết bị

| **Use Case ID:** | UC-BOOK-01 |
| ---: | :--- |
| **Use Case Name:** | Đặt thợ sửa chữa thiết bị |
| **Created By:** | BA Team | **Last Updated By:** | BA Team |
| **Date Created:** | 2026-05-17 | **Date Last Updated:** | 2026-05-17 |

| **Actor:** | **Primary:** Khách hàng (đã đăng ký, verify OTP). **Secondary:** Worker (thợ), Payment Gateway (MoMo/VNPay), eSMS (thông báo SMS). |
| ---: | :--- |
| **Description:** | Khi một thiết bị trong nhà hỏng và khách hàng cần thợ tới sửa, khách mở app ECareHome, mô tả sự cố và đặt thợ phù hợp. UC kết thúc khi một booking được tạo với status='matched', thợ được gán đã nhận đơn, và khách hàng nhận thông báo xác nhận. Theo mô hình post-pay, khách KHÔNG trả tiền ở bước này — thanh toán diễn ra sau khi hoàn tất dịch vụ. |
| **Preconditions:** | 1. Khách hàng đã đăng nhập app bằng số điện thoại đã verify OTP.<br>2. Loại dịch vụ được chọn đang ở trạng thái 'active' và có thợ phục vụ khu vực của khách.<br>3. Khách hàng không có booking nào đang treo chưa thanh toán quá hạn.<br>4. Dịch vụ matching đang sẵn sàng. |
| **Postconditions:** | 1. Bản ghi booking được tạo trong bảng bookings với status='matched', kèm worker_id và timestamp.<br>2. Thợ được gán nhận push notification và xem được chi tiết đơn.<br>3. Khách hàng thấy màn hình "Đã tìm được thợ" kèm thông tin thợ, đánh giá và ETA.<br>4. Sự kiện booking.matched được ghi vào audit log (hash chain, I-04).<br>5. SMS xác nhận được gửi tới khách hàng trong vòng 60 giây. |
| **Priority:** | High — Feature cốt lõi, nằm trên happy path E2E của ECareHome; chặn go-live pilot Hà Nội. |
| **Frequency of Use:** | Ước tính ~800 booking/ngày toàn nền tảng; peak ~120/giờ vào buổi tối và cuối tuần. |
| **Normal Course of Events:** | 1. Khách hàng mở app và chọn loại dịch vụ cần (vd "Sửa điều hòa").<br>2. System hiển thị màn hình **Mô tả sự cố**: ô nhập text, nút **Tải ảnh**, nút **Ghi âm**.<br>3. Khách hàng nhập mô tả sự cố (tối đa 500 ký tự) và bấm **Tìm thợ**.<br>4. System hiển thị danh sách thợ gần nhất kèm giá ước tính, đánh giá trung bình và khoảng cách.<br>5. Khách hàng chọn một thợ và bấm **Đặt thợ**.<br>6. System tạo booking với status='matching' và gửi đề nghị tới thợ được chọn.<br>7. Thợ nhận đề nghị và bấm **Nhận đơn**; system cập nhật booking sang status='matched'.<br>8. System hiển thị màn hình **Đã tìm được thợ** kèm thông tin thợ, đánh giá và ETA.<br>9. System gọi UC-NOTI-01 để gửi SMS xác nhận tới khách hàng. |
| **Alternative Courses:** | **UC-BOOK-01.AC.1: Để hệ thống tự ghép thợ**<br>Tại bước 5 của Normal Course, nếu khách hàng bấm **Để ECareHome chọn thợ giúp tôi**:<br>5a. System ẩn danh sách thợ và hiển thị "Đang tìm thợ phù hợp nhất…".<br>5b. System chạy thuật toán matching theo điểm số (khoảng cách, đánh giá, tải hiện tại).<br>5c. System chọn thợ điểm cao nhất → tiếp tục từ bước 6 của Normal Course.<br><br>**UC-BOOK-01.AC.2: Đặt lại thợ quen từ lịch sử**<br>Tại bước 1 của Normal Course, nếu khách hàng chọn **Đặt lại thợ cũ** từ màn hình lịch sử đơn:<br>1a. System hiển thị thông tin booking trước đó và thợ đã làm.<br>1b. Khách hàng xác nhận → system điền sẵn loại dịch vụ và thợ → tiếp tục từ bước 6 của Normal Course. |
| **Exceptions:** | **UC-BOOK-01.EX.1: Thợ được chọn từ chối đề nghị**<br>Trigger: Tại bước 7, thợ được chọn bấm **Từ chối** hoặc không phản hồi trong thời gian chờ.<br>Response: System chuyển đề nghị sang thợ phù hợp tiếp theo (tối đa 3 vòng) và hiển thị "Đang tìm thợ khác…".<br>Final state: Nếu một thợ nhận đơn, tiếp tục Normal Course từ bước 8. Nếu hết 3 vòng, kích hoạt EX.2.<br><br>**UC-BOOK-01.EX.2: Không tìm được thợ trong khu vực**<br>Trigger: Tại bước 6, sau 3 vòng đề nghị không thợ nào nhận đơn.<br>Response: System hiển thị "Hiện chưa có thợ rảnh ở khu vực của bạn. Để lại nhu cầu, tổng đài gọi lại trong 15 phút?" kèm nút **Báo nhu cầu**.<br>Final state: Không tạo booking 'matched'. Nếu khách bấm **Báo nhu cầu**, system tạo một sales lead ưu tiên (SLA gọi lại 15 phút). Sự kiện no_worker_found được ghi log.<br><br>**UC-BOOK-01.EX.3: Mất kết nối mạng trong lúc đặt**<br>Trigger: Tại bước 5 hoặc 6, thiết bị khách mất kết nối khi đang gửi yêu cầu.<br>Response: App hiển thị "Mất kết nối. Yêu cầu của bạn chưa được gửi." kèm nút **Thử lại**.<br>Final state: Không tạo booking. Yêu cầu đặt thợ được giữ tạm ở local; khi có mạng trở lại app cho phép gửi lại mà không nhập lại từ đầu.<br><br>**UC-BOOK-01.EX.4: SMS xác nhận không gửi được**<br>Trigger: Tại bước 9, eSMS không phản hồi trong 10 giây.<br>Response: Booking vẫn được giữ ở status='matched'. System chuyển sang gửi push notification thay thế.<br>Final state: Booking 'matched' KHÔNG bị rollback. Một retry job thử gửi lại SMS mỗi 2 phút trong tối đa 30 phút; nếu vẫn lỗi thì ghi cảnh báo cho ops, nhưng UC vẫn coi là thành công. |
| **Includes:** | UC-NOTI-01: Gửi thông báo đặt thợ (gọi ở bước 9 của Normal Course) |
| **Special Requirements:** | **Performance**: Màn hình danh sách thợ load ≤ 2s khi 500 khách đặt đồng thời; màn hình "Đã tìm được thợ" load ≤ 1s.<br>**Security**: Vị trí và số điện thoại khách chỉ hiển thị cho thợ sau khi booking đạt status='matched' (RBAC, I-08). Mô tả sự cố không chứa dữ liệu thanh toán.<br>**Reliability**: Nếu eSMS lỗi ở bước 9, booking KHÔNG được rollback — retry async, fallback push notification.<br>**Usability**: Flow đặt thợ hoàn tất trong ≤ 3 thao tác trên mobile (sau khi chọn loại dịch vụ).<br>**Audit**: Sự kiện booking.matched ghi vào audit log hash-chain (I-04), không cho sửa/xóa. |
| **Assumptions:** | 1. Thuật toán matching trả kết quả < 3s trong điều kiện tải bình thường.<br>2. Dữ liệu khu vực phục vụ của thợ được ops cập nhật đúng trước khi mở dịch vụ.<br>3. Số điện thoại khách đã verify — SMS xác nhận không bị bounce.<br>4. Thợ có app worker đang chạy và nhận được push notification đề nghị đơn. |
| **Notes and Issues:** | [TBD-1] Khách có được đặt thợ hộ cho người thân (proxy booking) không? \| Owner: Product Team \| Due: 2026-06-01 \| Resolution: TBD — cân nhắc Phase 2.<br>[TBD-2] Thời gian chờ thợ phản hồi mỗi vòng đề nghị là bao lâu? \| Owner: BA \| Due: 2026-05-25 \| Resolution: TBD — cần xác nhận với ops.<br>[NOTE] Mô hình post-pay: thanh toán nằm ở UC riêng sau khi hoàn tất dịch vụ — tham chiếu spec 4.51 v2. |

---

## Ví dụ 2: UC-DISPUTE-03 — Duyệt yêu cầu hoàn tiền tranh chấp

| **Use Case ID:** | UC-DISPUTE-03 |
| ---: | :--- |
| **Use Case Name:** | Duyệt yêu cầu hoàn tiền tranh chấp |
| **Created By:** | BA Team | **Last Updated By:** | BA Team |
| **Date Created:** | 2026-05-17 | **Date Last Updated:** | 2026-05-17 |

| **Actor:** | **Primary:** CS Manager (có quyền duyệt tranh chấp, RBAC). **Secondary:** Worker Care, Payment Gateway, Audit Log, eSMS. |
| ---: | :--- |
| **Description:** | Khi một yêu cầu tranh chấp do CS Agent escalate lên cần quyết định hoàn tiền, CS Manager mở hàng đợi tranh chấp, xem hồ sơ và bằng chứng, rồi ra quyết định: Duyệt hoàn tiền, Từ chối, hoặc Hoàn một phần. UC kết thúc khi tranh chấp có trạng thái cuối, quyết định được ghi audit, và cả khách lẫn thợ được thông báo. |
| **Preconditions:** | 1. CS Manager đã đăng nhập admin web với tài khoản có quyền 'MANAGE_DISPUTES' (RBAC, I-08).<br>2. Có ít nhất một tranh chấp ở trạng thái 'escalated_to_manager' trong hàng đợi.<br>3. Booking liên quan đã hoàn tất và đã có giao dịch thanh toán post-pay được ghi nhận.<br>4. Bằng chứng tranh chấp (ảnh/chat/ghi chú) đã được CS Agent đính kèm. |
| **Postconditions:** | 1. Tranh chấp có trạng thái cuối: 'refund_approved' / 'refund_rejected' / 'partial_refund'.<br>2. Một bản ghi quyết định được lưu kèm: manager_id, timestamp, quyết định, lý do, số tiền hoàn.<br>3. Nếu duyệt hoàn: lệnh hoàn tiền được gửi tới Payment Gateway qua saga có outbox + idempotency.<br>4. Quyết định được ghi vào audit log hash-chain (I-04), không cho sửa/xóa.<br>5. Thông báo kết quả được gửi tới khách hàng và thợ trong vòng 2 phút. |
| **Priority:** | High — Ảnh hưởng trực tiếp niềm tin khách hàng và dòng tiền; là gate tuân thủ. |
| **Frequency of Use:** | ~15 tranh chấp escalate/ngày toàn nền tảng; peak đầu tuần sau cuối tuần cao điểm dịch vụ. |
| **Normal Course of Events:** | 1. CS Manager mở tab **Hàng đợi tranh chấp** trên admin web.<br>2. System hiển thị danh sách tranh chấp 'escalated_to_manager', sắp xếp theo thời gian escalate (cũ nhất trước), kèm mã booking, loại tranh chấp và số tiền liên quan.<br>3. CS Manager bấm vào một tranh chấp để mở màn hình **Chi tiết tranh chấp**.<br>4. System hiển thị đầy đủ: hồ sơ khách, hồ sơ thợ, lịch sử booking, bằng chứng đính kèm và ghi chú của CS Agent.<br>5. CS Manager xem xét và bấm một trong ba nút: **Duyệt hoàn tiền** / **Từ chối** / **Hoàn một phần**.<br>6. System hiển thị popup xác nhận yêu cầu nhập lý do quyết định (bắt buộc) và số tiền hoàn (nếu hoàn một phần).<br>7. CS Manager nhập lý do, số tiền và bấm **Xác nhận quyết định**.<br>8. System lưu bản ghi quyết định, cập nhật trạng thái tranh chấp và khởi tạo lệnh hoàn tiền (nếu có) qua saga có outbox.<br>9. System ghi sự kiện quyết định vào audit log hash-chain.<br>10. System gọi UC-NOTI-02 để gửi thông báo kết quả tới khách hàng và thợ.<br>11. System hiển thị toast "Tranh chấp #[ID] đã xử lý" và đưa CS Manager về hàng đợi. |
| **Alternative Courses:** | **UC-DISPUTE-03.AC.1: Trả hồ sơ về Worker Care để điều tra thêm**<br>Tại bước 5 của Normal Course, nếu bằng chứng chưa đủ để quyết định:<br>5a. CS Manager bấm **Chuyển Worker Care điều tra**.<br>5b. System hiển thị ô nhập câu hỏi điều tra gửi kèm.<br>5c. CS Manager nhập câu hỏi và bấm **Chuyển**.<br>5d. System cập nhật trạng thái tranh chấp sang 'under_investigation' và giao cho Worker Care.<br>5e. UC kết thúc ở đây cho CS Manager. Quyết định cuối sẽ thực hiện trong một phiên UC riêng sau khi Worker Care phản hồi. |
| **Exceptions:** | **UC-DISPUTE-03.EX.1: Tranh chấp đã bị xử lý — concurrency conflict**<br>Trigger: Tại bước 8, system phát hiện tranh chấp đã đổi trạng thái kể từ khi CS Manager mở màn hình chi tiết (vd một manager khác xử lý song song).<br>Response: System hiển thị "Tranh chấp này đã được xử lý hoặc đang được người khác xử lý. Vui lòng làm mới hàng đợi."<br>Final state: Quyết định hiện tại bị hủy bỏ. Tranh chấp giữ trạng thái đã cập nhật. Sự kiện concurrency được ghi audit.<br><br>**UC-DISPUTE-03.EX.2: Lệnh hoàn tiền thất bại ở Payment Gateway**<br>Trigger: Tại bước 8, Payment Gateway trả lỗi hoặc timeout khi nhận lệnh hoàn tiền.<br>Response: System vẫn lưu quyết định 'refund_approved' nhưng đánh dấu lệnh hoàn ở trạng thái 'refund_pending' và hiển thị cảnh báo cho CS Manager.<br>Final state: Quyết định KHÔNG bị rollback. Saga retry lệnh hoàn theo backoff; outbox + idempotency đảm bảo không hoàn trùng. Nếu retry cạn, tạo ticket cho Finance Ops.<br><br>**UC-DISPUTE-03.EX.3: Lý do quyết định để trống**<br>Trigger: Tại bước 7, CS Manager bấm **Xác nhận quyết định** mà chưa nhập lý do.<br>Response: System hiển thị lỗi inline "Lý do quyết định là bắt buộc" và chặn submit.<br>Final state: Không lưu quyết định. CS Manager phải nhập lý do rồi mới submit được.<br><br>**UC-DISPUTE-03.EX.4: Số tiền hoàn một phần vượt số tiền giao dịch gốc**<br>Trigger: Tại bước 7, số tiền hoàn một phần CS Manager nhập lớn hơn số tiền giao dịch post-pay gốc.<br>Response: System hiển thị lỗi "Số tiền hoàn không được vượt số tiền giao dịch gốc ([số])" và chặn submit.<br>Final state: Không lưu quyết định. CS Manager phải nhập lại số tiền hợp lệ. |
| **Includes:** | UC-NOTI-02: Gửi thông báo kết quả tranh chấp (gọi ở bước 10 của Normal Course) |
| **Special Requirements:** | **Performance**: Hàng đợi tranh chấp load ≤ 2s với tối đa 50 tranh chấp; màn hình chi tiết load ≤ 1,5s.<br>**Security**: CS Manager chỉ xem và xử lý tranh chấp trong phạm vi quyền của mình (RBAC server-side, I-08). Quyết định hoàn tiền phải qua người có quyền 'MANAGE_DISPUTES' — không bao giờ chỉ gate ở frontend.<br>**Audit**: Mọi hành động của CS Manager (xem, duyệt, từ chối, chuyển điều tra) ghi audit với timestamp cấp giây vào hash-chain bất biến (I-04). Audit log lưu tối thiểu 5 năm.<br>**Reliability**: Lệnh hoàn tiền phải đi qua saga có outbox + idempotency — không bao giờ gọi gateway trần. Nếu gateway lỗi, quyết định không rollback.<br>**SLA**: 80% tranh chấp escalate phải có quyết định trong 24 giờ; quá 48 giờ chưa quyết định sẽ tự escalate lên cấp cao hơn. |
| **Assumptions:** | 1. CS Agent đã đính kèm đủ bằng chứng trước khi escalate.<br>2. Payment Gateway hỗ trợ API hoàn tiền tham chiếu giao dịch gốc.<br>3. Worker Care có quy trình điều tra riêng cho nhánh AC.1.<br>4. Quyền RBAC của CS Manager được cấp đúng trong hệ thống admin trước khi UC chạy. |
| **Notes and Issues:** | [TBD-1] Có cần cơ chế 4-eyes (hai người duyệt) cho khoản hoàn tiền lớn không, vd ≥ 2 triệu VND? \| Owner: Finance Lead \| Due: 2026-06-10 \| Resolution: TBD — tham chiếu chính sách 4-eyes của module thanh toán.<br>[NOTE] Trạng thái tranh chấp và chuyển tiếp tuân theo FSM của module dispute — đối chiếu spec module trước khi thêm trạng thái mới. |

---

## Bài học rút ra từ hai ví dụ

1. **UC-BOOK-01** minh họa một UC hướng khách hàng có tích hợp matching và xử lý fallback async khi service ngoài (eSMS) lỗi.

2. **UC-DISPUTE-03** minh họa một UC hướng admin (CS Manager) có concurrency conflict, RBAC server-side, audit hash-chain, và saga hoàn tiền.

3. **Cả hai UC đều có**:
   - 1 primary actor + secondary actor rõ ràng
   - Description phủ WHY + WHAT + OUTCOME
   - Preconditions verify được (không phải động cơ)
   - Postconditions diễn đạt dưới dạng thay đổi trạng thái system
   - Normal Course 9-11 bước xen kẽ Actor/System
   - 1-2 AC + 3-4 Exception phủ các failure mode chính
   - Special Requirements chỉ gồm non-functional
   - Notes có TBD kèm owner + due date

4. **Pattern đáng học từ hai ví dụ home-service này**:
   - Async fallback (EX.4 trong UC-BOOK-01): downstream service lỗi nhưng không rollback kết quả chính — retry async
   - Saga + outbox + idempotency cho mọi side-effect thanh toán (EX.2 trong UC-DISPUTE-03) — khớp Hard Constraint #4 của `CLAUDE.md`
   - RBAC enforce server-side, không chỉ frontend (Special Req trong UC-DISPUTE-03, invariant I-08)
   - Audit hash-chain bất biến cho mọi mutation tiền (invariant I-04)
   - Concurrency conflict handling cho hàng đợi đa actor (EX.1 trong UC-DISPUTE-03)
   - Tham chiếu Business Rule theo ID thay vì nhúng vào bước Normal Course

---
*Phương pháp gốc by **Phúc NT** · BA Zone · Digital School. Bản ECareHome edition đổi ví dụ sang home-service; giữ nguyên attribution.*
