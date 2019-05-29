//
//  PlayerView.h
//  AudioDemo
//
//  Created by silicn on 2019/5/28.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerView : UIView

@property (nonatomic, strong)NSURL *url;

- (void)play;

- (void)pause;


@end

NS_ASSUME_NONNULL_END
