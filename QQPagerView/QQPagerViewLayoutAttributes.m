//
//  QQPagerViewLayoutAttributes.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import "QQPagerViewLayoutAttributes.h"

@implementation QQPagerViewLayoutAttributes

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[QQPagerViewLayoutAttributes class]]) {
        return NO;
    }
    QQPagerViewLayoutAttributes *attributes = (QQPagerViewLayoutAttributes *)object;
    BOOL equal = [super isEqual:object];
    equal = equal && self.position == attributes.position;
    return equal;
}

- (id)copyWithZone:(NSZone *)zone {
    QQPagerViewLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.position = self.position;
    return attributes;
}

@end
