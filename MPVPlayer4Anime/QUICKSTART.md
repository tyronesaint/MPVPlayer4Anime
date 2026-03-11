# 快速开始指南

## 🚀 5 分钟快速开始

### 第一步：安装依赖
```bash
# 安装编译工具
brew install meson ninja pkg-config ffmpeg libass freetype fribidi fontconfig harfbuzz
```

### 第二步：编译 libmpv
```bash
cd /path/to/MPVPlayer4Anime/scripts
./build-libmpv.sh
```

### 第三步：打开 Xcode 项目
```bash
cd /path/to/MPVPlayer4Anime/MPVPlayer4Anime/App
open MPVPlayer4Anime.xcodeproj
```

### 第四步：配置 Xcode
1. 选择项目 -> "Build Settings"
2. 添加 Header Search Paths：
   ```
   $(PROJECT_DIR)/../../Dependencies/install/include
   ```
3. 添加 Library Search Paths：
   ```
   $(PROJECT_DIR)/../../Dependencies/install/lib
   ```
4. 添加 Other Linker Flags：
   ```
   -lmpv -framework AVFoundation -framework Metal -framework AudioToolbox -framework CoreAudio -framework CoreMedia -framework CoreVideo -framework QuartzCore -framework VideoToolbox
   ```

### 第五步：添加系统框架
在 Xcode 的 "Frameworks, Libraries, and Embedded Content" 中添加：
- AVFoundation.framework
- Metal.framework
- AudioToolbox.framework
- CoreAudio.framework
- CoreMedia.framework
- CoreVideo.framework
- QuartzCore.framework
- VideoToolbox.framework

### 第六步：设置开发团队
选择你的 Apple Developer 账号。

### 第七步：运行
点击 "Run" 按钮（⌘R）

## 📱 使用应用

### 添加 WebDAV 服务器
1. 打开应用
2. 进入"文件"标签页
3. 点击"添加服务器"
4. 填写服务器信息：
   - 名称：任意
   - URL：WebDAV 服务器地址（如 `https://yourserver.com/webdav`）
   - 用户名：WebDAV 用户名
   - 密码：WebDAV 密码

### 浏览和播放视频
1. 在"文件"标签页选择已添加的服务器
2. 浏览目录结构
3. 点击视频文件开始播放

### 使用 Anime4K Shader
1. 在播放界面，点击 Shader 按钮
2. 选择要使用的 Anime4K Shader
3. Shader 会立即应用到视频上

### 添加自定义 Shaders
1. 将 `.glsl` 文件复制到应用的 Documents/Shaders 目录
2. 重启应用或刷新设置
3. 在"设置" -> "Anime4K Shaders" 中查看可用 Shaders

## 🎨 下载 Anime4K Shaders

```bash
# 克隆 Anime4K 仓库
cd MPVPlayer4Anime/App/Resources
git clone https://github.com/bloc97/Anime4K.git Shaders
```

然后重启应用，Shaders 会自动复制到应用文档目录。

## ⚙️ 配置选项

### 调整 iOS 最低版本
在 `scripts/build-libmpv.sh` 中修改：
```bash
IOS_DEPLOYMENT_TARGET="15.0"  # 改为你想要的版本
```

在 Xcode 中：
```
Build Settings -> iOS Deployment Target
```

### 启用详细日志
在 `MPVPlayerWrapper.m` 中修改：
```objc
mpv_set_option_string(self.mpv, "loglevel", "v");
```

## 🔧 故障排除

### 问题：编译 libmpv 失败
**解决方案**：
```bash
# 更新 Homebrew
brew update && brew upgrade

# 清理并重新编译
cd scripts
./build-libmpv.sh
```

### 问题：Xcode 找不到 mpv 头文件
**解决方案**：
检查 Header Search Paths 是否包含：
```
$(PROJECT_DIR)/../../Dependencies/install/include
```

### 问题：链接错误
**解决方案**：
1. 确认 Library Search Paths 包含：
   ```
   $(PROJECT_DIR)/../../Dependencies/install/lib
   ```
2. 确认 Other Linker Flags 包含：
   ```
   -lmpv
   ```

### 问题：WebDAV 连接失败
**解决方案**：
1. 检查服务器 URL 是否正确
2. 确认用户名和密码是否正确
3. 尝试在浏览器中访问 WebDAV 服务器
4. 检查服务器是否支持 Basic Authentication

## 📚 更多信息

- [完整构建指南](BUILD.md)
- [GitHub Actions](.github/workflows/build.yml)
- [Anime4K 官方文档](https://github.com/bloc97/Anime4K)

## 💡 提示

### 性能优化建议
1. 使用较新版本的 Anime4K Shaders（M 或 S 版本）
2. 启用硬件解码（默认已启用）
3. 在较旧的设备上使用较小的 Shader 版本

### WebDAV 服务器推荐
- Nextcloud（开源）
- ownCloud（开源）
- Synology NAS（内置 WebDAV）
- 任何标准 WebDAV 服务器

## 🎉 开始享受吧！

现在你已经准备好使用 MPVPlayer4Anime 了：
- ✅ 支持 WebDAV 远程播放
- ✅ 支持 Anime4K 画质增强
- ✅ 支持 MKV、AVI 等所有主流格式
- ✅ Metal 硬件加速
- ✅ 简洁的 SwiftUI 界面

**有问题？** 查看 [BUILD.md](BUILD.md) 或提交 Issue。
