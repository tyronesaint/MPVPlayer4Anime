//
//  MPVPlayerWrapper.m
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

#import "MPVPlayer4Anime-Bridging-Header.h"
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

@interface MPVPlayerWrapper ()

@property (nonatomic, assign) mpv_handle *mpv;
@property (nonatomic, assign) mpv_render_context *renderContext;
@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, weak) UIView *playerView;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation MPVPlayerWrapper

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        self.playerView = view;
        _isPlaying = NO;
        [self setupMPV];
        [self setupMetal];
    }
    return self;
}

- (void)dealloc {
    if (self.renderContext) {
        mpv_render_context_free(self.renderContext);
    }
    if (self.mpv) {
        mpv_terminate_destroy(self.mpv);
    }
}

#pragma mark - Setup

- (void)setupMPV {
    // 创建 mpv 实例
    self.mpv = mpv_create();
    if (!self.mpv) {
        NSLog(@"❌ Failed to create mpv instance");
        return;
    }

    // 配置 mpv 选项
    mpv_set_option_string(self.mpv, "vo", "libmpv");
    mpv_set_option_string(self.mpv, "hwdec", "videotoolbox");
    mpv_set_option_string(self.mpv, "video-sync", "audio");
    mpv_set_option_string(self.mpv, "loglevel", "v");
    mpv_set_option_string(self.mpv, "demuxer-seekable-cache", "yes");

    // 初始化 mpv
    if (mpv_initialize(self.mpv) < 0) {
        NSLog(@"❌ Failed to initialize mpv");
        mpv_terminate_destroy(self.mpv);
        self.mpv = NULL;
        return;
    }

    NSLog(@"✅ mpv initialized successfully");
}

- (void)setupMetal {
    // 创建 Metal 设备
    self.device = MTLCreateSystemDefaultDevice();
    if (!self.device) {
        NSLog(@"❌ Metal is not supported on this device");
        return;
    }

    self.commandQueue = [self.device newCommandQueue];

    // 设置 Metal layer
    Class metalLayerClass = NSClassFromString(@"CAMetalLayer");
    if (metalLayerClass) {
        self.metalLayer = (CAMetalLayer *)[metalLayerClass layer];
        self.metalLayer.device = self.device;
        self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        self.metalLayer.framebufferOnly = YES;
        self.metalLayer.frame = self.playerView.bounds;

        // 替换 view 的 layer
        [self.playerView.layer addSublayer:self.metalLayer];
    }

    // 配置渲染上下文
    int advanced = 1;
    mpv_render_param params[] = {
        {.type = MPV_RENDER_PARAM_API_TYPE, .data = MPV_RENDER_API_TYPE_METAL},
        {.type = MPV_RENDER_PARAM_ADVANCED_CONTROL, .data = &advanced},
        {.type = MPV_RENDER_PARAM_INVALID}
    };

    if (mpv_render_context_create(&self.renderContext, self.mpv, params) < 0) {
        NSLog(@"❌ Failed to create mpv render context");
        return;
    }

    NSLog(@"✅ Metal render context created");

    // 设置 Metal layer 回调
    mpv_render_context_set_update_callback(self.renderContext, update_callback, (__bridge void *)self);

    // 开始渲染循环
    [self startRenderLoop];
}

#pragma mark - Control

- (void)loadFile:(NSString *)path {
    if (!self.mpv) return;

    NSLog(@"📽️  Loading file: %@", path);

    const char *cmd[] = {"loadfile", path.UTF8String, NULL};
    mpv_command(self.mpv, cmd);

    // 自动播放
    [self play];
}

- (void)play {
    if (!self.mpv) return;
    mpv_set_property_string(self.mpv, "pause", "no");
    self.isPlaying = YES;
    NSLog(@"▶️  Playback started");
}

- (void)pause {
    if (!self.mpv) return;
    mpv_set_property_string(self.mpv, "pause", "yes");
    self.isPlaying = NO;
    NSLog(@"⏸️  Playback paused");
}

- (void)stop {
    if (!self.mpv) return;
    mpv_command_string(self.mpv, "stop");
    self.isPlaying = NO;
    NSLog(@"⏹️  Playback stopped");
}

- (void)setShader:(NSString *)shaderPath {
    if (!self.mpv || !shaderPath) return;

    NSLog(@"🎨 Loading shader: %@", shaderPath);

    // 清除之前的 shaders
    const char *clearCmd[] = {"change-list", "glsl-shaders", "clr", "", NULL};
    mpv_command(self.mpv, clearCmd);

    // 设置新的 shader
    NSString *shaderOption = [NSString stringWithFormat:@"--glsl-shader=%@", shaderPath];
    const char *cmd[] = {"change-list", "glsl-shaders", "append", shaderOption.UTF8String, NULL};
    mpv_command(self.mpv, cmd);

    NSLog(@"✅ Shader loaded successfully");
}

#pragma mark - Render Loop

static void update_callback(void *ctx) {
    MPVPlayerWrapper *player = (__bridge MPVPlayerWrapper *)ctx;
    dispatch_async(dispatch_get_main_queue(), ^{
        [player render];
    });
}

- (void)render {
    if (!self.renderContext || !self.metalLayer) return;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if (!commandBuffer) return;

    id<MTLDrawable> drawable = self.metalLayer.nextDrawable;
    if (!drawable) return;

    // 配置渲染参数
    int flip = 1;
    mpv_render_param params[] = {
        {.type = MPV_RENDER_PARAMMetal_LAYER, .data = (__bridge void *)self.metalLayer},
        {.type = MPV_RENDER_PARAM_FLIP_Y, .data = &flip},
        {.type = MPV_RENDER_PARAM_INVALID}
    };

    // 执行渲染
    mpv_render_context_render(self.renderContext, params);

    // 提交命令
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)startRenderLoop {
    // 初始渲染
    [self render];
}

- (void)updateFrame {
    // 手动触发一帧渲染
    [self render];
}

@end
