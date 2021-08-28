//
//  QQPageControl.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import "QQPageControl.h"

@interface QQPageControl ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL needsUpdateIndicators;
@property (nonatomic, assign) BOOL needsCreateIndicators;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *indicatorLayers;

// internal
@property (nonatomic, strong) NSMutableDictionary *strokeColors;
@property (nonatomic, strong) NSMutableDictionary *fillColors;
@property (nonatomic, strong) NSMutableDictionary *paths;
@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, strong) NSMutableDictionary *alphas;
@property (nonatomic, strong) NSMutableDictionary *transforms;

@end

@implementation QQPageControl

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

- (void)commonInit {
    _numberOfPages = 0;
    _currentPage = 0;
    _itemSpacing = 6.0;
    _interitemSpacing = 6.0;
    _contentInsets = UIEdgeInsetsZero;
    _hidesForSinglePage = YES;
    self.userInteractionEnabled = NO;
    
    _indicatorLayers = [NSMutableArray array];
    _strokeColors = [NSMutableDictionary dictionary];
    _fillColors = [NSMutableDictionary dictionary];
    _paths = [NSMutableDictionary dictionary];
    _images = [NSMutableDictionary dictionary];
    _alphas = [NSMutableDictionary dictionary];
    _transforms = [NSMutableDictionary dictionary];

    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, self.frame.size.width - self.contentInsets.left - self.contentInsets.right, self.frame.size.height - self.contentInsets.top - self.contentInsets.bottom);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    CGFloat diameter = self.itemSpacing;
    CGFloat spacing = self.interitemSpacing;
    CGFloat x = 0;
    if (@available(iOS 11.0, *)) {
        if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeading) {
            x = 0;
        } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentFill) {
            CGFloat midX = CGRectGetMidX(self.contentView.bounds);
            CGFloat amplitude = ((CGFloat)self.numberOfPages / 2.0) * diameter + spacing * (CGFloat)(self.numberOfPages - 1) / 2.0;
            x = midX - amplitude;
        } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentTrailing) {
            CGFloat contentWidth = diameter * (CGFloat)(self.numberOfPages) + (CGFloat)(self.numberOfPages - 1) * spacing;
            x = self.contentView.frame.size.width - contentWidth;
        }
    } else {
        if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
            x = 0;
        } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter || self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentFill) {
            CGFloat midX = CGRectGetMidX(self.contentView.bounds);
            CGFloat amplitude = ((CGFloat)self.numberOfPages / 2.0) * diameter + spacing * (CGFloat)(self.numberOfPages - 1) / 2.0;
            x = midX - amplitude;
        } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
            CGFloat contentWidth = diameter * (CGFloat)(self.numberOfPages) + (CGFloat)(self.numberOfPages - 1) * spacing;
            x = self.contentView.frame.size.width - contentWidth;
        }
    }
    
    for (NSInteger i = 0; i < self.indicatorLayers.count; i++) {
        CAShapeLayer *layer = self.indicatorLayers[i];
        UIControlState state = (i == self.currentPage ? UIControlStateSelected : UIControlStateNormal);
        UIImage *image = self.images[@(state)];
        CGSize size = image ? image.size : CGSizeMake(diameter, diameter);
        CGPoint origin = CGPointMake(x - (size.width - diameter) * 0.5, CGRectGetMidY(self.contentView.bounds) - size.height * 0.5);
        layer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        x = x + spacing + diameter;
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state {
    if (self.strokeColors[@(state)] == strokeColor) return;
    self.strokeColors[@(state)] = strokeColor;
    [self setNeedsUpdateIndicators];
}

- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state {
    if (self.fillColors[@(state)] == fillColor) return;
    self.fillColors[@(state)] = fillColor;
    [self setNeedsUpdateIndicators];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.images[@(state)] == image) return;
    self.images[@(state)] = image;
    [self setNeedsUpdateIndicators];
}

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state {
    if ([self.alphas[@(state)] floatValue] == alpha) return;
    self.alphas[@(state)] = @(alpha);
    [self setNeedsUpdateIndicators];
}

- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state {
    if (self.paths[@(state)] == path) return;
    self.paths[@(state)] = path;
    [self setNeedsUpdateIndicators];
}

- (void)createIndicatorsIfNecessary {
    if (!self.needsCreateIndicators) return;
    self.needsCreateIndicators = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.currentPage >= self.numberOfPages) {
        self.currentPage = self.numberOfPages - 1;
    }
    for (CAShapeLayer *layer in self.indicatorLayers) {
        [layer removeFromSuperlayer];
    }
    [self.indicatorLayers removeAllObjects];
    
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.actions = @{@"bounds":[NSNull null]};
        [self.contentView.layer addSublayer:layer];
        [self.indicatorLayers addObject:layer];
    }
    
    [self setNeedsUpdateIndicators];
    
    [CATransaction commit];
}

- (void)updateIndicatorsIfNecessary {
    if (!self.needsUpdateIndicators) return;
    if (self.indicatorLayers.count == 0) return;
    self.needsUpdateIndicators = NO;
    self.contentView.hidden = self.hidesForSinglePage && self.numberOfPages <= 1;
    if (!self.contentView.isHidden) {
        for (CAShapeLayer *layer in self.indicatorLayers) {
            layer.hidden = NO;
            [self updateIndicatorAttributes:layer];
        }
    }
}

- (void)updateIndicatorAttributes:(CAShapeLayer *)layer {
    NSInteger index = [self.indicatorLayers indexOfObject:layer];
    UIControlState state = (index == self.currentPage) ? UIControlStateSelected : UIControlStateNormal;
    UIImage *image = self.images[@(state)];
    if (image) {
        layer.strokeColor = nil;
        layer.fillColor = nil;
        layer.path = nil;
        layer.contents = (__bridge id _Nullable)(image.CGImage);
    } else {
        layer.contents = nil;
        UIColor *strokeColor = self.strokeColors[@(state)];
        UIColor *fillColor = self.fillColors[@(state)];
        if (strokeColor == nil && fillColor == nil) {
            layer.fillColor = (state == UIControlStateSelected ? [UIColor whiteColor].CGColor : [UIColor grayColor].CGColor);
            layer.strokeColor = nil;
        } else {
            layer.strokeColor = strokeColor.CGColor;
            layer.fillColor = fillColor.CGColor;
        }
        UIBezierPath *path = self.paths[@(state)];
        if (path) {
            layer.path = path.CGPath;
        } else {
            layer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.itemSpacing, self.itemSpacing)].CGPath;
        }
        NSValue *transformValue = self.transforms[@(state)];
        if (transformValue) {
            layer.transform = CATransform3DMakeAffineTransform([transformValue CGAffineTransformValue]);
        }
        NSNumber *alphaNumber = self.alphas[@(state)];
        layer.opacity = alphaNumber ? [alphaNumber floatValue] : 1.0;
    }
}

- (void)setNeedsUpdateIndicators {
    self.needsUpdateIndicators = YES;
    [self setNeedsLayout];
    [self updateIndicatorsIfNecessary];
}

- (void)setNeedsCreateIndicators {
    self.needsCreateIndicators = YES;
    [self createIndicatorsIfNecessary];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        [self setNeedsCreateIndicators];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        [self setNeedsUpdateIndicators];
    }
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    if (_itemSpacing != itemSpacing) {
        _itemSpacing = itemSpacing;
        [self setNeedsUpdateIndicators];
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    if (_interitemSpacing != interitemSpacing) {
        _interitemSpacing = interitemSpacing;
        [self setNeedsLayout];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        [self setNeedsLayout];
    }
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    [self setNeedsLayout];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        _hidesForSinglePage = hidesForSinglePage;
        [self setNeedsUpdateIndicators];
    }
}

@end
