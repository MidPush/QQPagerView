//
//  QQPagerCollectionView.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import "QQPagerCollectionView.h"

@implementation QQPagerCollectionView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentInset = UIEdgeInsetsZero;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.scrollsToTop = NO;
    self.pagingEnabled = NO;
    
    if (@available(iOS 10.0, *)) {
        self.prefetchingEnabled = NO;
    }
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:UIEdgeInsetsZero];
    if (contentInset.top > 0) {
        CGPoint contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y+contentInset.top);
        self.contentOffset = contentOffset;
    }
}

@end
