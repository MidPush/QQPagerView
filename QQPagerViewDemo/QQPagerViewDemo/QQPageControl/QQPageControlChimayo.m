//
//  QQPageControlChimayo.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/26.
//

#import "QQPageControlChimayo.h"

@interface QQPageControlChimayo ()

@property (nonatomic, assign) CGFloat diameter;
@property (nonatomic, strong) NSMutableArray<QQIndicatorLayer *> *inactive;

@end

@implementation QQPageControlChimayo

- (CGFloat)diameter {
    return self.radius * 2;
}

- (NSMutableArray<QQIndicatorLayer *> *)inactive {
    if (!_inactive) {
        _inactive = [NSMutableArray array];
    }
    return _inactive;
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
        layer.backgroundColor = [self tintColorForPosition:index].CGColor;
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
    
    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

- (void)updateForProgress:(CGFloat)progress {
    if (self.numberOfPages > 1 && progress >= 0 && progress <= (self.numberOfPages - 1)) {
        
        CGRect rect = [self rectInsetBy:CGRectMake(0, 0, self.diameter, self.diameter) dx:1 dy:1];
        
        CGFloat left = floor(progress);
        NSInteger page = (NSInteger)progress;
        CGFloat move = rect.size.width / 2.0;
        
        CGFloat rightInset = move * (progress - left);
        CGRect rightRect = [self rectInsetBy:rect dx:rightInset dy:rightInset];
        
        CGFloat leftInset = (1 - (progress - left)) * move;
        CGRect leftRect = [self rectInsetBy:rect dx:leftInset dy:leftInset];
        
        for (NSInteger i = 0; i < self.inactive.count; i++) {
            QQIndicatorLayer *layer = self.inactive[i];
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.fillRule = kCAFillRuleEvenOdd;
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
            if (i == page) {
                [path appendPath:[UIBezierPath bezierPathWithOvalInRect:leftRect]];
            } else if (i == page + 1) {
                [path appendPath:[UIBezierPath bezierPathWithOvalInRect:rightRect]];
            } else {
                [path appendPath:[UIBezierPath bezierPathWithOvalInRect:rect]];
            }
            mask.path = path.CGPath;
            mask.frame = layer.bounds;
            layer.mask = mask;
        }
    }
}

- (CGRect)rectInsetBy:(CGRect)rect dx:(CGFloat)dx dy:(CGFloat)dy {
    return CGRectMake(rect.origin.x + dx, rect.origin.y + dy, rect.size.width - 2 * dx, rect.size.height - 2 * dy);
}

@end
