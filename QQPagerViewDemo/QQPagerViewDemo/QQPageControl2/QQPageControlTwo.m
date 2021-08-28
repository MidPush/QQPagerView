//
//  QQPageControlTwo.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/28.
//

#import "QQPageControlTwo.h"


CGFloat const QQPageControlRadius = -1;

@interface QQPageControlTwo ()

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *indicatorLayers;

@end

@implementation QQPageControlTwo

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _numberOfPages = 0;
    _currentPage = 0;
    _hidesForSinglePage = YES;
    _pageIndicatorTintColor = nil;
    _currentPageIndicatorTintColor = nil;
    
    _pageIndicatorSpacing = 10;
    _pageIndicatorSize = CGSizeMake(10, 10);
    _currentPageIndicatorSize = CGSizeMake(10, 10);
    _radius = QQPageControlRadius;
    _currentPageRadius = QQPageControlRadius;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateIndicatorsIfNeeded];
}

#pragma mark - Setters & Getters
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        [self createIndicatorsIfNeeded];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setPage:currentPage animated:NO];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        _hidesForSinglePage = hidesForSinglePage;
        [self updateIndicatorsIfNeeded];
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    if (_pageIndicatorTintColor != pageIndicatorTintColor) {
        _pageIndicatorTintColor = pageIndicatorTintColor;
        [self updateIndicatorsIfNeeded];
    }
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    if (_currentPageIndicatorTintColor != currentPageIndicatorTintColor) {
        _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
        [self updateIndicatorsIfNeeded];
    }
}

- (void)setPageIndicatorSpacing:(CGFloat)pageIndicatorSpacing {
    if (_pageIndicatorSpacing != pageIndicatorSpacing) {
        _pageIndicatorSpacing = pageIndicatorSpacing;
        [self updateIndicatorsIfNeeded];
    }
}

- (void)setPageIndicatorSize:(CGSize)pageIndicatorSize {
    if (!CGSizeEqualToSize(_pageIndicatorSize, pageIndicatorSize)) {
        _pageIndicatorSize = pageIndicatorSize;
        [self updateIndicatorsIfNeeded];
    }
}

- (void)setCurrentPageIndicatorSize:(CGSize)currentPageIndicatorSize {
    if (!CGSizeEqualToSize(_currentPageIndicatorSize, currentPageIndicatorSize)) {
        _currentPageIndicatorSize = currentPageIndicatorSize;
        [self updateIndicatorsIfNeeded];
    }
}

- (void)setIndicatorImage:(UIImage *)image forPage:(NSInteger)page {
    
}

- (void)setPage:(NSInteger)page animated:(BOOL)animated {
    if (_currentPage != page) {
        _currentPage = page;
        [self updateIndicatorsFrameAnimated:animated];
    }
}

- (NSMutableArray<CAShapeLayer *> *)indicatorLayers {
    if (!_indicatorLayers) {
        _indicatorLayers = [NSMutableArray array];
    }
    return _indicatorLayers;
}

#pragma mark - Privates

- (void)createIndicatorsIfNeeded {
    for (CAShapeLayer *layer in self.indicatorLayers) {
        [layer removeFromSuperlayer];
    }
    [self.indicatorLayers removeAllObjects];
    
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        [self.layer addSublayer:layer];
        [self.indicatorLayers addObject:layer];
    }
    
    [self updateIndicatorsIfNeeded];
}

- (void)updateIndicatorsIfNeeded {
    self.hidden = self.hidesForSinglePage && self.numberOfPages <= 1;
    if (self.indicatorLayers.count == 0) return;
    if (!self.isHidden) {
        [self updateIndicatorsFrameAnimated:NO];
    }
}

- (void)updateIndicatorsFrameAnimated:(BOOL)animated {
    
    CAShapeLayer *activeLayer = self.indicatorLayers.firstObject;
    CGSize fitSize = [self fitSize];
    CGFloat firstX = (CGRectGetWidth(self.frame) - fitSize.width) / 2;
    for (NSInteger index = 0; index < self.indicatorLayers.count; index++) {
        CAShapeLayer *layer = self.indicatorLayers[index];
        if (layer == activeLayer) {
            CGRect activeLayerFrame = CGRectMake(firstX + self.currentPage * (_pageIndicatorSize.width + _pageIndicatorSpacing), (CGRectGetHeight(self.frame) - _currentPageIndicatorSize.height) / 2, _currentPageIndicatorSize.width, _currentPageIndicatorSize.height);
            if (animated) {
                [UIView animateWithDuration:0.25 animations:^{
                    activeLayer.frame = activeLayerFrame;
                }];
            } else {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                
                activeLayer.frame = activeLayerFrame;
                
                [CATransaction commit];
            }
            activeLayer.backgroundColor = _currentPageIndicatorTintColor ? _currentPageIndicatorTintColor.CGColor : [UIColor whiteColor].CGColor;
            if (self.currentPageRadius == QQPageControlRadius) {
                activeLayer.cornerRadius = MIN(_currentPageIndicatorSize.width, _currentPageIndicatorSize.height) * 0.5;
            } else {
                activeLayer.cornerRadius = self.currentPageRadius;
            }
        } else {
            CGFloat x = 0;
            if (index > self.currentPage) {
                x = CGRectGetMaxX(activeLayer.frame) + (index - self.currentPage) * (_pageIndicatorSize.width + _pageIndicatorSpacing) - _pageIndicatorSpacing;
            } else {
                x = firstX + (index - 1) * (_pageIndicatorSize.width + _pageIndicatorSpacing);
            }
            
            CGRect layerFrame = CGRectMake(x, (CGRectGetHeight(self.frame) - _pageIndicatorSize.height) / 2, _pageIndicatorSize.width, _pageIndicatorSize.height);
            if (animated) {
                [UIView animateWithDuration:0.25 animations:^{
                    layer.frame = layerFrame;
                }];
            } else {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                
                layer.frame = layerFrame;
                
                [CATransaction commit];
            }
            if (self.radius == QQPageControlRadius) {
                layer.cornerRadius = MIN(_pageIndicatorSize.width, _pageIndicatorSize.height) * 0.5;
            } else {
                layer.cornerRadius = self.radius;
            }
            layer.backgroundColor = _pageIndicatorTintColor ? _pageIndicatorTintColor.CGColor : [UIColor grayColor].CGColor;
        }
    }
}

- (CGSize)fitSize {
    CGFloat count = self.indicatorLayers.count;
    CGSize currentSize = CGSizeMake(MAX(self.pageIndicatorSize.width, self.currentPageIndicatorSize.width), MAX(self.pageIndicatorSize.height, self.currentPageIndicatorSize.height));
    return CGSizeMake((count - 1) * (self.pageIndicatorSize.width + self.pageIndicatorSpacing) + currentSize.width, currentSize.height);
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat count = self.indicatorLayers.count;
    CGSize currentSize = CGSizeMake(MAX(self.pageIndicatorSize.width, self.currentPageIndicatorSize.width), MAX(self.pageIndicatorSize.height, self.currentPageIndicatorSize.height));
    return CGSizeMake((count - 1) * (self.pageIndicatorSize.width + self.pageIndicatorSpacing) + currentSize.width, currentSize.height);
}

@end
