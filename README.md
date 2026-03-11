# VLC for iOS - Anime4K Edition

[![Build Status](https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K/workflows/Build%20VLC%20for%20iOS%20with%20Anime4K/badge.svg)](https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K/actions)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![iOS](https://img.shields.io/badge/iOS-12.0%2B-blue)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)

> 基于 VLC for iOS 官方项目改造，集成 Anime4K shader 增强和 WebDAV 远程播放功能

## ✨ 特性

### 🎬 Anime4K Shader 支持
- ✅ **抗锯齿** (AA): 消除动漫中的锯齿
- ✅ **动漫抗锯齿** (aA): 专门优化动漫画面
- ✅ **颜色抗锯齿** (cAA): 改善颜色边缘
- ✅ **锐化** (CAS): 增强细节清晰度
- ✅ **降噪** (Denoise): 减少噪点
- ✅ **去色带** (Deband): 消除色带伪影
- ✅ **线稿模式**: 专门优化线稿显示
- ✅ **性能分级**: 提供高/中/低三个性能等级

### 🌐 WebDAV 支持 (开发中)
- 🔄 远程文件浏览
- 📱 直接流式播放
- 🔐 支持多种认证方式
- 💾 可选文件缓存

### 🎨 自定义 UI
- 🎭 Anime 风格配色方案
- 🎯 简洁现代的界面设计
- ⚡ 流畅的动画效果
- 🌙 深色模式支持

## 📸 截图

<!-- TODO: 添加截图 -->
*截图待补充*

## 🚀 快速开始

### 前置要求

- macOS 10.12 或更高版本
- Xcode 11.0 或更高版本
- CocoaPods 1.4 或更高版本
- iOS 12.0 或更高版本（真机/模拟器）

### 安装步骤

1. **克隆仓库**
```bash
git clone https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K.git
cd VLC-iOS-Anime4K
```

2. **安装依赖**
```bash
cd vlc-ios
pod install
```

3. **打开项目**
```bash
open VLC.xcworkspace
```

4. **编译运行**
   - 在 Xcode 中选择目标设备或模拟器
   - 按 `Cmd + R` 运行项目

## 🎯 使用指南

### Anime4K Shader 设置

1. 打开播放器
2. 点击播放控制菜单
3. 选择 "Anime4K 增强"
4. 选择想要的预设效果
5. 根据设备性能选择合适的强度

### WebDAV 配置（开发中）

1. 进入设置
2. 选择 "云存储"
3. 点击 "添加 WebDAV 服务器"
4. 填写服务器信息：
   - 服务器地址
   - 端口（默认 80/443）
   - 用户名和密码
5. 连接并浏览文件

## 🛠️ 开发

### 项目结构

```
VLC-iOS-Anime4K/
├── vlc-ios/                    # VLC for iOS 主项目
│   ├── Sources/
│   │   ├── Playback/
│   │   │   └── Player/
│   │   │       └── Anime4KShaderManager.swift   # Shader 管理
│   │   └── UI Elements/
│   │       └── Anime4KControlView.swift        # UI 控制
│   └── Resources/
│       └── Shaders/
│           └── Anime4K/                          # GLSL Shaders
├── .github/workflows/       # GitHub Actions 配置
├── QUICKSTART_GUIDE.md       # 快速入门指南
└── README.md                 # 本文件
```

### 构建

#### 本地构建
```bash
cd vlc-ios
xcodebuild -workspace VLC.xcworkspace \
  -scheme VLC-iOS \
  -configuration Debug \
  -sdk iphonesimulator
```

#### GitHub Actions 自动构建
每次推送到 `main` 或 `develop` 分支时，GitHub Actions 会自动构建项目。

## 📚 文档

- [快速入门指南](QUICKSTART_GUIDE.md)
- [详细改造计划](VLC_MODIFICATION_PLAN.md)
- [VLC 官方文档](https://code.videolan.org/videolan/vlc-ios/wikis)
- [Anime4K 官方文档](https://github.com/bloc97/Anime4K)

## 🔧 技术栈

- **语言**: Swift 5.0+, Objective-C
- **框架**: UIKit, AVFoundation
- **播放引擎**: VLCKit 4.0.0a18 (libvlc)
- **依赖管理**: CocoaPods
- **CI/CD**: GitHub Actions

## 📊 Anime4K 性能对比

| 预设 | 性能影响 | 推荐设备 |
|------|---------|---------|
| AA | 低 | 所有设备 |
| aA | 中 | iPhone 8+ |
| cAA | 中 | iPhone 8+ |
| CAS | 高 | iPhone 11+ |
| 线稿模式 | 高 | iPhone 11+ |

## 🤝 贡献

欢迎贡献代码！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

请确保：
- 代码符合项目风格
- 添加适当的注释
- 更新相关文档
- 所有测试通过

## 📄 许可证

本项目基于 GPLv2 和 MPLv2 双重许可。

- VLC for iOS: [GPLv2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
- Anime4K: [MIT License](https://github.com/bloc97/Anime4K/blob/master/LICENSE)

## 🙏 致谢

- [VideoLAN](https://www.videolan.org/) - VLC 媒体播放器
- [Anime4K](https://github.com/bloc97/Anime4K) - 高质量动漫增强算法
- 所有 VLC for iOS 的贡献者

## 📞 联系方式

- 问题反馈: [GitHub Issues](https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K/issues)
- 讨论: [GitHub Discussions](https://github.com/YOUR_USERNAME/VLC-iOS-Anime4K/discussions)

## 🗺️ 路线图

- [x] 项目初始化
- [x] Anime4K Shader 集成
- [x] UI 控制面板
- [ ] WebDAV 完整支持
- [ ] 更多 Shader 预设
- [ ] 性能优化
- [ ] 多语言支持
- [ ] iPad 优化

## 📝 更新日志

### v0.1.0 (2024-03-11)
- ✨ 初始版本发布
- ✨ Anime4K Shader 支持
- ✨ 自定义 UI 设计
- ✨ GitHub Actions 自动构建

---

**Made with ❤️ for Anime lovers**

如果喜欢这个项目，请给个 ⭐ Star！
