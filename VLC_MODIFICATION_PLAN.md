# VLC for iOS 改造计划

## 项目概述

基于 VLC for iOS 官方项目，改造为支持 Anime4K 渲染和 WebDAV 远程播放的 Anime 专用播放器。

## 项目结构分析

### 当前 VLC 项目架构

```
vlc-ios/
├── Sources/
│   ├── Playback/          # 播放器核心逻辑
│   │   ├── Player/        # 播放器控制器和视图
│   │   ├── Control/       # 播放控制
│   │   └── Queue/         # 播放队列
│   ├── Cloud/             # 云存储集成（已支持 Google Drive, OneDrive, Dropbox）
│   ├── Media Library/     # 媒体库管理
│   ├── Network/           # 网络流媒体
│   ├── Settings/          # 设置界面
│   └── UI Elements/       # UI 组件
├── Resources/             # 资源文件（图片、图标等）
├── Podfile               # CocoaPods 依赖配置
└── VLC.xcworkspace       # Xcode 工作区
```

### 核心技术栈

- **播放引擎**：VLCKit 4.0.0a18（libvlc 的 iOS 封装）
- **语言**：Swift + Objective-C
- **最低系统**：iOS 12.0（我们可以改为 iOS 15.0）
- **依赖管理**：CocoaPods

## 改造计划

### Phase 1: 项目初始化和配置 ✅

- [x] 克隆 VLC for iOS 项目
- [x] 分析项目结构
- [ ] 更新 Podfile 依赖
- [ ] 配置项目设置

### Phase 2: 集成 Anime4K Shader 支持

#### 2.1 下载 Anime4K Shaders

Anime4K 是一组 GLSL shader，需要将其集成到 VLC 的视频渲染管线中。

```bash
# 下载 Anime4K shaders
mkdir -p vlc-ios/Resources/Shaders/Anime4K
cd vlc-ios/Resources/Shaders/Anime4K

# 下载 Anime4K GLSL shaders
git clone https://github.com/bloc97/Anime4K.git
cp -r Anime4K/glsl/*.glsl .
```

#### 2.2 创建 Shader 管理器

在 VLC 项目中创建一个新的管理器来加载和应用 Anime4K shader。

**文件**：`Sources/Playback/Player/Anime4KShaderManager.swift`

```swift
import Foundation

class Anime4KShaderManager {
    enum Preset: String, CaseIterable {
        case none = "None"
        case aa = "Anime4K_3Dnn_AA"
        case aaThin = "Anime4K_3Dnn_AA_Thin"
        case aA = "Anime4K_3Dnn_aA"
        case aAThin = "Anime4K_3Dnn_aA_Thin"
        case aAB = "Anime4K_3Dnn_aAB_Thin"
        case ac = "Anime4K_3Dnn_ac"
        case acThin = "Anime4K_3Dnn_ac_Thin"
        case cAA = "Anime4K_3Dnn_cAA_Thin"
        case caaB = "Anime4K_3Dnn_caaB_Thin"
        case cas = "Anime4K_3Dnn_cas"
        case deband = "Anime4K_3Dnn_Deband"
        case denoise = "Anime4K_3Dnn_Denoise"
        case recoverDetail = "Anime4K_3Dnn_Recover_Detail"
        case lineArtMode = "Anime4K_3Dnn_LineArtMode_Thin"
    }

    private var currentPreset: Preset = .none
    private var shaders: [Preset: String] = [:]

    init() {
        loadShaders()
    }

    private func loadShaders() {
        // 从 Resources/Shaders/Anime4K 加载 shader 文件
        for preset in Preset.allCases {
            if preset != .none {
                let shaderPath = Bundle.main.path(forResource: preset.rawValue, ofType: "glsl", inDirectory: "Shaders/Anime4K")
                if let path = shaderPath, let shaderContent = try? String(contentsOfFile: path) {
                    shaders[preset] = shaderContent
                }
            }
        }
    }

    func getShader(for preset: Preset) -> String? {
        return shaders[preset]
    }

    func setCurrentPreset(_ preset: Preset) {
        currentPreset = preset
    }

    func getCurrentPreset() -> Preset {
        return currentPreset
    }
}
```

#### 2.3 集成到播放器

修改 `PlayerViewController.swift`，添加 Anime4K shader 应用逻辑。

**关键修改点**：
1. 在播放器初始化时创建 `Anime4KShaderManager` 实例
2. 在视频渲染时应用选中的 shader
3. 添加 UI 控制来切换不同的 Anime4K 预设

### Phase 3: 集成 WebDAV 支持

VLC 已经支持多种云存储（Google Drive, OneDrive, Dropbox），我们可以参考这些实现来添加 WebDAV 支持。

#### 3.1 创建 WebDAV 服务

**文件**：`Sources/Cloud/WebDAVService.swift`

```swift
import Foundation

class WebDAVService {
    static let shared = WebDAVService()

    private var session: URLSession?
    private var baseURL: String?
    private var credentials: URLCredential?

    private init() {}

    func configure(url: String, username: String? = nil, password: String? = nil) {
        baseURL = URL(string: url)
        if let user = username, let pass = password {
            credentials = URLCredential(user: user, password: pass, persistence: .forSession)
        }

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": "VLC-iOS",
            "Accept": "*/*",
            "Depth": "1"
        ]

        if let creds = credentials {
            let authString = "\(creds.user!):\(creds.password!)"
            let authData = authString.data(using: .utf8)!
            let base64Auth = authData.base64EncodedString()
            config.httpAdditionalHeaders?["Authorization"] = "Basic \(base64Auth)"
        }

        session = URLSession(configuration: config)
    }

    func listFiles(at path: String = "/", completion: @escaping ([WebDAVFile]) -> Void) {
        guard let baseURL = baseURL else { return }

        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")

        session?.dataTask(with: request) { data, response, error in
            // 解析 WebDAV XML 响应
            // 返回文件列表
        }.resume()
    }

    func downloadFile(at path: String, completion: @escaping (URL?) -> Void) {
        // 下载文件
    }
}

struct WebDAVFile {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let lastModified: Date?
}
```

#### 3.2 添加 WebDAV 设置界面

参考现有的云存储设置界面（Google Drive, OneDrive），创建 WebDAV 设置页面。

**文件**：`Sources/Settings/WebDAVSettingsViewController.swift`

#### 3.3 集成到媒体库

将 WebDAV 文件添加到 VLC 的媒体库中，使其可以像本地文件一样播放。

### Phase 4: UI 界面定制

将 VLC 的界面改为适合 Anime 观看的风格：

#### 4.1 配色方案

- 主色调：紫罗兰色 (#8B5CF6) - 动漫风格
- 背景色：深紫色 (#1E1B4B)
- 强调色：粉色 (#EC4899)
- 文字色：白色/浅灰

#### 4.2 UI 元素

- 播放器界面：深色模式，简洁设计
- 进度条：紫色渐变
- 按钮：圆角设计，带微发光效果
- 字幕显示：底部居中，白色黑边

### Phase 5: 编译和测试

#### 5.1 安装依赖

```bash
cd vlc-ios
pod install
```

#### 5.2 编译项目

```bash
# 用 Xcode 打开工作区
open VLC.xcworkspace

# 或使用命令行编译
xcodebuild -workspace VLC.xcworkspace -scheme VLC-iOS -configuration Debug
```

#### 5.3 测试功能

- [ ] 播放本地视频文件
- [ ] 应用 Anime4K shader
- [ ] 连接 WebDAV 服务器
- [ ] 从 WebDAV 播放视频
- [ ] 测试不同的 Anime4K 预设
- [ ] 性能测试

## 关键技术挑战

### 1. Shader 集成

**挑战**：VLC 使用 libvlc，shader 需要通过 VLC 的视频滤镜 API 应用。

**解决方案**：
- 使用 VLC 的 `--video-filter` 参数应用自定义 shader
- 或者直接修改 VLCKit 的渲染管线

### 2. WebDAV 认证

**挑战**：WebDAV 支持多种认证方式（Basic, Digest, OAuth）。

**解决方案**：
- 先实现 Basic 认证
- 后续可扩展支持 Digest 和 OAuth

### 3. 性能优化

**挑战**：Anime4K shader 可能影响播放性能。

**解决方案**：
- 提供多个性能预设（低、中、高）
- 在设置中允许用户选择
- 默认使用中等预设

## 下一步行动

1. ✅ 完成 Phase 1：项目初始化
2. ⏳ 开始 Phase 2：集成 Anime4K shader
3. ⏳ 开始 Phase 3：集成 WebDAV 支持
4. ⏳ 开始 Phase 4：UI 定制
5. ⏳ 开始 Phase 5：编译测试

## 参考资料

- [Anime4K GitHub](https://github.com/bloc97/Anime4K)
- [VLC for iOS Wiki](https://code.videolan.org/videolan/vlc-ios/wikis)
- [VLCKit 文档](https://code.videolan.org/videolan/VLCKit)
- [WebDAV 协议规范](https://tools.ietf.org/html/rfc4918)
