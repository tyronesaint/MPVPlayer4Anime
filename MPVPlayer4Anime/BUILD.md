# 构建指南

## 前置条件

### 系统要求
- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- iOS 15.0 或更高版本（应用最低版本）

### 安装依赖

#### 1. 安装 Homebrew（如果还没有）
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. 安装编译工具
```bash
# 安装 Meson 和 Ninja（用于编译 libmpv）
brew install meson ninja pkg-config

# 安装 FFmpeg 依赖
brew install ffmpeg libass freetype fribidi fontconfig harfbuzz
```

## 构建步骤

### 1. 克隆项目
```bash
git clone https://github.com/yourusername/MPVPlayer4Anime.git
cd MPVPlayer4Anime
```

### 2. 编译 libmpv
```bash
cd scripts
chmod +x build-libmpv.sh
./build-libmpv.sh
```

这会在 `../Dependencies/install/` 目录下生成：
- `lib/libmpv.a` - 静态库文件
- `include/mpv/` - 头文件

### 3. 配置 Xcode 项目
```bash
cd ../MPVPlayer4Anime/App
open MPVPlayer4Anime.xcodeproj
```

在 Xcode 中：
1. 选择项目 -> "MPVPlayer4Anime"
2. 在 "Build Settings" 中搜索 "Header Search Paths"
3. 添加路径：`$(PROJECT_DIR)/../../Dependencies/install/include`
4. 搜索 "Library Search Paths"
5. 添加路径：`$(PROJECT_DIR)/../../Dependencies/install/lib`
6. 搜索 "Other Linker Flags"
7. 添加：`-lmpv -framework AVFoundation -framework Metal -framework AudioToolbox -framework CoreAudio -framework CoreMedia -framework CoreVideo -framework QuartzCore -framework VideoToolbox`

### 4. 添加系统框架
在 Xcode 中：
1. 选择项目 -> "General" -> "Frameworks, Libraries, and Embedded Content"
2. 点击 "+" 添加以下框架：
   - AVFoundation.framework
   - AudioToolbox.framework
   - CoreAudio.framework
   - CoreMedia.framework
   - CoreVideo.framework
   - Metal.framework
   - QuartzCore.framework
   - VideoToolbox.framework

### 5. 设置开发团队
1. 在 Xcode 中选择项目 -> "Signing & Capabilities"
2. 在 "Team" 下拉菜单中选择你的 Apple Developer 账号
3. 如果没有，点击 "Add an Account" 添加

### 6. 构建并运行
1. 选择目标设备（真机或模拟器）
2. 点击左上角的 "Run" 按钮（▶️）
3. 或者按 `⌘R`

## 使用 GitHub Actions 构建

如果你想使用 GitHub Actions 自动构建：

1. 将代码推送到 GitHub
2. GitHub Actions 会自动触发构建
3. 在 "Actions" 标签页查看构建进度
4. 构建完成后，可以下载构建产物（xcarchive 文件）

## 常见问题

### 1. 编译 libmpv 失败
**问题**：Meson 配置失败
**解决方案**：
- 检查是否安装了所有依赖：`brew list`
- 尝试更新 Homebrew：`brew update && brew upgrade`
- 查看错误日志，可能需要手动调整编译参数

### 2. Xcode 找不到头文件
**问题**：`'mpv/client.h' file not found`
**解决方案**：
- 确认 libmpv 编译成功
- 检查 "Header Search Paths" 是否正确
- 路径应该是：`$(PROJECT_DIR)/../../Dependencies/install/include`

### 3. 链接错误
**问题**：`Undefined symbols for architecture arm64`
**解决方案**：
- 确认 "Library Search Paths" 包含：`$(PROJECT_DIR)/../../Dependencies/install/lib`
- 确认 "Other Linker Flags" 包含：`-lmpv`
- 确认所有必需的框架都已添加

### 4. Metal 渲染不工作
**问题**：视频无法播放，黑屏
**解决方案**：
- 确认设备支持 Metal（iPhone 6s 及以上）
- 检查日志中是否有 Metal 相关错误
- 尝试降低 iOS 部署目标版本

## 下载 Anime4K Shaders

### 方式 1：手动下载
```bash
cd MPVPlayer4Anime/App/Resources
git clone https://github.com/bloc97/Anime4K.git Shaders
```

### 方式 2：使用 submodule
```bash
git submodule add https://github.com/bloc97/Anime4K.git MPVPlayer4Anime/App/Resources/Shaders
```

## 调试

### 查看日志
在 Xcode 中：
1. 打开 Debug Area（`⇧⌘Y`）
2. 选择 Console
3. 查看应用输出的日志

### 启用详细日志
在 `MPVPlayerWrapper.m` 中修改：
```objc
mpv_set_option_string(self.mpv, "loglevel", "v"); // v = verbose
```

## 性能优化

### 1. 使用硬件解码
libmpv 默认使用 VideoToolbox 硬件解码：
```objc
mpv_set_option_string(self.mpv, "hwdec", "videotoolbox");
```

### 2. 调整 shader 性能
Anime4K 有多个版本，性能不同：
- `L` - 低性能，高质量
- `M` - 中等性能
- `S` - 高性能，较低质量
- `UL` - 超高质量，低性能
- `VL` - 超高质量，最低性能

根据设备性能选择合适的 shader 版本。

## 下一步

- [x] 项目初始化
- [x] 编译 libmpv
- [x] 集成到 Xcode
- [x] 实现 WebDAV 客户端
- [x] 实现 Shader 管理
- [x] 创建 UI 界面
- [x] 配置 GitHub Actions

**完成！** 🎉
