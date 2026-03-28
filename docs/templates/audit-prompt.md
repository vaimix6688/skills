# Audit Prompt Template

Use this template every time you need to audit a prompt before sending it to an AI executor.

---

## Usage

```
Hãy audit lại prompt sau trước khi tôi gửi thực thi.
Áp dụng đầy đủ Audit Checklist bên dưới.

[PASTE PROMPT VÀO ĐÂY]
```

---

## Audit Checklist

### 1. Goal & Scope
- [ ] Prompt có 1 mục tiêu rõ ràng, không gộp nhiều mục tiêu?
- [ ] Scope có bị quá rộng (sẽ gây drift)?
- [ ] Có chỉ rõ: làm gì, KHÔNG làm gì?
- [ ] Output mong đợi được mô tả cụ thể chưa?

### 2. Path & Config Verification
> KHÔNG assume path — PHẢI verify thực tế trước khi sửa.
- [ ] Mọi file path có được verify tồn tại trước khi dùng bằng `find`?
- [ ] Đã nhận diện đúng môi trường (dev vs prod vs test)?
- [ ] Container names đúng chưa?

### 3. Destructive Operations Risk
> Mọi thao tác write/delete/restart phải có backup và rollback
- [ ] Có backup rõ ràng trước khi sửa file?
- [ ] Lệnh restart có giữ nguyên environment variable an toàn không (`up -d --force-recreate`)?
- [ ] Nếu script/code fail thì có step by step rollback không?

### 4. Protocol & Safety
- **PACE Protocol (Pause, Anchor, Confirm, Execute)**: Prompt có dừng ở những điểm nguy hiểm để người dùng xác nhận không?
- Cấu trúc "If X then do Y, else do Z" có rõ ràng trong các bước không?

### 5. Invariants / Rules
- [ ] Prompt có rủi ro vi phạm các Invariants của hệ thống không? (Ví dụ: force git push, thay đổi contract API mà không báo trước...)

---

## Verdict Format

```markdown
## Audit Result — [Tên Prompt]

### ✅ OK
- [Điểm tốt]

### ⚠️ Issues Found
- [Vấn đề 1] — [Mức độ: HIGH/MED/LOW] — [Cách Fix]

### 🔴 Blocking Issues (phải fix trước khi chạy)
- [Issue blocking]

### Expected Output khi thành công
[Mô tả]

### Prompt đã fix
[Paste version đã sửa]
```
