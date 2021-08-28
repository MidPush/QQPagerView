//
//  QQPageControlJalapeno.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/26.
//

#import "QQPageControlJalapeno.h"

@interface QQPageControlJalapeno ()

@property (nonatomic, assign) CGFloat diameter;
@property (nonatomic, strong) NSMutableArray<QQIndicatorLayer *> *inactive;
@property (nonatomic, strong) QQIndicatorLayer *active;

@property (nonatomic, assign) NSInteger lastPage;

@end

@implementation QQPageControlJalapeno

- (CGFloat)diameter {
    return self.radius * 2;
}

- (NSMutableArray<QQIndicatorLayer *> *)inactive {
    if (!_inactive) {
        _inactive = [NSMutableArray array];
    }
    return _inactive;
}

- (QQIndicatorLayer *)active {
    if (!_active) {
        _active = [QQIndicatorLayer layer];
    }
    return _active;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat floatCount = (CGFloat)self.inactive.count;
    CGFloat x = ceil((self.bounds.size.width - self.diameter * floatCount - self.padding * (floatCount - 1)) * 0.5);
    CGFloat y = ceil((self.bounds.size.height - self.diameter) * 0.5);
    CGRect frame = CGRectMake(x, y, self.diameter, self.diameter);
    
    for (NSInteger index = 0; index < self.inactive.count; index++) {
        QQIndicatorLayer *layer = self.inactive[index];
        layer.backgroundColor = [[self tintColorForPosition:index] colorWithAlphaComponent:self.inactiveTransparency].CGColor;
        if (self.borderWidth > 0) {
            layer.borderWidth = self.borderWidth;
            layer.borderColor = [self tintColorForPosition:index].CGColor;
        }
        layer.cornerRadius = self.radius;
        layer.frame = frame;
        frame.origin.x += (self.diameter + self.padding);
    }
    self.active.fillColor = self.currentPageTintColor ? self.currentPageTintColor.CGColor : self.tintColor.CGColor;
    [self updateForProgress:self.progress];
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.inactive.count * self.diameter + (self.inactive.count - 1) * self.padding, self.diameter);
}

- (void)updateNumberOfPages:(NSInteger)count {
    for (QQIndicatorLayer *layer in self.inactive) {
        [layer removeFromSuperlayer];
    }
    
    for (NSInteger i = 0; i < count; i++) {
        QQIndicatorLayer *layer = [[QQIndicatorLayer alloc] init];
        [self.layer addSublayer:layer];
        [self.inactive addObject:layer];
    }
    [self.layer addSublayer:self.active];
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)updateForProgress:(CGFloat)progress {
    if (self.numberOfPages > 1 && progress >= 0 && progress <= (self.numberOfPages - 1)) {
        
        CGFloat left = self.inactive.firstObject.frame.origin.x;
        CGFloat normalized = progress * (self.diameter + self.padding);
        
        NSInteger currentPage = (NSInteger)progress;
        CGFloat stepSize = (self.diameter + self.padding);
        CGFloat leftX = currentPage * stepSize + left;
        CGFloat rightX = normalized + left;
        CGFloat stepProgress = progress - currentPage;
        
        if (labs(self.lastPage - currentPage) > 1) {
            self.lastPage = currentPage + (self.lastPage > currentPage ? 1 : -1);
        }
        
        CGFloat middleX = normalized;
        if (stepProgress > 0.5) {
            if (self.lastPage > currentPage) {
                rightX = (self.lastPage) * stepSize + left;
                leftX = leftX + ((stepProgress - 0.5) * stepSize * 2);
                middleX = leftX;
            } else {
                leftX = leftX + ((stepProgress - 0.5) * stepSize * 2);
                rightX = (self.currentPage) * stepSize + left;
                middleX = rightX;
            }
        } else if (self.lastPage > currentPage) {
            rightX = (self.lastPage) * stepSize - ((0.5 - stepProgress) * stepSize * 2) + left;
            middleX = leftX;
        } else {
            rightX = rightX + (stepProgress * stepSize);
            middleX = rightX;
        }
        
        CGFloat top = (self.bounds.size.height - self.diameter) * 0.5;
        
        CGPoint point0 = CGPointMake(leftX, self.radius + top);
        CGPoint point1 = CGPointMake(middleX + self.radius, top);
        CGPoint point2 = CGPointMake(rightX + self.radius * 2, self.radius + top);
        CGPoint point3 = CGPointMake(middleX + self.radius, self.radius * 2 + top);
        
        CGFloat offset = self.radius * 0.55;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:point0];
        [path addCurveToPoint:point1 controlPoint1:CGPointMake(point0.x, point0.y - offset) controlPoint2:CGPointMake(point1.x - offset, point1.y)];
        [path addCurveToPoint:point2 controlPoint1:CGPointMake(point1.x + offset, point1.y) controlPoint2:CGPointMake(point2.x, point2.y - offset)];
        [path addCurveToPoint:point3 controlPoint1:CGPointMake(point2.x, point2.y + offset) controlPoint2:CGPointMake(point3.x + offset, point3.y)];
        [path addCurveToPoint:point0 controlPoint1:CGPointMake(point3.x - offset, point3.y) controlPoint2:CGPointMake(point0.x, point0.y + offset)];
        self.active.path = path.CGPath;
        
        if (progress == self.currentPage) {
            self.lastPage = (NSInteger)progress;
        }
        
    }
}


@end
