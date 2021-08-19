//
//  QQPagerViewTransformer.h
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import "QQPagerViewLayoutAttributes.h"

NS_ASSUME_NONNULL_BEGIN

@class QQPagerView;

typedef NS_ENUM(NSInteger, QQPagerViewTransformerType) {
    QQPagerViewTransformerTypeCrossFading,
    QQPagerViewTransformerTypeZoomOut,
    QQPagerViewTransformerTypeDepth,
    QQPagerViewTransformerTypeOverlap,
    QQPagerViewTransformerTypeLinear,
    QQPagerViewTransformerTypeCoverFlow,
    QQPagerViewTransformerTypeFerrisWheel,
    QQPagerViewTransformerTypeInvertedFerrisWheel,
    QQPagerViewTransformerTypeCubic
};

@interface QQPagerViewTransformer : NSObject

- (instancetype)initWithType:(QQPagerViewTransformerType)type;

@property (nonatomic, weak) QQPagerView *pagerView;
@property (nonatomic, assign) QQPagerViewTransformerType type;

@property (nonatomic, assign) CGFloat minimumScale;
@property (nonatomic, assign) CGFloat minimumAlpha;

- (CGFloat)proposedInteritemSpacing;
- (void)applyTransformToAttributes:(QQPagerViewLayoutAttributes *)attributes;

@end

NS_ASSUME_NONNULL_END
