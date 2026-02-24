#!/usr/bin/env osascript

-- WeChat Auto Reply Script
-- 用法: osascript wechat-dm.applescript "联系人名称" ["消息内容"]
-- 如果提供了消息内容，直接发送；否则执行 OCR 半自动回复

on run argv
  if argv is {} then
    display dialog "请指定联系人名称" buttons {"取消"} default button 1
    return
  end if
  
  set contactName to item 1 of argv
  set customMessage to ""
  
  -- 检查是否有第二个参数（自定义消息）
  if length of argv > 1 then
    set customMessage to item 2 of argv
  end if
  
  -- 1. 激活微信
  tell application "WeChat" to activate
  delay 2
  
  -- 2. 确保前台
  tell application "System Events"
    tell process "WeChat"
      set frontmost to true
    end tell
  end tell
  delay 0.5
  
  -- 3. 打开搜索 (Cmd+F)
  tell application "System Events" to keystroke "f" using {command down}
  delay 0.5
  
  -- 4. 输入搜索词
  set the clipboard to contactName
  tell application "System Events" to keystroke "v" using {command down}
  delay 1
  
  -- 5. 选择联系人（回车）
  tell application "System Events" to key code 36
  delay 1
  
  -- 6. 如果有自定义消息，直接发送
  if customMessage is not "" then
    set the clipboard to customMessage
    do shell script "cliclick c:1000,832"
    delay 0.3
    tell application "System Events" to keystroke "v" using {command down}
    delay 0.3
    tell application "System Events" to key code 36
#    display dialog "已发送：" & customMessage buttons {"确定"} default button 1
    return
  end if
  
  -- 7. 无自定义消息，执行 OCR 自动回复
  -- 截图并保存
  set screenshotPath to "/tmp/wechat_contact_ocr.png"
  do shell script "/usr/sbin/screencapture -x -t png " & quoted form of screenshotPath
  delay 0.5
  
  -- OCR 识别（调用 Python）
  set ocrResult to do shell script "python3 << 'PYEOF'
from Foundation import NSURL
from Vision import VNRecognizeTextRequest, VNImageRequestHandler, VNRequestTextRecognitionLevelAccurate

screenshotPath = '/tmp/wechat_contact_ocr.png'
theURL = NSURL.fileURLWithPath_(screenshotPath)
theRequest = VNRecognizeTextRequest.alloc().initWithCompletionHandler_(None)
theRequest.setRecognitionLevel_(VNRequestTextRecognitionLevelAccurate)
theRequest.setRecognitionLanguages_(['zh-Hans', 'en-US'])
theRequest.setUsesLanguageCorrection_(True)

theHandler = VNImageRequestHandler.alloc().initWithURL_options_(theURL, None)
success, error = theHandler.performRequests_error_([theRequest], None)

if success:
    results = theRequest.results()
    texts = []
    for aResult in results:
        topCandidate = aResult.topCandidates_(1)[0]
        texts.append(topCandidate.string())
    print('|||SEPARATOR|||'.join(texts))
else:
    print('OCR_FAILED')
PYEOF"
  
  -- 8. 分析聊天内容并生成回复（带置信度判断）
  set replyText to "收到"  -- 默认回复
  set confidence to 60  -- 默认置信度（百分比）
  
  if ocrResult contains "OCR_FAILED" then
    display dialog "OCR 识别失败" buttons {"确定"} default button 1
    return
  end if
  
  -- 智能回复判断逻辑（附带置信度）
  if ocrResult contains "在吗" or ocrResult contains "忙吗" then
    set replyText to "在的，什么事？"
    set confidence to 95
  else if ocrResult contains "谢谢" or ocrResult contains "感谢" then
    set replyText to "不客气"
    set confidence to 95
  else if ocrResult contains "收到" and (ocrResult contains "好的" or ocrResult contains "恩" or ocrResult contains "嗯") then
    set replyText to "好的"
    set confidence to 90
  else if ocrResult contains "投资" or ocrResult contains "抄底" or ocrResult contains "行情" then
    set replyText to "不急，等稳一点"
    set confidence to 85
  else if ocrResult contains "?" or ocrResult contains "？" then
    set replyText to "我看看，稍等"
    set confidence to 75
  else if ocrResult contains "好" or ocrResult contains "OK" or ocrResult contains "ok" then
    set replyText to "好的"
    set confidence to 80
  else if ocrResult contains "明天" or ocrResult contains "几点" then
    set replyText to "我确认一下，回头告诉你"
    set confidence to 70
  end if
  
  -- 9. 置信度判断：>85% 自动发送，否则需要确认
  set autoSend to false
  if confidence > 85 then
    set autoSend to true
  else
    -- 生成选项给用户确认
    set dialogText to "检测到聊天内容：" & return & return & "「" & ocrResult & "」" & return & return & "建议回复（置信度 " & confidence & "%）：" & return & "「" & replyText & "」"
    
    set userChoice to button returned of (display dialog dialogText buttons {"取消", "修改回复", "确认发送"} default button 3 cancel button 1)
    
    if userChoice is "确认发送" then
      set autoSend to true
    else if userChoice is "修改回复" then
      -- 让用户手动输入回复
      set customReply to text returned of (display dialog "请输入回复内容：" default answer replyText buttons {"取消", "发送"} default button 2 cancel button 1)
      set replyText to customReply
      set autoSend to true
    else
      return
    end if
  end if
  
  -- 10. 发送消息
  set the clipboard to replyText
  
  -- 点击输入框（坐标需根据实际调整）
  do shell script "cliclick c:1000,832"
  delay 0.3
  
  tell application "System Events" to keystroke "v" using {command down}
  delay 0.3
  
  tell application "System Events" to key code 36
  
  -- 显示结果
  if confidence > 85 then
    display dialog "已自动发送（置信度 " & confidence & "%）：" & return & "「" & replyText & "」" buttons {"确定"} default button 1
  else
    display dialog "已发送回复：" & return & "「" & replyText & "」" buttons {"确定"} default button 1
  end if
  
end run
