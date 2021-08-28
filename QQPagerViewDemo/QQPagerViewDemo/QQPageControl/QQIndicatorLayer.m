//
//  QQIndicatorLayer.m
//  万能测试
//
//  Created by Mac on 2021/8/25.
//

#import "QQIndicatorLayer.h"

@implementation QQIndicatorLayer

- (instancetype)init {
    if (self = [super init]) {
        self.actions = @{
            @"bounds":[NSNull null],
            @"frame":[NSNull null],
            @"position":[NSNull null]
        };
    }
    return self;
}

@end
