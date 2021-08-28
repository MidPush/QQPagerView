//
//  QQBasePageControl.m
//  万能测试
//
//  Created by Mac on 2021/8/25.
//

#import "QQBasePageControl.h"

@interface WeakProxy : NSObject

@property (nonatomic, weak) id target;

@end

@implementation WeakProxy

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        self.target = target;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (self.target) {
        return [self.target respondsToSelector:aSelector];
    }
    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}

@end

@interface QQBasePageControl ()

@property (nonatomic, assign) CGFloat moveToProgress;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray *tintColorArray;

@end

@implementation QQBasePageControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _numberOfPages = 0;
    _progress = 0.0;
    _padding = 5.0;
    _radius = 5;
    _inactiveTransparency = 0.4;
    _hidesForSinglePage = YES;
    _borderWidth = 0;
}

- (void)setupDisplayLink {
    if (!self.displayLink) {
        WeakProxy *weakSelf = [[WeakProxy alloc] initWithTarget:self];
        self.displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(updateFrame)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)invalidateDisplayLink {
    if (self.displayLink) {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)updateFrame {
    [self animate];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (progress < 0 || progress > (_numberOfPages - 1)) return;
    if (animated) {
        self.moveToProgress = progress;
        [self setupDisplayLink];
    } else {
        self.progress = progress;
    }
}

- (UIColor *)tintColorForPosition:(NSInteger)position {
    if (position < 0 || position > (_numberOfPages - 1)) return self.tintColor;
    if (_tintColorArray.count < _numberOfPages) {
        return self.tintColor;
    } else {
        return _tintColorArray[position];
    }
}

- (void)insertTintColor:(UIColor *)color position:(NSInteger)position {
    if (_tintColorArray.count < _numberOfPages) {
        [self setupTintColors];
    }
    _tintColorArray[position] = color;
}

- (void)setupTintColors {
    if (!self.tintColor) return;
    _tintColorArray = [NSMutableArray array];
    for (NSInteger i = 0; i < _numberOfPages; i++) {
        [_tintColorArray addObject:self.tintColor];
    }
}

- (void)populateTintColors {
    if (_tintColorArray.count > 0) {
        if (_tintColorArray.count > _numberOfPages) {
            _tintColorArray = [[_tintColorArray subarrayWithRange:NSMakeRange(0, _numberOfPages)] mutableCopy];
        } else if (_tintColorArray.count < _numberOfPages) {
            if (self.tintColor) {
                for (NSInteger i = 0; i < _numberOfPages - _tintColorArray.count; i++) {
                    [_tintColorArray addObject:self.tintColor];
                }
            }
        }
    }
}

- (void)updateNumberOfPages:(NSInteger)count {
    
}

- (void)updateForProgress:(CGFloat)progress {
    
}


- (void)animate {
    float a = fabs(_moveToProgress);
    float b = fabs(_progress);
    
    if (a > b) {
        self.progress += 0.1;
    }
    if (a < b) {
        self.progress -= 0.1;
    }
    
    if (a == b) {
        self.progress = _moveToProgress;
        self.moveToProgress = -1;
        [self invalidateDisplayLink];
    }
    
    if (self.progress < 0) {
        self.progress = 0;
        self.moveToProgress = -1;
        [self invalidateDisplayLink];
    }
    
    if (self.progress > (CGFloat)(_numberOfPages - 1)) {
        self.progress = (CGFloat)(_numberOfPages - 1);
        self.moveToProgress = -1;
        [self invalidateDisplayLink];
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        [self populateTintColors];
        [self updateNumberOfPages:numberOfPages];
        self.hidden = self.hidesForSinglePage && numberOfPages <= 1;
    }
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = progress;
        [self updateForProgress:progress];
    }
}

- (NSInteger)currentPage {
    return lround(self.progress);
}

- (void)setPadding:(CGFloat)padding {
    if (_padding != padding) {
        _padding = padding;
        [self setNeedsLayout];
        [self updateForProgress:self.progress];
    }
}

- (void)setRadius:(CGFloat)radius {
    if (_radius != radius) {
        _radius = radius;
        [self setNeedsLayout];
        [self updateForProgress:self.progress];
    }
}

- (void)setInactiveTransparency:(CGFloat)inactiveTransparency {
    if (_inactiveTransparency != inactiveTransparency) {
        _inactiveTransparency = inactiveTransparency;
        [self setNeedsLayout];
        [self updateForProgress:self.progress];
    }
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    if (_hidesForSinglePage != hidesForSinglePage) {
        [self setNeedsLayout];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth != borderWidth) {
        _borderWidth = borderWidth;
        [self setNeedsLayout];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self setNeedsLayout];
}

- (void)setTintColors:(NSArray<UIColor *> *)tintColors {
    _tintColorArray = [tintColors mutableCopy];
    if (tintColors.count == _numberOfPages) {
        [self setNeedsLayout];
    }
}

- (NSArray<UIColor *> *)tintColors {
    return [_tintColorArray copy];
}

- (void)setCurrentPageTintColor:(UIColor *)currentPageTintColor {
    _currentPageTintColor = currentPageTintColor;
    [self setNeedsLayout];
}

- (void)dealloc {
    [self invalidateDisplayLink];
}

- (UIColor *)blend:(UIColor *)color1 color2:(UIColor *)color2 progress:(CGFloat)progress {
    CGFloat l1 = 1 - progress;
    CGFloat l2 = progress;
    CGFloat r1, g1, b1, a1;
    CGFloat r2, g2, b2, a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color1 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return [UIColor colorWithRed:l1*r1 + l2*r2 green:l1*g1 + l2*g2 blue:l1*b1 + l2*b2 alpha:l1*a1 + l2*a2];
}

@end
