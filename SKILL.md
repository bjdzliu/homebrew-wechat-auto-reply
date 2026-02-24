---
name: wechat-auto-reply
description: 半自动回复微信联系人消息（置信度>85%自动发送，否则确认），或主动发送指定内容。使用方式：./wechat-dm.sh "联系人名称" 或 ./wechat-dm.sh "联系人名称" "消息内容"
---

# WeChat Auto Reply Skill

半自动回复微信联系人消息（基于AI置信度智能判断），或主动发送指定内容。

## 功能描述

**两种模式：**
1. **半自动回复模式**：搜索联系人 → OCR 识别聊天内容 → AI 判断回复
   - 置信度 > 85% → 自动发送
   - 置信度 ≤ 85% → 弹窗确认（可修改回复内容）
2. **主动发送模式**：搜索联系人 → 直接发送指定消息

## 使用方式

```bash
# OCR 半自动回复（查看聊天记录，智能判断回复内容）
# 置信度 > 85% 自动发送，否则弹窗确认
./wechat-dm.sh "联系人名称"

# 主动发送（直接发送指定消息，不走 OCR）
./wechat-dm.sh "联系人名称" "消息内容"
```

**示例：**
```bash
# 半自动回复模式
./wechat-dm.sh "小李"      # 如果是"在吗"等高置信场景，自动发送
./wechat-dm.sh "小王"      # 如果是问题类，会弹窗让你确认或修改

# 主动发送模式
./wechat-dm.sh "小李" "什么时候下班"
./wechat-dm.sh "小王" "今天行情怎么样"
```

## 环境准备

### 依赖工具

| 工具 | 安装方式 | 用途 |
|------|----------|------|
| `cliclick` | `brew install cliclick` | 稳定的鼠标点击 |
| `screencapture` | macOS 内置 | 截图（可通过 `/usr/sbin/screencapture` 调用） |
| Vision Framework | macOS 10.15+ | OCR 文本识别 |

### Python 依赖

```bash
pip3 install pyobjc
```

## 实现原理

### 1. 激活微信

```applescript
tell application "WeChat" to activate
```

### 2. 确保前台

```applescript
tell app "System Events"
  tell process "WeChat"
    set frontmost to true
  end tell
end tell
```

### 3. 搜索联系人

- 使用 `Cmd+F` 打开搜索
- 通过剪贴板粘贴联系人名称
- 按回车进入聊天

### 4. OCR 截图

使用 macOS Vision Framework 识别聊天内容：

```python
from Vision import VNRecognizeTextRequest, VNImageRequestHandler

theRequest.setRecognitionLanguages(["zh-Hans", "en-US"])
theRequest.setUsesLanguageCorrection(True)
```

### 5. 智能回复判断（带置信度）

根据聊天内容自动生成回复，每个回复都附带置信度评分：

| 场景 | 关键词 | 回复内容 | 置信度 |
|------|--------|----------|--------|
| 询问在线 | "在吗"、"忙吗" | "在的，什么事？" | 95% |
| 感谢回复 | "谢谢"、"感谢" | "不客气" | 95% |
| 确认信息 | "收到"+"好的" | "好的" | 90% |
| 投资讨论 | "投资"、"抄底"、"行情" | "不急，等稳一点" | 85% |
| 问题咨询 | "?"、"？" | "我看看，稍等" | 75% |
| 一般确认 | "好"、"OK" | "好的" | 80% |
| 时间相关 | "明天"、"几点" | "我确认一下，回头告诉你" | 70% |
| 默认回复 | 其他 | "收到" | 60% |

**置信度规则：**
- **≥ 85%**：直接自动发送（高置信度场景）
- **< 85%**：弹窗显示建议回复，需用户确认
  - 可选择"确认发送"直接发送
  - 可选择"修改回复"手动编辑内容
  - 可选择"取消"不发送

### 6. 发送消息

- 点击输入框获取焦点
- 粘贴回复内容
- 按回车发送

## 注意事项

- **输入框坐标**：默认 `{1000, 832}`，需根据实际屏幕调整
- **OCR 识别**：支持中文和英文，设置 `["zh-Hans", "en-US"]`
- **等待时间**：每次操作后建议等待 0.5-1s
- **剪贴板**：使用 AppleScript `set the clipboard` 比 `pbcopy` 更可靠
- **置信度阈值**：默认 85%，可在脚本中调整 `if confidence > 85` 这一行
- **确认弹窗**：低置信度时会显示完整聊天内容和建议回复，支持手动修改

## 自定义配置

### 修改输入框坐标

编辑 `wechat-dm.applescript` 中的：

```bash
cliclick c:1000,832  # 修改为你的坐标
```

### 调整置信度阈值

编辑 `wechat-dm.applescript` 中的：

```applescript
if confidence > 85 then  # 修改为你需要的阈值（0-100）
  set autoSend to true
```

### 添加自定义回复规则

在 `wechat-dm.applescript` 中的智能回复判断部分添加：

```applescript
else if ocrResult contains "你的关键词" then
  set replyText to "你的回复内容"
  set confidence to 90  -- 设置置信度
```

## 错误处理

- 微信未安装：提示安装微信
- 搜索无结果：提示联系人不存在
- OCR 失败：重试截图或使用备用方案
