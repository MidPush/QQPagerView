//
//  QQPagerView.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import "QQPagerView.h"
#import "QQPagerViewLayout.h"
#import "QQPagerCollectionView.h"

NSUInteger const QQPagerViewAutomaticDistance = 0;
CGSize const QQPagerViewAutomaticSize = {0, 0};

@interface QQPagerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) QQPagerViewLayout *layout;
@property (nonatomic, weak) QQPagerCollectionView *collectionView;
@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) NSInteger numberOfSections;

@property (nonatomic, assign) NSInteger dequeingSection;
@property (nonatomic, strong) NSIndexPath *centermostIndexPath; //中心的indexPath
@property (nonatomic, assign) BOOL isPossiblyRotating; //是否旋转
@property (nonatomic, strong) NSIndexPath *possibleTargetingIndexPath;

@end

@implementation QQPagerView

#pragma mark - Public properties

- (void)setScrollDirection:(QQPagerViewScrollDirection)scrollDirection {
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        [self.layout forceInvalidate];
    }
}

- (void)setAutomaticSlidingInterval:(NSTimeInterval)automaticSlidingInterval {
    if (_automaticSlidingInterval != automaticSlidingInterval) {
        _automaticSlidingInterval = automaticSlidingInterval;
        [self cancelTimer];
        if (self.automaticSlidingInterval > 0) {
            [self startTimer];
        }
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    if (_interitemSpacing != interitemSpacing) {
        _interitemSpacing = interitemSpacing;
        [self.layout forceInvalidate];
    }
}

- (void)setItemSize:(CGSize)itemSize {
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
        [self.layout forceInvalidate];
    }
}

- (void)setInfinite:(BOOL)infinite {
    if (_infinite != infinite) {
        _infinite = infinite;
        self.layout.needsReprepare = YES;
        [self.collectionView reloadData];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    self.collectionView.scrollEnabled = scrollEnabled;
}

- (BOOL)scrollEnabled {
    return self.collectionView.scrollEnabled;
}

- (void)setBounces:(BOOL)bounces {
    self.collectionView.bounces = bounces;
}

- (BOOL)bounces {
    return self.collectionView.bounces;
}

- (void)setRemovesInfiniteLoopForSingleItem:(BOOL)removesInfiniteLoopForSingleItem {
    if (_removesInfiniteLoopForSingleItem != removesInfiniteLoopForSingleItem) {
        _removesInfiniteLoopForSingleItem = removesInfiniteLoopForSingleItem;
        [self reloadData];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView {
    _backgroundView = backgroundView;
    if (backgroundView) {
        if (backgroundView.superview) {
            [backgroundView removeFromSuperview];
        }
        [self insertSubview:backgroundView atIndex:0];
        [self setNeedsLayout];
    }
}

- (void)setTransformer:(QQPagerViewTransformer *)transformer {
    _transformer = transformer;
    _transformer.pagerView = self;
    [self.layout forceInvalidate];
}

- (BOOL)isTracking {
    return self.collectionView.isTracking;
}

- (CGFloat)scrollOffset {
    CGFloat contentOffset = MAX(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    CGFloat scrollOffset = (CGFloat)(contentOffset/self.layout.itemSpacing);
    return fmod(scrollOffset, (CGFloat)(self.numberOfItems));
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return self.collectionView.panGestureRecognizer;
}

#pragma mark - Private properties
- (NSIndexPath *)centermostIndexPath {
    if (self.numberOfItems > 0 && !CGSizeEqualToSize(self.collectionView.contentSize, CGSizeZero)) {
        NSIndexPath *mostIndexPath = nil;
        CGFloat diff = CGFLOAT_MAX;
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
            CGRect frame = [self.layout frameForIndexPath:indexPath];
            CGFloat center = 0;
            CGFloat ruler = 0;
            switch (self.scrollDirection) {
                case QQPagerViewScrollDirectionHorizontal: {
                    center = CGRectGetMidX(frame);
                    ruler = CGRectGetMidX(self.collectionView.bounds);
                } break;
                case QQPagerViewScrollDirectionVertical: {
                    center = CGRectGetMidY(frame);
                    ruler = CGRectGetMidY(self.collectionView.bounds);
                } break;
            }
            if (fabs(ruler - center) < diff) {
                diff = fabs(ruler - center);
                mostIndexPath = indexPath;
            }
        }
        if (mostIndexPath) {
            return mostIndexPath;
        }
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (BOOL)isPossiblyRotating {
    NSArray *animationKeys = self.collectionView.layer.animationKeys;
    if (!animationKeys) {
        return NO;
    }
    NSArray *rotationAnimationKeys = @[@"position", @"bounds.origin", @"bounds.size"];
    BOOL contains = NO;
    for (NSString *key in rotationAnimationKeys) {
        if ([animationKeys containsObject:key]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

#pragma mark - Overriden functions
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.collectionView.frame = self.contentView.bounds;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow != nil) {
        [self startTimer];
    } else {
        [self cancelTimer];
    }
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!self.dataSource) {
        return 1;
    }
    self.numberOfItems = [self.dataSource numberOfItemsInPagerView:self];
    if (self.numberOfItems <= 0) {
        return 0;
    }
    if (self.infinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem)) {
        self.numberOfSections = INT16_MAX / self.numberOfItems;
    } else {
        self.numberOfSections = 1;
    }
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.numberOfItems <= 1 && self.removesInfiniteLoopForSingleItem) {
        [self cancelTimer];
    } else if (self.automaticSlidingInterval > 0) {
        [self startTimer];
    }
    return self.numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.dequeingSection = indexPath.section;
    UICollectionViewCell *cell = [self.dataSource pagerView:self cellForItemAtIndex:indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:shouldHighlightItemAtIndex:)]) {
        NSInteger index = indexPath.item % self.numberOfItems;
        return [self.delegate pagerView:self shouldHighlightItemAtIndex:index];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didHighlightItemAtIndex:)]) {
        NSInteger index = indexPath.item % self.numberOfItems;
        [self.delegate pagerView:self didHighlightItemAtIndex:index];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:shouldSelectItemAtIndex:)]) {
        NSInteger index = indexPath.item % self.numberOfItems;
        return [self.delegate pagerView:self shouldSelectItemAtIndex:index];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.possibleTargetingIndexPath = indexPath;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.possibleTargetingIndexPath = nil;
    });
    NSInteger index = indexPath.item % self.numberOfItems;
    [self scrollToItemAtIndex:index animated:YES];
    if ([self.delegate respondsToSelector:@selector(pagerView:didSelectItemAtIndex:)]) {
        [self.delegate pagerView:self didSelectItemAtIndex:index];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:willDisplayCell:forItemAtIndex:)]) {
        NSInteger index = indexPath.item % self.numberOfItems;
        [self.delegate pagerView:self willDisplayCell:cell forItemAtIndex:index];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didEndDisplayingCell:forItemAtIndex:)]) {
        NSInteger index = indexPath.item % self.numberOfItems;
        [self.delegate pagerView:self didEndDisplayingCell:cell forItemAtIndex:index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillBeginDragging:)]) {
        [self.delegate pagerViewWillBeginDragging:self];
    }
    if (self.automaticSlidingInterval > 0) {
        [self cancelTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillEndDragging:targetIndex:)]) {
        CGFloat contentOffset = self.scrollDirection == QQPagerViewScrollDirectionHorizontal ? targetContentOffset->x : targetContentOffset->y;
        NSInteger targetItem = lround((CGFloat)(contentOffset/self.layout.itemSpacing));
        // 当滑动到最后一个 item 时，继续滑动 targetItem 可能等于 numberOfItems，此时取余为0，则 targetIndex=0，如果设置不无限滚动，targetIndex 应该还为 numberOfItems-1 才对
        if (!self.infinite && targetItem >= self.numberOfItems) {
            targetItem = self.numberOfItems - 1;
        }
        [self.delegate pagerViewWillEndDragging:self targetIndex:targetItem % self.numberOfItems];
    }
    if (self.automaticSlidingInterval > 0) {
        [self startTimer];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isPossiblyRotating && self.numberOfItems > 0) {
        // In case someone is using KVO
        NSInteger currentIndex = lround((CGFloat)(self.scrollOffset)) % self.numberOfItems;
        if (currentIndex != self.currentIndex) {
            _currentIndex = currentIndex;
        }
    }
    if ([self.delegate respondsToSelector:@selector(pagerViewDidScroll:)]) {
        [self.delegate pagerViewDidScroll:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(pagerView:didScrollFromIndex:toIndex:progress:)]) {
        NSInteger fromIndex = ((NSInteger)(self.scrollOffset)) % self.numberOfItems;
        NSInteger toIndex = fromIndex;
        if (self.scrollOffset > fromIndex) {
            toIndex = fromIndex + 1;
        } else if (self.scrollOffset < fromIndex) {
            toIndex = fromIndex - 1;
        }
        if (toIndex >= self.numberOfItems) {
            toIndex = 0;
        }
        CGFloat progress = self.scrollOffset - floor(self.scrollOffset);
        [self.delegate pagerView:self didScrollFromIndex:fromIndex toIndex:toIndex progress:progress];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndScrollingAnimation:)]) {
        [self.delegate pagerViewDidEndScrollingAnimation:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(pagerView:didScrollToItemAtIndex:)]) {
        [self.delegate pagerView:self didScrollToItemAtIndex:self.currentIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndDecelerating:)]) {
        [self.delegate pagerViewDidEndDecelerating:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(pagerView:didScrollToItemAtIndex:)]) {
        [self.delegate pagerView:self didScrollToItemAtIndex:self.currentIndex];
    }
}

#pragma mark - Public functions

- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.dequeingSection];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (void)reloadData {
    self.layout.needsReprepare = YES;
    [self.collectionView reloadData];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    UICollectionViewScrollPosition position = self.scrollDirection == QQPagerViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:position];
}

- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < self.numberOfItems) {
        NSIndexPath *indexPath = nil;
        if (self.possibleTargetingIndexPath && self.possibleTargetingIndexPath.item == index) {
            indexPath = self.possibleTargetingIndexPath;
            self.possibleTargetingIndexPath = nil;
        } else {
            if (self.numberOfItems > 1) {
                indexPath = [self nearbyIndexPathForIndex:index];
            } else {
                indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            }
        }
        CGPoint contentOffset = [self.layout contentOffsetForIndexPath:indexPath];
        [self.collectionView setContentOffset:contentOffset animated:animated];
    }
}

- (NSInteger)indexForCell:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath) {
        return indexPath.item;
    }
    return NSNotFound;
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self nearbyIndexPathForIndex:index];
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

// MARK: - Private functions
- (void)commonInit {
    _scrollDirection = QQPagerViewScrollDirectionHorizontal;
    _automaticSlidingInterval = 3.0;
    _interitemSpacing = 0.0;
    _itemSize = QQPagerViewAutomaticSize;
    _infinite = YES;
    _decelerationDistance = 1;
    _removesInfiniteLoopForSingleItem = YES;
    
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    QQPagerViewLayout *layout = [[QQPagerViewLayout alloc] init];
    QQPagerCollectionView *collectionView = [[QQPagerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    self.layout = layout;
    
}

#pragma mark - Timer
- (void)startTimer {
    if (self.automaticSlidingInterval > 0 && self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.automaticSlidingInterval target:self selector:@selector(flipNext) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)flipNext {
    if (self.superview && self.window && self.numberOfItems > 0 && !self.isTracking) {
        CGPoint contentOffset = CGPointZero;
        NSIndexPath *indexPath = self.centermostIndexPath;
        NSInteger section = self.numberOfSections > 1 ? (indexPath.section+(indexPath.item+1)/self.numberOfItems) : 0;
        NSInteger item = (indexPath.item+1) % self.numberOfItems;
        contentOffset = [self.layout contentOffsetForIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
        [self.collectionView setContentOffset:contentOffset animated:YES];
    }
}

- (void)cancelTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (NSIndexPath *)nearbyIndexPathForIndex:(NSInteger)index {
    // Is there a better algorithm?
    NSInteger currentIndex = self.currentIndex;
    NSInteger currentSection = self.centermostIndexPath.section;
    if (labs(currentIndex-index) <= self.numberOfItems/2) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection];
    } else if (index-currentIndex >= 0) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection-1];
    } else {
        return [NSIndexPath indexPathForItem:index inSection:currentSection+1];
    }
}

@end
