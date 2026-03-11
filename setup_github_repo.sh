#!/bin/bash

# GitHub Repository Setup Script
# 初始化并推送到 GitHub 仓库

set -e

echo "═══════════════════════════════════════════════════"
echo "🚀 VLC for iOS - Anime4K Edition"
echo "GitHub Repository Setup"
echo "═══════════════════════════════════════════════════"
echo ""

# 检查是否在项目根目录
if [ ! -f "QUICKSTART_GUIDE.md" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# 询问仓库名称
read -p "请输入 GitHub 仓库名称 (默认: VLC-iOS-Anime4K): " REPO_NAME
REPO_NAME=${REPO_NAME:-VLC-iOS-Anime4K}

# 询问 GitHub 用户名
read -p "请输入 GitHub 用户名: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GitHub 用户名不能为空"
    exit 1
fi

echo ""
echo "📋 配置信息:"
echo "  仓库名称: $REPO_NAME"
echo "  用户名: $GITHUB_USERNAME"
echo ""

# 确认继续
read -p "确认继续? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "❌ 操作已取消"
    exit 0
fi

echo ""
echo "🔧 正在初始化 Git 仓库..."

# 初始化 Git 仓库
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git 仓库已初始化"
else
    echo "⚠️  Git 仓库已存在"
fi

# 添加 .gitignore
echo "📝 创建 .gitignore 文件..."
cat > .gitignore << 'EOF'
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
*.xcworkspace/*
!*.xcworkspace/xcshareddata/
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3

# CocoaPods
Pods/
vlc-ios/Pods/
*.xcworkspace

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Temporary files
*~
*.swp
*.tmp
*.temp

# Build artifacts
*.app
*.dSYM.zip
*.dSYM
*.ipa

# Logs
*.log

# Anime4K shaders (optional)
# Uncomment if you want to ignore shaders
# vlc-ios/Resources/Shaders/

# Backups
*.bak
*.backup

EOF
echo "✅ .gitignore 已创建"

# 添加所有文件
echo "📦 添加文件到 Git..."
git add .

# 提交初始版本
echo "💾 创建初始提交..."
git commit -m "Initial commit: VLC for iOS with Anime4K integration

Features:
- Anime4K Shader Support
- Custom UI Design
- WebDAV Integration (coming soon)

Based on VLC for iOS official project
"

# 添加远程仓库
GITHUB_REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo ""
echo "🔗 添加远程仓库: $GITHUB_REPO_URL"
git remote add origin "$GITHUB_REPO_URL"

# 提示用户手动创建仓库
echo ""
echo "═══════════════════════════════════════════════════"
echo "⚠️  重要提示"
echo "═══════════════════════════════════════════════════"
echo ""
echo "在执行下一步之前，请先在 GitHub 上创建仓库："
echo ""
echo "1. 访问: https://github.com/new"
echo "2. 仓库名称: $REPO_NAME"
echo "3. 描述: VLC for iOS with Anime4K shader support"
echo "4. 可见性: Public (推荐) 或 Private"
echo "5. 初始化选项: 勾选 'Add a README file'"
echo "6. 点击 'Create repository'"
echo ""
read -p "创建完成后按 Enter 继续..."

# 推送到 GitHub
echo ""
echo "🚀 推送到 GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "═══════════════════════════════════════════════════"
echo "✅ 仓库设置完成！"
echo "═══════════════════════════════════════════════════"
echo ""
echo "📍 仓库地址: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "📝 下一步操作:"
echo "1. 访问仓库: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "2. 查看 Actions 标签页，确认构建状态"
echo "3. 在本地 Xcode 中打开项目: cd vlc-ios && open VLC.xcworkspace"
echo "4. 阅读 QUICKSTART_GUIDE.md 了解如何使用"
echo ""
echo "🎉 恭喜！你的 VLC-iOS-Anime4K 项目已成功推送到 GitHub！"
echo ""
