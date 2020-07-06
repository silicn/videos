//
//  Person.m
//  AudioDemo
//
//  Created by silicn on 2019/5/27.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import "Person.h"


@implementation Person

@synthesize name = _name;

- (Class)class
{
    NSLog(@"Person");
    return [super class];
}


- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)name
{
    _name = name;
}

@end
