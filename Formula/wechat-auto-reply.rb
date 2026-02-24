class WechatAutoReply < Formula
  desc "OpenClaw skill: WeChat Auto Reply with AI-powered confidence scoring"
  homepage "https://github.com/bjdzliu/homebrew-wechat-auto-reply"
  url "https://github.com/bjdzliu/homebrew-wechat-auto-reply/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "6cddf561133a6d496123efe6ffe15cb27b2715a65a18f03bde099ae912db6336"
  license "MIT"

  depends_on "cliclick"
  depends_on "python@3"

  def install
    # 安装所有文件到 share 目录
    (share/"openclaw/skills/wechat-auto-reply").install "SKILL.md", "wechat-dm.applescript", "wechat-dm.sh"

    # 创建 bin 包装脚本
    (bin/"wechat-auto-reply").write <<~EOS
      #!/bin/bash
      exec "#{share}/openclaw/skills/wechat-auto-reply/wechat-dm.sh" "$@"
    EOS
  end

  def post_install
    # 创建 OpenClaw skills 目录
    skills_root = File.expand_path("~/.openclaw/skills")
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
      ✅ WeChat Auto Reply installed successfully!

      📦 Installation:
        # Method 1: One-line install (full path)
        brew install bjdzliu/wechat-auto-reply/wechat-auto-reply

        # Method 2: Two-step install (shorter command)
        brew tap bjdzliu/wechat-auto-reply
        brew install wechat-auto-reply

      🚀 Usage:
        # Semi-auto reply (OCR + AI with confidence scoring)
        wechat-auto-reply "联系人名称"

        # Direct message
        wechat-auto-reply "联系人名称" "消息内容"

      📂 Locations:
        Skill directory: #{share}/openclaw/skills/wechat-auto-reply
        User link: ~/.openclaw/skills/wechat-auto-reply
        Command: $(which wechat-auto-reply)

      ⚠️  Requirements:
        • macOS Automation permissions for WeChat
        • Python package: pyobjc (auto-installed)
        • cliclick (auto-installed as dependency)
        • Default input box coordinates: {1000, 832}
          (modify in #{share}/openclaw/skills/wechat-auto-reply/wechat-dm.applescript if needed)

      📖 Documentation:
        #{share}/openclaw/skills/wechat-auto-reply/SKILL.md
    EOS
  end

  test do
    assert_predicate bin/"wechat-auto-reply", :exist?
    assert_predicate share/"openclaw/skills/wechat-auto-reply/SKILL.md", :exist?
  end
end