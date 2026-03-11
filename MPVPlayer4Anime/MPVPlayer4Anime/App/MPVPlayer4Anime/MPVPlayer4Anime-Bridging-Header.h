//
//  MPVPlayer4Anime-Bridging-Header.h
//  MPVPlayer4Anime
//
//  Created on 2025/01/15.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Metal/Metal.h>

// libmpv headers (will be available after building)
#import <mpv/client.h>
#import <mpv/render.h>

@interface MPVPlayerWrapper : NSObject

- (instancetype)initWithView:(UIView *)view;
- (void)loadFile:(NSString *)path;
- (void)play;
- (void)pause;
- (void)stop;
- (void)setShader:(NSString *)shaderPath;

@end
