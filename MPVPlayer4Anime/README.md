# MPVPlayer4Anime

基于 mpv 的 iOS 视频播放器，支持 Anime4K 渲染和 WebDAV 远程播放。

## 功能特性

- ✅ 基于 libmpv 核心播放引擎
- ✅ Metal 硬件加速渲染
- ✅ Anime4K GLSL shaders 支持
- ✅ WebDAV 远程文件访问
- ✅ 支持所有主流视频格式（MKV, AVI, MP4 等）
- ✅ 自定义 shader 加载
- ✅ 播放控制（播放/暂停/停止）

## 环境要求

- macOS 12.0+
- Xcode 14.0+
- iOS 15.0+

## 构建说明

### 安装依赖

```bash
# 安装编译工具
brew install meson ninja pkg-config

# 安装 FFmpeg 依赖
brew install ffmpeg libass freetype fribidi fontconfig harfbuzz
```

### 编译 libmpv

```bash
./scripts/build-libmpv.sh
```

编译脚本默认配置为 iOS 15.0 最低版本。

### 使用 Xcode 构建

```bash
cd MPVPlayer4Anime/App
open MPVPlayer4Anime.xcodeproj
```

在 Xcode 中：
1. 选择你的开发团队
2. 选择真机或模拟器
3. 点击 Run (⌘R) 构建

### 使用 GitHub Actions 构建

直接推送代码到 GitHub，Actions 会自动构建。

## 使用说明

1. 添加 WebDAV 服务器
2. 浏览并选择视频文件
3. 选择 Anime4K shader（可选）
4. 开始播放

## 项目结构

```
MPVPlayer4Anime/
├── .github/workflows/      # GitHub Actions 配置
├── MPVPlayer4Anime/App/    # iOS App 主工程
│   ├── MPVPlayer4Anime/    # 主应用代码
│   ├── Views/              # SwiftUI 视图
│   ├── Managers/           # 管理器（WebDAV、Shader）
│   ├── Services/           # 服务（WebDAV Client）
│   └── Resources/Shaders/  # Anime4K GLSL shaders
├── scripts/                # 编译脚本
└── Dependencies/           # 编译产物（libmpv）
```

## License

MIT License
