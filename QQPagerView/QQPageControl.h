//
//  QQPageControl.h
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQPageControl : UIControl

/// default is 0
@property (nonatomic, assign) NSInteger numberOfPages;

/// default is 0. Value is pinned to 0..numberOfPages-1
@property (nonatomic, assign) NSInteger currentPage;

/// 指示器大小
@property (nonatomic, assign) CGFloat itemSpacing;

/// 指示器之间间距
@property (nonatomic, assign) CGFloat interitemSpacing;

/// 内边距
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/// 当 numberOfPages = 1 时，是否隐藏。默认为YES
@property (nonatomic, assign) BOOL hidesForSinglePage;

- (void)setStrokeColor:(nullable UIColor *)strokeColor forState:(UIControlState)state;
- (void)setFillColor:(nullable UIColor *)fillColor forState:(UIControlState)state;
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state;
- (void)setPath:(nullable UIBezierPath *)path forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
