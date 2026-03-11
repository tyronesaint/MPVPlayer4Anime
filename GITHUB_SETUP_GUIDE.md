# 🚀 GitHub 上传和自动构建指南

本指南将帮助你将 VLC-iOS-Anime4K 项目上传到 GitHub，并配置 GitHub Actions 自动构建。

## 📋 前置准备

1. **GitHub 账号**
   - 如果没有，先注册: https://github.com/signup

2. **Git 安装**
   ```bash
   # 检查是否已安装
   git --version

   # macOS 通常已预装
   # 如果没有，使用 Homebrew 安装:
   brew install git
   ```

3. **配置 Git**
   ```bash
   git config --global user.name "你的名字"
   git config --global user.email "你的邮箱"
   ```

## 🎯 方法一：使用自动化脚本（推荐）

### 步骤 1: 运行设置脚本

```bash
cd /workspace/projects
chmod +x setup_github_repo.sh
./setup_github_repo.sh
```

脚本会引导你完成：
- 输入仓库名称
- 输入 GitHub 用户名
- 自动初始化 Git 仓库
- 创建 `.gitignore`
- 提交代码
- 添加远程仓库
- 推送到 GitHub

### 步骤 2: 手动创建 GitHub 仓库

1. 访问: https://github.com/new
2. 填写仓库信息：
   - **仓库名称**: VLC-iOS-Anime4K
   - **描述**: VLC for iOS with Anime4K shader support
   - **可见性**: Public（推荐）或 Private
   - **初始化选项**: **不要**勾选任何选项（因为我们会推送现有代码）
3. 点击 "Create repository"
4. 回到终端，按 Enter 继续推送

## 🎯 方法二：手动操作

### 步骤 1: 创建 GitHub 仓库

访问 https://github.com/new 创建新仓库。

### 步骤 2: 初始化 Git

```bash
cd /workspace/projects
git init
```

### 步骤 3: 创建 .gitignore

创建 `.gitignore` 文件，内容见项目根目录。

### 步骤 4: 提交代码

```bash
git add .
git commit -m "Initial commit: VLC for iOS with Anime4K integration"
```

### 步骤 5: 连接远程仓库

```bash
# 替换 YOUR_USERNAME 为你的 GitHub 用户名
git remote add origin https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K.git
```

### 步骤 6: 推送到 GitHub

```bash
git branch -M main
git push -u origin main
```

## 🤖 GitHub Actions 自动构建

### 工作原理

每次你推送代码到 `main` 或 `develop` 分支时，GitHub Actions 会自动：

1. ✅ 检出代码
2. ✅ 设置 Xcode 环境
3. ✅ 安装依赖（CocoaPods）
4. ✅ 编译 VLC-iOS
5. ✅ 运行测试（如果有）
6. ✅ 上传构建产物

### 查看构建状态

1. 访问你的 GitHub 仓库
2. 点击 "Actions" 标签页
3. 查看最新的构建工作流

### 下载构建产物

构建成功后，你可以：

1. 在 Actions 页面找到成功的构建
2. 滚动到底部 "Artifacts" 部分
3. 下载构建产物（`.app` 文件或 `.xcarchive`）

## 🔄 自动部署脚本

项目包含一个便捷的部署脚本 `deploy.sh`：

```bash
chmod +x deploy.sh
./deploy.sh
```

这个脚本会：
- 检查待提交的更改
- 询问提交信息
- 自动提交并推送
- 显示 Actions 链接

## 📁 项目文件结构

推送后，GitHub 仓库将包含：

```
VLC-iOS-Anime4K/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions 配置
├── vlc-ios/                   # VLC 主项目
├── MPVPlayer4Anime/           # 旧的 mpv 项目（可选）
├── Resources/                 # 资源文件
├── README.md                  # 项目说明
├── QUICKSTART_GUIDE.md        # 快速入门
├── VLC_MODIFICATION_PLAN.md   # 改造计划
├── deploy.sh                  # 部署脚本
├── setup_github_repo.sh       # GitHub 设置脚本
└── download_anime4k_shaders.sh # Shader 下载脚本
```

## 🎯 常见问题

### Q1: 推送时提示认证失败

**解决方案**:
```bash
# 方法 1: 使用 Personal Access Token
# 1. GitHub Settings -> Developer settings -> Personal access tokens -> Tokens (classic)
# 2. 生成新 Token，勾选 `repo` 权限
# 3. 使用 Token 代替密码

# 方法 2: 使用 SSH
git remote set-url origin git@github.com:YOUR_USERNAME/VLC-iOS-Anime4K.git
```

### Q2: Actions 构建失败

**可能原因**:
- CocoaPods 安装失败
- Xcode 版本不匹配
- 代码有编译错误

**解决方案**:
1. 查看 Actions 日志
2. 检查错误信息
3. 本地修复后再推送

### Q3: 如何修改 Actions 配置

编辑 `.github/workflows/build.yml` 文件，然后推送：

```bash
git add .github/workflows/build.yml
git commit -m "Update workflow configuration"
git push
```

### Q4: 如何添加更多平台支持

在 `build.yml` 中添加新的 job，例如：

```yaml
build-ipad:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - name: Build for iPad
      run: |
        cd vlc-ios
        xcodebuild -workspace VLC.xcworkspace \
          -scheme VLC-iOS \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPad Pro'
```

## 🎨 自定义 Actions

### 添加徽章到 README

在 `README.md` 中添加：

```markdown
[![Build Status](https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K/workflows/Build%20VLC%20for%20iOS%20with%20Anime4K/badge.svg)](https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K/actions)
```

记得替换 `YOUR_USERNAME` 为你的实际用户名。

### 配置构建触发器

在 `.github/workflows/build.yml` 中修改：

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]  # 推送更多分支触发
  pull_request:
    branches: [ main ]                      # PR 到 main 触发
  schedule:
    - cron: '0 0 * * 0'                    # 每周日 0:00 定时构建
  workflow_dispatch:                        # 手动触发
```

## 📊 监控构建

### 设置构建通知

1. 进入 GitHub 仓库
2. Settings -> Notifications
3. 选择你想要的通知方式（Email、GitHub App 等）

### 查看构建历史

```bash
# 使用 GitHub CLI
gh run list --repo YOUR_USERNAME/VLC-iOS-Anime4K

# 查看特定构建
gh run view RUN_ID --repo YOUR_USERNAME/VLC-iOS-Anime4K
```

## 🎉 完成！

现在你的项目已经：

✅ 上传到 GitHub
✅ 配置了自动构建
✅ 可以通过 Actions 查看构建状态
✅ 可以下载构建产物

下一步：
1. 在本地 Xcode 中开发新功能
2. 使用 `deploy.sh` 快速部署
3. 在 GitHub 上查看构建结果
4. 邀请朋友测试你的应用

祝你开发顺利！🚀
