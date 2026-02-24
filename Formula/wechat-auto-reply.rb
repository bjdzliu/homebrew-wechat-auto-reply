class WechatAutoReply < Formula
  desc "OpenClaw skill: WeChat Auto Reply with AI-powered confidence scoring"
  homepage "https://github.com/bjdzliu/homebrew-openclaw"
  url "https://github.com/bjdzliu/homebrew-openclaw/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "31e5823e5bcaa5d082b72a95916067bba71b7095c51c84e7f8f5da0c262214c1"
  license "MIT"

  depends_on "cliclick"
  depends_on "python@3"

  def install
    # 打印调试信息
    ohai "Current directory: #{Dir.pwd}"
    ohai "Files present: #{Dir['*'].join(', ')}"
    
    # 安装所有文件到 share 目录
    (share/"openclaw/skills/wechat-auto-reply").mkpath
    (share/"openclaw/skills/wechat-auto-reply").install "SKILL.md"
    (share/"openclaw/skills/wechat-auto-reply").install "wechat-dm.applescript"  
    (share/"openclaw/skills/wechat-auto-reply").install "wechat-dm.sh"

    # 创建 bin 包装脚本
    (bin/"wechat-auto-reply").write <<~EOS
      #!/bin/bash
      exec "#{share}/openclaw/skills/wechat-auto-reply/wechat-dm.sh" "$@"
    EOS
  end

  def post_install
    # 创建 OpenClaw workspace/skills 目录
    skills_root = File.expand_path("~/.openclaw/workspace/skills")
    FileUtils.mkdir_p(skills_root)

    # 创建软链接到用户目录
    target = File.join(skills_root, "wechat-auto-reply")
    FileUtils.rm_rf(target)
    FileUtils.ln_sf(share/"openclaw/skills/wechat-auto-reply", target)

    # 提示用户安装 Python 依赖
    ohai "Installing Python dependencies..."
    system Formula["python@3"].opt_bin/"pip3", "install", "--quiet", "pyobjc"
  end

  def caveats
    <<~EOS
      WeChat Auto Reply skill installed successfully!

      Skill directory:
        #{share}/openclaw/skills/wechat-auto-reply

      Linked to:
        ~/.openclaw/workspace/skills/wechat-auto-reply

      Command available:
        wechat-auto-reply <contact_name> [message]

      Usage:
        # Semi-auto reply (OCR + AI with confidence scoring)
        wechat-auto-reply "联系人名称"

        # Direct message
        wechat-auto-reply "联系人名称" "消息内容"

      IMPORTANT:
        - Requires macOS Automation permissions for WeChat
        - Requires Python package: pyobjc (auto-installed)
        - Requires cliclick (auto-installed as dependency)
        - Default input box coordinates: {1000, 832}
          (modify in #{share}/openclaw/skills/wechat-auto-reply/wechat-dm.applescript if needed)

      For more information, see:
        #{share}/openclaw/skills/wechat-auto-reply/SKILL.md
    EOS
  end

  test do
    assert_predicate bin/"wechat-auto-reply", :exist?
    assert_predicate share/"openclaw/skills/wechat-auto-reply/SKILL.md", :exist?
  end
end