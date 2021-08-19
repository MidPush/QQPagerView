//
//  QQPagerView.h
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import "QQPagerViewTransformer.h"

NS_ASSUME_NONNULL_BEGIN

extern NSUInteger const QQPagerViewAutomaticDistance;
extern CGSize const QQPagerViewAutomaticSize;

@class QQPagerView;
@protocol QQPagerViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInPagerView:(QQPagerView *)pagerView;
- (__kindof UICollectionViewCell *)pagerView:(QQPagerView *)pagerView cellForItemAtIndex:(NSInteger)index;

@end

@protocol QQPagerViewDelegate <NSObject>

@optional
- (BOOL)pagerView:(QQPagerView *)pagerView shouldHighlightItemAtIndex:(NSInteger)index;

- (void)pagerView:(QQPagerView *)pagerView didHighlightItemAtIndex:(NSInteger)index;

- (BOOL)pagerView:(QQPagerView *)pagerView shouldSelectItemAtIndex:(NSInteger)index;

- (void)pagerView:(QQPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index;

- (void)pagerView:(QQPagerView *)pagerView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index;

- (void)pagerView:(QQPagerView *)pagerView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index;

- (void)pagerViewWillBeginDragging:(QQPagerView *)pagerView;

- (void)pagerViewWillEndDragging:(QQPagerView *)pagerView targetIndex:(NSInteger)targetIndex;

- (void)pagerViewDidScroll:(QQPagerView *)pagerView;

- (void)pagerViewDidEndScrollingAnimation:(QQPagerView *)pagerView;

- (void)pagerViewDidEndDecelerating:(QQPagerView *)pagerView;

- (void)pagerView:(QQPagerView *)pagerView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end

typedef NS_ENUM(NSInteger, QQPagerViewScrollDirection) {
    QQPagerViewScrollDirectionHorizontal,
    QQPagerViewScrollDirectionVertical
};

@interface QQPagerView : UIView

@property (nonatomic, weak) id<QQPagerViewDataSource> dataSource;
@property (nonatomic, weak) id<QQPagerViewDelegate> delegate;

/// 滚动方向，默认为 QQPagerViewScrollDirectionHorizontal
@property (nonatomic, assign) QQPagerViewScrollDirection scrollDirection;

/// 当前 index
@property (nonatomic, assign, readonly) NSInteger currentIndex;

/// 自动滚动时间间隔，默认为3.0，0表示不自动滚动
@property (nonatomic, assign) NSTimeInterval automaticSlidingInterval;

/// 两个 item 间隔，默认为0
@property (nonatomic, assign) CGFloat interitemSpacing;

/// item 大小
@property (nonatomic, assign) CGSize itemSize;

/// 是否开启无限滚动，默认为YES
@property (nonatomic, assign) BOOL infinite;

/// 确定的减速距离，它指示减速期间传递的 item 个数，默认1
@property (nonatomic, assign) NSInteger decelerationDistance;

/// 是否能滚动
@property (nonatomic, assign) BOOL scrollEnabled;

/// 是否有弹簧效果
@property (nonatomic, assign) BOOL bounces;

/// 控制在只有一个 item 时是否删除无限循环，默认YES
@property (nonatomic, assign) BOOL removesInfiniteLoopForSingleItem;

/// 设置背景视图
@property (nonatomic, strong) UIView *backgroundView;

/// Transformer
@property (nonatomic, strong) QQPagerViewTransformer *transformer;

@property (nonatomic, assign, readonly, getter=isTracking) BOOL tracking;
@property (nonatomic, assign, readonly) CGFloat scrollOffset;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndex:(NSInteger)index;

- (void)reloadData;
- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;
- (NSInteger)indexForCell:(__kindof UICollectionViewCell *)cell;
- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
