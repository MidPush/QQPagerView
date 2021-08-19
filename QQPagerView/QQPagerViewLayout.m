//
//  QQPagerViewLayout.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import "QQPagerViewLayout.h"
#import "QQPagerViewLayoutAttributes.h"

@interface QQPagerViewLayout ()

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGFloat leadingSpacing;
@property (nonatomic, assign) QQPagerViewScrollDirection scrollDirection;

@property (nonatomic, strong) QQPagerView *pagerView;

@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) NSInteger numberOfSections;
@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) CGFloat actualInteritemSpacing;
@property (nonatomic, assign) CGSize actualItemSize;

@end

@implementation QQPagerViewLayout

+ (Class)layoutAttributesClass {
    return [QQPagerViewLayoutAttributes class];
}

- (QQPagerView *)pagerView {
    UIView *pagerView = self.collectionView.superview.superview;
    if ([pagerView isKindOfClass:[QQPagerView class]]) {
        return (QQPagerView *)pagerView;
    }
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)prepareLayout {
    UICollectionView *collectionView = self.collectionView;
    QQPagerView *pagerView = self.pagerView;
    if (!collectionView || !pagerView) {
        return;
    }
    
    if (!self.needsReprepare && CGSizeEqualToSize(self.collectionViewSize, collectionView.frame.size) ) {
        return;
    }
    
    self.needsReprepare = NO;
    self.collectionViewSize = collectionView.frame.size;
    
    self.numberOfSections = [collectionView.dataSource numberOfSectionsInCollectionView:collectionView];
    self.numberOfItems = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:0];
    self.actualItemSize = pagerView.itemSize;
    if (CGSizeEqualToSize(self.actualItemSize, CGSizeZero)) {
        self.actualItemSize = collectionView.frame.size;
    }
    
    if (pagerView.transformer) {
        self.actualInteritemSpacing = [pagerView.transformer proposedInteritemSpacing];
    } else {
        self.actualInteritemSpacing = pagerView.interitemSpacing;
    }
    
    self.scrollDirection = pagerView.scrollDirection;
    self.leadingSpacing = self.scrollDirection == QQPagerViewScrollDirectionHorizontal ? (collectionView.frame.size.width-self.actualItemSize.width)*0.5 : (collectionView.frame.size.height-self.actualItemSize.height)*0.5;
    self.itemSpacing = (self.scrollDirection == QQPagerViewScrollDirectionHorizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing;
    
    // 计算并缓存contentSize，而不是每次都计算
    NSInteger numberOfItems = self.numberOfItems * self.numberOfSections;
    switch (self.scrollDirection) {
        case QQPagerViewScrollDirectionHorizontal: {
            CGFloat contentSizeWidth = self.leadingSpacing * 2;
            contentSizeWidth += (CGFloat)(numberOfItems - 1) * self.actualInteritemSpacing;
            contentSizeWidth += (CGFloat)(numberOfItems) * self.actualItemSize.width;
            CGSize contentSize = CGSizeMake(contentSizeWidth, collectionView.frame.size.height);
            self.contentSize = contentSize;
        } break;
            
        case QQPagerViewScrollDirectionVertical: {
            CGFloat contentSizeHeight = self.leadingSpacing * 2;
            contentSizeHeight += (CGFloat)(numberOfItems - 1) * self.actualInteritemSpacing;
            contentSizeHeight += (CGFloat)(numberOfItems) * self.actualItemSize.height;
            CGSize contentSize = CGSizeMake(collectionView.frame.size.width, contentSizeHeight);
            self.contentSize = contentSize;
        } break;
            
        default:
            break;
    }
    
    [self adjustCollectionViewBounds];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    if (self.itemSpacing <= 0 || CGRectIsEmpty(rect)) {
        return layoutAttributes;
    }
    
    rect = CGRectIntersection(rect, CGRectMake(0, 0, self.contentSize.width, self.contentSize.height));
    if (CGRectIsEmpty(rect)) {
        return layoutAttributes;
    }
    
    // 计算某些矩形的起始位置和索引
    NSInteger numberOfItemsBefore = self.scrollDirection == QQPagerViewScrollDirectionHorizontal ? MAX((int)((CGRectGetMinX(rect)-self.leadingSpacing)/self.itemSpacing),0) : MAX((int)((CGRectGetMinY(rect)-self.leadingSpacing)/self.itemSpacing),0);
    
    CGFloat startPosition = self.leadingSpacing + (CGFloat)(numberOfItemsBefore)*self.itemSpacing;
    NSInteger startIndex = numberOfItemsBefore;
    
    NSInteger itemIndex = startIndex;
    CGFloat origin = startPosition;
    CGFloat maxPosition = self.scrollDirection == QQPagerViewScrollDirectionHorizontal ? MIN(CGRectGetMaxX(rect),self.contentSize.width-self.actualItemSize.width-self.leadingSpacing) : MIN(CGRectGetMaxY(rect),self.contentSize.height-self.actualItemSize.height-self.leadingSpacing);
    while (origin - maxPosition <= FLT_EPSILON) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex%self.numberOfItems inSection:itemIndex/self.numberOfItems];
        QQPagerViewLayoutAttributes *attributes = (QQPagerViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
        [self applyTransformToAttributes:attributes transformer:self.pagerView.transformer];
        [layoutAttributes addObject:attributes];
        itemIndex += 1;
        origin += self.itemSpacing;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    QQPagerViewLayoutAttributes *attributes = [QQPagerViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.indexPath = indexPath;
    CGRect frame = [self frameForIndexPath:indexPath];
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    attributes.center = center;
    attributes.size = self.actualItemSize;
    return attributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    UICollectionView *collectionView = self.collectionView;
    QQPagerView *pagerView = self.pagerView;
    if (!collectionView || !pagerView) {
        return proposedContentOffset;
    }
    CGPoint contentOffset = proposedContentOffset;
    CGFloat proposedContentOffsetX = 0;
    if (self.scrollDirection == QQPagerViewScrollDirectionVertical) {
        proposedContentOffsetX = contentOffset.x;
    } else {
        CGFloat boundedOffset = collectionView.contentSize.width-self.itemSpacing;
        proposedContentOffsetX = [self calculateTargetOffset:contentOffset.x boundedOffset:boundedOffset velocity:velocity];
    }
    
    CGFloat proposedContentOffsetY = 0;
    if (self.scrollDirection == QQPagerViewScrollDirectionHorizontal) {
        proposedContentOffsetY = contentOffset.y;
    } else {
        CGFloat boundedOffset = collectionView.contentSize.height-self.itemSpacing;
        proposedContentOffsetY = [self calculateTargetOffset:contentOffset.y boundedOffset:boundedOffset velocity:velocity];
    }
    contentOffset = CGPointMake(proposedContentOffsetX, proposedContentOffsetY);
    return contentOffset;
}

- (CGFloat)calculateTargetOffset:(CGFloat)proposedOffset boundedOffset:(CGFloat)boundedOffset velocity:(CGPoint)velocity {
    CGFloat targetOffset = 0;
    if (self.pagerView.decelerationDistance == QQPagerViewAutomaticDistance) {
        if (fabs(velocity.x) >= 0.3) {
            CGFloat vector = velocity.x >= 0 ? 1.0 : -1.0;
            targetOffset = round(proposedOffset/self.itemSpacing+0.35*vector) * self.itemSpacing;
        } else {
            targetOffset = round(proposedOffset/self.itemSpacing) * self.itemSpacing;
        }
    } else {
        CGFloat extraDistance = MAX(self.pagerView.decelerationDistance - 1, 0);
        if (velocity.x > 0.3) {
            targetOffset = ceil(self.collectionView.contentOffset.x/self.itemSpacing+(CGFloat)(extraDistance)) * self.itemSpacing;
        } else if (velocity.x < -0.3) {
            targetOffset = floor(self.collectionView.contentOffset.x/self.itemSpacing-(CGFloat)(extraDistance)) * self.itemSpacing;
        } else {
            targetOffset = round(proposedOffset/self.itemSpacing) * self.itemSpacing;
        }
    }
    targetOffset = MAX(0, targetOffset);
    targetOffset = MIN(boundedOffset, targetOffset);
    return targetOffset;
}

// MARK:- Internal functions
- (void)forceInvalidate {
    self.needsReprepare = YES;
    [self invalidateLayout];
}

- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath {
    CGPoint origin = [self frameForIndexPath:indexPath].origin;
    UICollectionView *collectionView = self.collectionView;
    if (!collectionView) {
        return origin;
    }
    CGFloat contentOffsetX = 0;
    if (self.scrollDirection == QQPagerViewScrollDirectionVertical) {
        contentOffsetX = 0;
    } else {
        contentOffsetX = origin.x - (collectionView.frame.size.width*0.5-self.actualItemSize.width*0.5);
    }
    
    CGFloat contentOffsetY = 0;
    if (self.scrollDirection == QQPagerViewScrollDirectionHorizontal) {
        contentOffsetY = 0;
    } else {
        contentOffsetY = origin.y - (collectionView.frame.size.height*0.5-self.actualItemSize.height*0.5);
    }
    return CGPointMake(contentOffsetX, contentOffsetY);
}

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = self.numberOfItems * indexPath.section + indexPath.item;
    CGFloat originX = 0;
    if (self.scrollDirection == QQPagerViewScrollDirectionVertical) {
        originX = (self.collectionView.frame.size.width - self.actualItemSize.width)*0.5;
    } else {
        originX = self.leadingSpacing + (CGFloat)numberOfItems * self.itemSpacing;
    }
    
    CGFloat originY = 0;
    if (self.scrollDirection == QQPagerViewScrollDirectionHorizontal) {
        originY = (self.collectionView.frame.size.height-self.actualItemSize.height)*0.5;
    } else {
        originY = self.leadingSpacing + (CGFloat)numberOfItems * self.itemSpacing;
    }
    return CGRectMake(originX, originY, self.actualItemSize.width, self.actualItemSize.height);
}

// MARK:- Notification
- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    if (CGSizeEqualToSize(self.pagerView.itemSize, CGSizeZero)) {
        [self adjustCollectionViewBounds];
    }
}

// MARK:- Private functions
- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)adjustCollectionViewBounds {
    UICollectionView *collectionView = self.collectionView;
    QQPagerView *pagerView = self.pagerView;
    if (!collectionView || !pagerView) {
        return;
    }
    NSInteger currentIndex= pagerView.currentIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentIndex inSection:pagerView.infinite ? self.numberOfSections/2 : 0];
    CGPoint contentOffset = [self contentOffsetForIndexPath:indexPath];
    CGRect newBounds = CGRectMake(contentOffset.x, contentOffset.y, collectionView.frame.size.width, collectionView.frame.size.height);
    collectionView.bounds = newBounds;
}

- (void)applyTransformToAttributes:(QQPagerViewLayoutAttributes *)attributes transformer:(QQPagerViewTransformer *)transformer {
    if (!transformer) {
        return;
    }
    UICollectionView *collectionView = self.collectionView;
    if (!collectionView) {
        return;
    }
    switch (self.scrollDirection) {
        case QQPagerViewScrollDirectionHorizontal: {
            CGFloat ruler = CGRectGetMidX(collectionView.bounds);
            attributes.position = (attributes.center.x-ruler)/self.itemSpacing;
        } break;
        case QQPagerViewScrollDirectionVertical: {
            CGFloat ruler = CGRectGetMidX(collectionView.bounds);
            attributes.position = (attributes.center.y-ruler)/self.itemSpacing;
        } break;
        default:
            break;
    }
    attributes.zIndex = (int)(self.numberOfItems)-(int)(attributes.position);
    [transformer applyTransformToAttributes:attributes];
}

@end
