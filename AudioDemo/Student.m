//
//  Student.m
//  AudioDemo
//
//  Created by silicn on 2019/5/27.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import "Student.h"

@implementation Student{
    NSString *_sex;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@",[super class]);
        _sex = @"男";
    }
    return self;
}

@end
