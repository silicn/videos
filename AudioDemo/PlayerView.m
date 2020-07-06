//
//  PlayerView.m
//  AudioDemo
//
//  Created by silicn on 2019/5/28.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import "PlayerView.h"

#import <AVFoundation/AVFoundation.h>

@interface PlayerView()

@property (nonatomic, strong)AVPlayer *player;

@property (nonatomic, strong)AVPlayerLayer *playerLayer;


@end

@implementation PlayerView

//- (CALayer *)layer
//{
//    return [AVPlayerLayer playerLayerWithPlayer:self.player];
//}

+(Class)layerClass
{
    return [AVPlayerLayer class];
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
        
        
        UIButton *stop = [UIButton buttonWithType:UIButtonTypeSystem];
        [stop setTitle:@"S" forState:UIControlStateNormal];
        stop.frame = CGRectMake(10, frame.size.height - 20, 20, 20);
        stop.backgroundColor = [UIColor whiteColor];
        
        self.layer.backgroundColor = [UIColor cyanColor].CGColor;
        
        [stop addTarget:self action:@selector(pauseOrplay) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:stop];
        
        UIProgressView *prossess = [[UIProgressView alloc]initWithFrame:CGRectMake(40, frame.size.height - 20 + 10, 200, 20)];
        
        [self addSubview:prossess];
        
        
        
        
        
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.player  && [keyPath isEqualToString:@"status"]) {
        NSLog(@"%@",change);
    }
    
    if (object == self.player && [keyPath isEqualToString:@"timeControlStatus"]) {
        NSLog(@"%@",change);
    }
}

- (void)rePlay
{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    
}

- (void)pauseOrplay
{
    if (@available(iOS 10.0, *)) {
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            [self.player play];
        }else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
            [self.player pause];
        }else if (self.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate){
            [self.player play];
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    if (self.player) {
        AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:url];
        [self.player replaceCurrentItemWithPlayerItem:item];
    }
}

- (void)pause {
   
    if (self.player) {
        [self.player pause];
    }
}



- (void)play
{
    if (self.player) {
        [self.player play];
    }
}

- (AVPlayer *)player
{
    if ([(AVPlayerLayer *)[self layer] player] == nil) {
        ((AVPlayerLayer *)[self layer]).player = [[AVPlayer alloc]init];
    }
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


- (void)dealloc
{
    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
