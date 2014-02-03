

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerView ()


@end

@implementation AVPlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
