//
//  UIColor+QQExtension.h
//  NNKit
//
//  Created by Mac on 2021/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (QQExtension)

/**
 16进制字符串转颜色
 */
+ (nullable UIColor *)qq_colorWithHexString:(NSString *)hexString;

/**
 传入数组，[R, G, B] => [0, 0, 255] ，取值范围 0~255.0
 */
+ (nullable UIColor *)qq_colorWithRGB:(NSArray<NSNumber *> *)rgb;

/**
 传入数组，[R, G, B, A] => [0, 0, 255, 1.0] ，RGB取值范围 0~255.0，A取值范围 0~1.0
 */
+ (nullable UIColor *)qq_colorWithRGBA:(NSArray<NSNumber *> *)rgba;

/**
 *  将颜色A变化到颜色B，可通过progress控制变化的程度
 *  @param fromColor 起始颜色
 *  @param toColor 目标颜色
 *  @param progress 变化程度，取值范围0.0f~1.0f
 */
+ (nullable UIColor *)qq_colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress;

/**
 将当前色值 RGB 转换为hex字符串，不包含 alpha
 例如：0066bb
 */
@property (nonatomic, copy, readonly) NSString *qq_hexString;

/**
 将当前色值 RGBA 转换为hex字符串，包含 alpha
 例如：0066bbff
 */
@property (nonatomic, copy, readonly) NSString *qq_hexStringWithAlpha;

/**
 颜色在RGB颜色空间中的红色分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_red;

/**
 颜色在RGB颜色空间中的绿色分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_green;

/**
 颜色在RGB颜色空间中的蓝色分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_blue;

/**
 颜色在RGB颜色空间中的透明度分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_alpha;

/**
 颜色在HSB颜色空间中的色调分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_hue;

/**
 颜色在HSB颜色空间中的饱和度分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_saturation;

/**
 颜色在HSB颜色空间中的亮度分量值，范围 0.0 ~ 1.0
 */
@property (nonatomic, assign, readonly) CGFloat qq_brightness;

/**
 *  产生一个随机色，大部分情况下用于测试
 */
+ (UIColor *)qq_randomColor;

@end

NS_ASSUME_NONNULL_END
