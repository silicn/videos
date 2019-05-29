//
//  ViewController.m
//  AudioDemo
//
//  Created by silicn on 2019/5/27.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "Student.h"

#import "PlayerView.h"

#import "ImagePickViewController.h"



@interface ViewController ()

@property (nonatomic, strong)AVPlayer *player;

@property (nonatomic, strong)AVPlayerLayer *layer;

@property (nonatomic, strong)PlayerView *play;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //https://www.bilibili.com/video/av53328787
//    
////    NSURL *url = [NSURL URLWithString:@"https://www.acfun.cn/v/ac10249894"];
//    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"makeMM.mp4" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path isDirectory:YES];
//
//    self.player = [[AVPlayer alloc]initWithURL:url];
//    
//    self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    
//    self.layer.frame = CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9 /16);
//    
//    self.layer.backgroundColor = [UIColor blackColor].CGColor;
//    
//    [self.view.layer addSublayer:self.layer];
//    
//    [self.player play];
    
    self.play = [[PlayerView alloc]initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9/16)];
    self.play.url = url;
    
    [self.view addSubview:self.play];
    
//    [self.play play];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [btn setTitle:@"开启" forState:UIControlStateNormal];
    
    
    btn.frame = CGRectMake(0, 0, 100, 30);
    
    btn.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(openCamer) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)openCamer
{
    ImagePickViewController *vc = [[ImagePickViewController alloc]init];
    [self.navigationController presentViewController:vc animated:YES completion:NULL];
}


@end
