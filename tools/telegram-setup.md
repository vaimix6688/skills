# Telegram Bot — Điều khiển Claude Code từ điện thoại

## Cách 1: Official Plugin (Khuyên dùng)

Claude Code có plugin Telegram chính thức. Setup trong 5 phút.

### Yêu cầu
- Claude Code CLI đã cài
- Bun runtime (`npm install -g bun` hoặc https://bun.sh)
- Tài khoản Telegram

### Setup

```bash
# 1. Cài plugin Telegram
claude --channels plugin:telegram@claude-plugins-official

# 2. Tạo bot trên Telegram
#    → Mở Telegram → tìm @BotFather → gõ /newbot
#    → Đặt tên bot → nhận BOT_TOKEN
#    → Copy token

# 3. Chạy Claude Code với channel Telegram
claude --channel telegram

# 4. Pair account
#    → Nhắn tin cho bot trên Telegram
#    → Nhận mã xác thực 6 ký tự
#    → Nhập mã vào Claude Code terminal
```

### Sử dụng

Sau khi pair xong, nhắn tin cho bot trên Telegram:
- Gửi text → Claude Code thực thi
- Gửi file (PDF, ảnh) → Claude đọc và xử lý
- Gửi voice message → Claude nhận và phản hồi
- Claude trả lời → hiển thị trên Telegram

### Hạn chế
- Cần giữ Claude Code session chạy trên máy
- Telegram KHÔNG mã hóa end-to-end cho bot → **KHÔNG gửi API keys, passwords, secrets**
- Cần Bun runtime

---

## Cách 2: Claude Agent SDK + Custom Bot (Linh hoạt)

Tự build bot Python với full control.

### Setup

```bash
pip install python-telegram-bot anthropic claude-agent-sdk
```

### Code mẫu

```python
#!/usr/bin/env python3
"""Telegram bot điều khiển Claude Code."""

import os
import asyncio
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters
from claude_agent_sdk import query

TELEGRAM_TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
ALLOWED_USERS = [int(x) for x in os.environ.get("ALLOWED_TELEGRAM_IDS", "").split(",") if x]

async def handle_message(update: Update, context):
    user_id = update.effective_user.id
    if ALLOWED_USERS and user_id not in ALLOWED_USERS:
        await update.message.reply_text("Unauthorized.")
        return

    message = update.message.text
    await update.message.reply_text("Processing...")

    try:
        result = ""
        async for event in query(prompt=message):
            if hasattr(event, "text"):
                result += event.text

        # Split if > 4096 chars (Telegram limit)
        for i in range(0, len(result), 4096):
            await update.message.reply_text(result[i:i+4096])
    except Exception as e:
        await update.message.reply_text(f"Error: {str(e)[:500]}")

async def start(update: Update, context):
    await update.message.reply_text(
        "Claude Code Bot\n\n"
        "Commands:\n"
        "/code <task> — Execute coding task\n"
        "/search <query> — Search codebase\n"
        "/git <command> — Git operations\n"
        "Or just send a message."
    )

def main():
    app = Application.builder().token(TELEGRAM_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    app.run_polling()

if __name__ == "__main__":
    main()
```

### Environment Variables

```bash
export TELEGRAM_BOT_TOKEN="your-bot-token-from-botfather"
export ANTHROPIC_API_KEY="your-anthropic-api-key"
export ALLOWED_TELEGRAM_IDS="123456789,987654321"  # Optional: restrict access
```

### Chạy

```bash
python bot.py
```

---

## Cách 3: n8n (No-code)

Dùng n8n self-hosted cho workflow automation:

1. Cài n8n: `npm install -g n8n && n8n start`
2. Tạo workflow: Telegram Trigger → Claude API Node → Telegram Send
3. Config Telegram bot token + Anthropic API key trong n8n

---

## So sánh

| | Official Plugin | Custom Bot | n8n |
|---|---|---|---|
| Setup time | 5 phút | 1-2 giờ | 30 phút |
| Flexibility | Thấp | Cao | Trung bình |
| Custom commands | Không | Có | Có |
| Multi-user | Không | Có | Có |
| Cần code | Không | Có | Không |
| Session management | Tự động | Tự build | Workflow-based |
