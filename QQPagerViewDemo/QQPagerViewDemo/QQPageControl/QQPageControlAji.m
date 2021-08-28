//
//  QQPageControlAji.m
//  万能测试
//
//  Created by Mac on 2021/8/25.
//

#import "QQPageControlAji.h"

@interface QQPageControlAji ()

@property (nonatomic, assign) CGFloat diameter;

@property (nonatomic, strong) NSMutableArray<QQIndicatorLayer *> *inactive;
@property (nonatomic, strong) QQIndicatorLayer *active;


@end

@implementation QQPageControlAji

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

- (CGFloat)diameter {
    return self.radius * 2;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat floatCount = (CGFloat)self.inactive.count;
    CGFloat x = ceil((self.bounds.size.width - self.diameter * floatCount - self.padding * (floatCount - 1)) * 0.5);
    CGFloat y = ceil((self.bounds.size.height - self.diameter) * 0.5);
    CGRect frame = CGRectMake(x, y, self.diameter, self.diameter);
    
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
        frame.origin.x += (self.diameter + self.padding);
    }
    
    [self updateForProgress:self.progress];
}

- (void)updateForProgress:(CGFloat)progress {
    CGRect min = self.inactive.firstObject.frame;
    CGRect max = self.inactive.lastObject.frame;
    if (self.numberOfPages > 1 && progress >= 0 && progress <= (self.numberOfPages - 1)) {
        CGFloat total = (CGFloat)(self.numberOfPages - 1);
        CGFloat dist = max.origin.x - min.origin.x;
        CGFloat percent = (CGFloat)(progress / total);
        
        CGFloat offset = dist * percent;
        CGRect activeFrame = self.active.frame;
        activeFrame.origin.x = (min.origin.x + offset);
        self.active.frame = activeFrame;
    }
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeZero];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.inactive.count * self.diameter + (self.inactive.count - 1) * self.padding, self.diameter);
}

@end
