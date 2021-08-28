//
//  QQPageControlTwo.h
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQPageControlTwo : UIControl

/// default is 0
@property (nonatomic, assign) NSInteger numberOfPages;

/// default is 0. Value is pinned to 0..numberOfPages-1
@property (nonatomic, assign) NSInteger currentPage;

/// hides the indicator if there is only one page, default is NO
@property (nonatomic, assign) BOOL hidesForSinglePage;

/// The tint color for non-selected indicators. Default is nil.
@property (nullable, nonatomic, strong) UIColor *pageIndicatorTintColor;

/// The tint color for the currently-selected indicators. Default is nil.
@property (nullable, nonatomic, strong) UIColor *currentPageIndicatorTintColor;

///
@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, assign) CGFloat currentPageRadius;

/// 指示器之间的间隙
@property (nonatomic, assign) CGFloat pageIndicatorSpacing;

///
@property (nonatomic, assign) CGSize pageIndicatorSize;

///
@property (nonatomic, assign) CGSize currentPageIndicatorSize;

- (void)setIndicatorImage:(nullable UIImage *)image forPage:(NSInteger)page;
- (void)setPage:(NSInteger)page animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
