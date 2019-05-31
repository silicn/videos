//
//  NSArray+Safey.m
//  AudioDemo
//
//  Created by silicn on 2019/5/30.
//  Copyright © 2019 SILICN. All rights reserved.
//

#import "NSArray+Safey.h"
#import "objc/message.h"


@implementation NSArray (Safey)

+ (void)load
{

    [self exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayI") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_objectAtIndex:)];
    
    [self exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArray0") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_ZeroObjectAtIndex:)];
    
    [self exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSSingleObjectArrayI") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_signleObjectAtIndex:)];
    
    
    
}

+ (void)exchangeInstanceMethodWithSelfClass:(Class)selfClass
                           originalSelector:(SEL)originalSelector
                           swizzledSelector:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(selfClass, swizzledSelector);
    BOOL didAddMethod = class_addMethod(selfClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(selfClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



- (id)safe_objectAtIndex:(NSUInteger)index
{
    if (index < [self count]) {
        return [self safe_objectAtIndex:index];
    }else{
        NSLog(@"数组越界:%@",self);
    }
    return nil;
}

- (id)safe_ZeroObjectAtIndex:(NSUInteger)index
{
    if (index < [self count]) {
        return [self safe_ZeroObjectAtIndex:index];
    }else{
        NSLog(@"数组越界:%@",self);
    }
    return nil;
}

- (id)safe_signleObjectAtIndex:(NSUInteger)index
{
    if (index < [self count]) {
        return [self safe_signleObjectAtIndex:index];
    }else{
        NSLog(@"数组越界:%@",self);
    }
    return nil;
}




@end
