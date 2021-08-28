//
//  QQPageControlPaprika.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/27.
//

#import "QQPageControlPaprika.h"

@interface QQPageControlPaprika ()

@property (nonatomic, assign) CGFloat diameter;
@property (nonatomic, strong) NSMutableArray<QQIndicatorLayer *> *inactive;

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, assign) CGRect min;
@property (nonatomic, assign) CGRect max;;

@end

@implementation QQPageControlPaprika

- (CGFloat)diameter {
    return self.radius * 2;
}

- (NSMutableArray<QQIndicatorLayer *> *)inactive {
    if (!_inactive) {
        _inactive = [NSMutableArray array];
    }
    return _inactive;
}

- (NSMutableArray *)frames {
    if (!_frames) {
        _frames = [NSMutableArray array];
    }
    return _frames;
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
    
    [self.frames removeAllObjects];
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
        
        [self.frames addObject:[NSValue valueWithCGRect:layer.frame]];
    }
    
    QQIndicatorLayer *active = self.inactive.firstObject;
    if (active) {
        active.backgroundColor = self.currentPageTintColor ? self.currentPageTintColor.CGColor : self.tintColor.CGColor;
        active.borderWidth = 0;
    }
    
    self.min = self.inactive.firstObject.frame;
    self.max = self.inactive.lastObject.frame;
    
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
        
        CGFloat total = (CGFloat)(self.numberOfPages - 1);
        NSInteger page = (NSInteger)progress;
        for (NSInteger index = 0; index < self.frames.count; index++) {
            if (page > index) {
                self.inactive[index + 1].frame = [self.frames[index] CGRectValue];
            } else if (page < index) {
                self.inactive[index].frame = [self.frames[index] CGRectValue];
            }
        }
        
        CGFloat dist = self.max.origin.x - self.min.origin.x;
        CGFloat percent = (progress / total);
        
        CGFloat offset = dist * percent;
        QQIndicatorLayer *active = self.inactive.firstObject;
        if (!active) return;
        CGRect activeFrame = active.frame;
        
        CGFloat x = self.min.origin.x + offset;
        CGFloat spacePerItem = (dist + self.diameter + self.padding) / (CGFloat)(self.numberOfPages);
        CGFloat r = spacePerItem / 2;
        CGFloat yDirection = (page % 2 == 1) ? 1 : -1;
        activeFrame.origin.x = x;
        CGFloat xBetweenPoints = x - page * spacePerItem - self.min.origin.x;
        CGFloat y = sqrt(pow(r, 2) - pow(fabs(r - xBetweenPoints), 2));
        activeFrame.origin.y = (isnan(y) ? 0 : (y * yDirection)) + self.min.origin.y;
        active.frame = activeFrame;
        
        NSInteger index = page + 1;
        if (index >= self.inactive.count) {
            return;
        }
        
        QQIndicatorLayer *element = self.inactive[index];
        if (index >= self.frames.count) {
            return;
        }
        
        CGRect prev = [self.frames[page] CGRectValue];
        UIColor *prevColor = [self tintColorForPosition:page];
        CGRect current = [self.frames[page + 1] CGRectValue];
        UIColor *currentColor = [self tintColorForPosition:page + 1];
        
        CGFloat elementTotal = current.origin.x - prev.origin.x;
        CGFloat elementProgress = current.origin.x - active.frame.origin.x;
        CGFloat elementPercent = (elementTotal - elementProgress) / elementTotal;
        
        element.borderColor = [self blend:currentColor color2:prevColor progress:elementPercent].CGColor;
        prev.origin.x += elementProgress;
        prev.origin.y = 2 * self.min.origin.y - active.frame.origin.y;
        element.frame = prev;
    }
}


@end
