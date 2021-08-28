//
//  QQBasePageControl.h
//  万能测试
//
//  Created by Mac on 2021/8/25.
//

#import <UIKit/UIKit.h>
#import "QQIndicatorLayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface QQBasePageControl : UIControl

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, strong) NSArray<UIColor *> *tintColors;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat inactiveTransparency;
@property (nonatomic, strong) UIColor *currentPageTintColor;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (UIColor *)tintColorForPosition:(NSInteger)position;
- (void)insertTintColor:(UIColor *)color position:(NSInteger)position;

- (void)updateNumberOfPages:(NSInteger)count;
- (void)updateForProgress:(CGFloat)progress;

- (UIColor *)blend:(UIColor *)color1 color2:(UIColor *)color2 progress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
