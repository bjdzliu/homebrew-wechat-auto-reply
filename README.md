# Homebrew OpenClaw Tap

OpenClaw skills collection for Homebrew installation.

## 🚀 Quick Install

```bash
brew install bjdzliu/openclaw/wechat-auto-reply
```

Or use the two-step method:

```bash
# Step 1: Add the tap
brew tap bjdzliu/openclaw

# Step 2: Install (shorter command)
brew install wechat-auto-reply

# Future updates
brew upgrade wechat-auto-reply
```

## 📚 Available Skills

### WeChat Auto Reply

WeChat Auto Reply with AI-powered confidence scoring - semi-automatic message reply with intelligent confidence assessment.

## 📖 Usage

After installation, you can use the `wechat-auto-reply` command:

```bash
# Semi-auto reply mode (OCR + AI with confidence scoring)
# - Confidence > 85%: Auto-send
# - Confidence ≤ 85%: Confirm dialog
wechat-auto-reply "联系人名称"

# Direct message mode
wechat-auto-reply "联系人名称" "消息内容"
```

### Examples

```bash
# Semi-auto reply
wechat-auto-reply "小李"      # High confidence → auto-send
wechat-auto-reply "小王"      # Low confidence → confirm dialog

# Direct message
wechat-auto-reply "小李" "什么时候下班"
wechat-auto-reply "小王" "今天行情怎么样"
```

## 🔧 Requirements

- **macOS 10.15+** (for Vision Framework OCR)
- **WeChat** app installed
- **macOS Automation permissions** for WeChat
- **Dependencies** (auto-installed):
  - `cliclick` - Mouse click automation
  - `python@3` - Python runtime
  - `pyobjc` - Python Objective-C bridge

## 📂 File Locations

- **Skill directory**: `$(brew --prefix)/share/openclaw/skills/wechat-auto-reply`
- **User link**: `~/.openclaw/workspace/skills/wechat-auto-reply`
- **Command**: `$(brew --prefix)/bin/wechat-auto-reply`

## ⚙️ Configuration

Default input box coordinates: `{1000, 832}`

To adjust for your screen:

```bash
# Edit the AppleScript
vim $(brew --prefix)/share/openclaw/skills/wechat-auto-reply/wechat-dm.applescript

# Find and modify:
cliclick c:1000,832  # Change to your coordinates
```

## 🤖 How It Works

1. **Activate WeChat** - Brings WeChat to foreground
2. **Search Contact** - Uses Cmd+F to find the contact
3. **OCR Screenshot** - Captures and reads chat content (macOS Vision Framework)
4. **AI Reply** - Generates reply with confidence score
5. **Smart Send** - Auto-send (>85%) or confirm (<85%)
6. **Send Message** - Pastes and sends the message

## 📊 Confidence Scoring

| Scenario | Keywords | Reply | Confidence |
|----------|----------|-------|------------|
| Online inquiry | "在吗", "忙吗" | "在的，什么事？" | 95% |
| Thanks | "谢谢", "感谢" | "不客气" | 95% |
| Confirmation | "收到"+"好的" | "好的" | 90% |
| Investment | "投资", "抄底", "行情" | "不急，等稳一点" | 85% |
| Question | "?", "？" | "我看看，稍等" | 75% |
| General OK | "好", "OK" | "好的" | 80% |
| Time-related | "明天", "几点" | "我确认一下，回头告诉你" | 70% |
| Default | Others | "收到" | 60% |

## 🔄 Update

```bash
# If you used one-line install
brew upgrade bjdzliu/openclaw/wechat-auto-reply

# If you added the tap first
brew upgrade wechat-auto-reply
```

## 🗑️ Uninstall

```bash
brew uninstall wechat-auto-reply

# Optional: Remove the tap
brew untap bjdzliu/openclaw
```

## 📝 Documentation

For more details, see the [SKILL.md](SKILL.md) file.

## 📄 License

MIT

## 🔗 Links

- **Repository**: https://github.com/bjdzliu/homebrew-openclaw
- **Issues**: https://github.com/bjdzliu/homebrew-openclaw/issues
