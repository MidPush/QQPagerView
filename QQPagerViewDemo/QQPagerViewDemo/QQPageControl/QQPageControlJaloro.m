//
//  QQPageControlJaloro.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/27.
//

#import "QQPageControlJaloro.h"

@interface QQPageControlJaloro ()

@property (nonatomic, assign) CGFloat diameter;
@property (nonatomic, strong) NSMutableArray<QQIndicatorLayer *> *inactive;
@property (nonatomic, strong) QQIndicatorLayer *active;

@end

@implementation QQPageControlJaloro

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
        _elementWidth = 20;
        _elementHeight = 6;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat floatCount = (CGFloat)self.inactive.count;
    CGFloat x = ceil((self.bounds.size.width - self.elementWidth * floatCount - self.padding * (floatCount - 1)) * 0.5);
    CGFloat y = ceil((self.bounds.size.height - self.elementHeight) * 0.5);
    CGRect frame = CGRectMake(x, y, self.elementWidth, self.elementHeight);
    
    self.active.cornerRadius = self.radius;
    self.active.backgroundColor = self.currentPageTintColor ? self.currentPageTintColor.CGColor : self.tintColor.CGColor;
    self.active.frame = frame;
    
    for (NSInteger index = 0; index < self.inactive.count; index++) {
        QQIndicatorLayer *layer = self.inactive[index];
        layer.backgroundColor = [[self tintColorForPosition:index] colorWithAlphaComponent:self.inactiveTransparency].CGColor;
        if (self.borderWidth > 0) {
            layer.borderWidth = self.borderWidth;
            layer.borderColor = [self tintColorForPosition:index].CGColor;
        }
        layer.cornerRadius = self.radius;
        layer.frame = frame;
        frame.origin.x += (self.elementWidth + self.padding);
    }
    
    [self updateForProgress:self.progress];
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.inactive.count * self.elementWidth + (self.inactive.count - 1) * self.padding, self.elementHeight);
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
        
        CGRect min = self.inactive.firstObject.frame;
        CGRect max = self.inactive.lastObject.frame;
        
        CGFloat total = (CGFloat)(self.numberOfPages - 1);
        CGFloat dist = max.origin.x - min.origin.x;
        CGFloat percent = (progress / total);
        
        CGFloat offset = dist * percent;
        CGRect frame = self.active.frame;
        frame.origin.x = min.origin.x + offset;
        self.active.frame = frame;
    }
}

@end
