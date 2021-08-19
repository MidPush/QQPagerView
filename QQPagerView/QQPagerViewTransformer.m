//
//  QQPagerViewTransformer.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/20.
//

#import "QQPagerViewTransformer.h"
#import "QQPagerView.h"

@implementation QQPagerViewTransformer

- (instancetype)initWithType:(QQPagerViewTransformerType)type {
    if (self = [super init]) {
        self.type = type;
        self.minimumScale = 0.65;
        self.minimumAlpha = 0.6;
        if (type == QQPagerViewTransformerTypeZoomOut) {
            self.minimumScale = 0.85;
        } else if (type == QQPagerViewTransformerTypeDepth) {
            self.minimumScale = 0.5;
        }
    }
    return self;
}

- (void)applyTransformToAttributes:(QQPagerViewLayoutAttributes *)attributes {
    if (!_pagerView) return;
    
    CGFloat position = attributes.position;
    QQPagerViewScrollDirection scrollDirection = _pagerView.scrollDirection;
    CGFloat itemSpacing = (scrollDirection == QQPagerViewScrollDirectionHorizontal ? attributes.bounds.size.width : attributes.bounds.size.height) + [self proposedInteritemSpacing];
    
    switch (self.type) {
        case QQPagerViewTransformerTypeCrossFading: {
            NSInteger zIndex = 0;
            CGFloat alpha = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
            switch (scrollDirection) {
                case QQPagerViewScrollDirectionHorizontal:
                    transform.tx = -itemSpacing * position;
                    break;
                case QQPagerViewScrollDirectionVertical:
                    transform.ty = -itemSpacing * position;
                    break;
                default:
                    break;
            }
            if (fabs(position) < 1) { // [-1,1]
                // Use the default slide transition when moving to the left page
                alpha = 1 - fabs(position);
                zIndex = 1;
            } else { // (1,+Infinity]
                // This page is way off-screen to the right.
                alpha = 0;
                zIndex = NSIntegerMin;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;
        } break;
            
        case QQPagerViewTransformerTypeZoomOut: {
            CGFloat alpha = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (position < -1) {
                alpha = 0;
            } else if (position >= -1 && position <= 1) {
                CGFloat scaleFactor = MAX(self.minimumScale, 1 - fabs(position));
                transform.a = scaleFactor;
                transform.d = scaleFactor;
                switch (scrollDirection) {
                    case QQPagerViewScrollDirectionHorizontal: {
                        CGFloat vertMargin = attributes.bounds.size.height * (1 - scaleFactor) / 2;
                        CGFloat horzMargin = itemSpacing * (1 - scaleFactor) / 2;
                        transform.tx = position < 0 ? (horzMargin - vertMargin*2) : (-horzMargin + vertMargin*2);
                    } break;
                    case QQPagerViewScrollDirectionVertical: {
                        CGFloat horzMargin = attributes.bounds.size.width * (1 - scaleFactor) / 2;
                        CGFloat vertMargin = itemSpacing * (1 - scaleFactor) / 2;
                        transform.ty = position < 0 ? (vertMargin - horzMargin*2) : (-vertMargin + horzMargin*2);
                    } break;
                }
                // Fade the page relative to its size.
                alpha = self.minimumAlpha + (scaleFactor-self.minimumScale)/(1-self.minimumScale)*(1-self.minimumAlpha);
            } else if (position > 1) {
                alpha = 0;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
        } break;
            
        case QQPagerViewTransformerTypeDepth: {
            CGFloat alpha = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
            NSInteger zIndex = 0;
            if (position < -1) {
                alpha = 0;
                zIndex = 0;
            } else if (position >= -1 && position <= 0) {
                alpha = 1;
                transform.tx = 0;
                transform.a = 1;
                transform.d = 1;
                zIndex = 1;
            } else if (position > 0 && position < 1) {
                // Fade the page out.
                alpha = (CGFloat)(1.0) - position;
                // Counteract the default slide transition
                switch (scrollDirection) {
                    case QQPagerViewScrollDirectionHorizontal:
                        transform.tx = itemSpacing * -position;
                        break;
                    case QQPagerViewScrollDirectionVertical:
                        transform.ty = itemSpacing * -position;
                        break;
                }
                // Scale the page down (between minimumScale and 1)
                CGFloat scaleFactor = self.minimumScale
                    + (1.0 - self.minimumScale) * (1.0 - fabs(position));
                transform.a = scaleFactor;
                transform.d = scaleFactor;
                zIndex = 0;
            } else if (position >= 1) {
                // This page is way off-screen to the right.
                alpha = 0;
                zIndex = 0;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;
        } break;
            
        case QQPagerViewTransformerTypeOverlap : case QQPagerViewTransformerTypeLinear: {
            if (scrollDirection == QQPagerViewScrollDirectionVertical) {
                // This type doesn't support vertical mode
                return;
            }
            CGFloat scale = MAX(1 - (1-self.minimumScale) * fabs(position), self.minimumScale);
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            attributes.transform = transform;
            CGFloat alpha = (self.minimumAlpha + (1-fabs(position))*(1-self.minimumAlpha));
            attributes.alpha = alpha;
            CGFloat zIndex = (1-fabs(position)) * 10;
            attributes.zIndex = (int)(zIndex);
        } break;
            
        case QQPagerViewTransformerTypeCoverFlow: {
            if (scrollDirection == QQPagerViewScrollDirectionVertical) {
                // This type doesn't support vertical mode
                return;
            }
            CGFloat pos = MIN(MAX(-position,-1) ,1);
            CGFloat rotation = sin(pos*(M_PI)*0.5)*(M_PI)*0.25*1.5;
            CGFloat translationZ = -itemSpacing * 0.5 * fabs(pos);
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -0.002;
            transform3D = CATransform3DRotate(transform3D, rotation, 0, 1, 0);
            transform3D = CATransform3DTranslate(transform3D, 0, 0, translationZ);
            attributes.zIndex = 100 - (int)(fabs(pos));
            attributes.transform3D = transform3D;
        } break;
            
        case QQPagerViewTransformerTypeFerrisWheel : case QQPagerViewTransformerTypeInvertedFerrisWheel: {
            if (scrollDirection == QQPagerViewScrollDirectionVertical) {
                // This type doesn't support vertical mode
                return;
            }
            CGAffineTransform transform = CGAffineTransformIdentity;
            NSInteger zIndex = 0;
            if (position > -5 && position < 5) {
                CGFloat itemSpacing = attributes.bounds.size.width+[self proposedInteritemSpacing];
                CGFloat count = 14;
                CGFloat circle = M_PI * 2.0;
                CGFloat radius = itemSpacing * count / circle;
                CGFloat ty = radius * (self.type == QQPagerViewTransformerTypeInvertedFerrisWheel ? 1 : -1);
                CGFloat theta = circle / count;
                CGFloat rotation = position * theta * (self.type == QQPagerViewTransformerTypeInvertedFerrisWheel ? 1 : -1);
                transform = CGAffineTransformTranslate(transform, -position*itemSpacing, ty);
                transform = CGAffineTransformRotate(transform, rotation);
                transform = CGAffineTransformTranslate(transform, 0, -ty);
                zIndex = (int)((4.0-fabs(position)*10));
            }
            attributes.alpha = fabs(position) < 0.5 ? 1 : self.minimumAlpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;
        } break;
            
        case QQPagerViewTransformerTypeCubic: {
            if (position < -1) {
                attributes.alpha = 0;
            } else if (position >= -1 && position < 1) {
                attributes.alpha = 1;
                attributes.zIndex = (int)((1-position) * (CGFloat)(10));
                CGFloat direction = position < 0 ? 1 : -1;
                CGFloat theta = position * M_PI * 0.5 * (scrollDirection == QQPagerViewScrollDirectionHorizontal ? 1 : -1);
                CGFloat radius = scrollDirection == QQPagerViewScrollDirectionHorizontal ? attributes.bounds.size.width : attributes.bounds.size.height;
                CATransform3D transform3D = CATransform3DIdentity;
                transform3D.m34 = -0.002;
                switch (scrollDirection) {
                    case QQPagerViewScrollDirectionHorizontal: {
                        // ForwardX -> RotateY -> BackwardX
                        CGFloat x = attributes.center.x;
                        x += direction*radius*0.5; // ForwardX
                        attributes.center = CGPointMake(x, attributes.center.y); // ForwardX
                        transform3D = CATransform3DRotate(transform3D, theta, 0, 1, 0); // RotateY
                        transform3D = CATransform3DTranslate(transform3D,-direction*radius*0.5, 0, 0); // BackwardX
                    } break;
                    case QQPagerViewScrollDirectionVertical: {
                        // ForwardY -> RotateX -> BackwardY
                        CGFloat y = attributes.center.y;
                        y += direction*radius*0.5;
                        attributes.center = CGPointMake(attributes.center.x, y); // ForwardY
                        transform3D = CATransform3DRotate(transform3D, theta, 1, 0, 0); // RotateX
                        transform3D = CATransform3DTranslate(transform3D,0, -direction*radius*0.5, 0); // BackwardY
                    } break;
                }
                attributes.transform3D = transform3D;
            } else if (position >= 1) {
                attributes.alpha = 0;
            } else {
                attributes.alpha = 0;
                attributes.zIndex = 0;
            }
        } break;
    }
}

- (CGFloat)proposedInteritemSpacing {
    QQPagerView *pagerView = _pagerView;
    if (!pagerView) {
        return 0;
    }
    QQPagerViewScrollDirection scrollDirection = pagerView.scrollDirection;
    
    if (self.type == QQPagerViewTransformerTypeOverlap) {
        if (scrollDirection == QQPagerViewScrollDirectionHorizontal) {
            return pagerView.itemSize.width * -self.minimumScale * 0.6;
        }
        return 0;
    } else if (self.type == QQPagerViewTransformerTypeLinear) {
        if (scrollDirection == QQPagerViewScrollDirectionHorizontal) {
            return pagerView.itemSize.width * -self.minimumScale * 0.2;
        }
        return 0;
    } else if (self.type == QQPagerViewTransformerTypeCoverFlow) {
        if (scrollDirection == QQPagerViewScrollDirectionHorizontal) {
            return -pagerView.itemSize.width * sin(M_PI * 0.25 * 0.25 * 3.0);
        }
        return 0;
    } else if (self.type == QQPagerViewTransformerTypeFerrisWheel || self.type == QQPagerViewTransformerTypeInvertedFerrisWheel) {
        if (scrollDirection == QQPagerViewScrollDirectionHorizontal) {
            return -pagerView.itemSize.width * 0.15;
        }
        return 0;
    } else if (self.type == QQPagerViewTransformerTypeCubic) {
        return 0;
    }
    return pagerView.interitemSpacing;
}

@end
