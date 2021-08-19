//
//  CustomCellExampleViewController.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/27.
//

#import "CustomCellExampleViewController.h"
#import "QQPagerView.h"
#import "UIColor+QQExtension.h"

@interface CustomPagerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CustomPagerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end

@interface CustomCellExampleViewController ()<QQPagerViewDelegate, QQPagerViewDataSource>
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) QQPagerView *pagerView;
@property (nonatomic, strong) UILabel *textLabel;

@property (strong, nonatomic) NSArray<NSString *> *imageNames;
@property (nonatomic, strong) NSMutableDictionary *imageColorCaches;

@end

@implementation CustomCellExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageColorCaches = [NSMutableDictionary dictionary];
    self.imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg"];
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backgroundView];
    
    _pagerView = [[QQPagerView alloc] init];
    _pagerView.layer.cornerRadius = 10;
    _pagerView.layer.masksToBounds = YES;
    _pagerView.delegate = self;
    _pagerView.dataSource = self;
    _pagerView.automaticSlidingInterval = 2.0;
    _pagerView.infinite = YES;
    [self.view addSubview:_pagerView];
    [_pagerView registerClass:[CustomPagerCell class] forCellWithReuseIdentifier:@"cell"];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.font = [UIFont systemFontOfSize:16];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.text = @"背景随着图片颜色而变化";
    [self.view addSubview:_textLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _backgroundView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, 160);
    _pagerView.frame = CGRectMake(12, CGRectGetMaxY(_backgroundView.frame) - 75, self.view.frame.size.width - 24, 150);
    _textLabel.frame = CGRectMake(10, CGRectGetMaxY(_pagerView.frame) + 30, self.view.frame.size.width - 20, 30);
}

#pragma mark - QQPagerViewDataSource
- (NSInteger)numberOfItemsInPagerView:(QQPagerView *)pagerView {
    return self.imageNames.count;
}

- (UICollectionViewCell *)pagerView:(QQPagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    CustomPagerCell *cell = (CustomPagerCell *)[pagerView dequeueReusableCellWithIdentifier:@"cell" forIndex:index];
    cell.imageView.image = [UIImage imageNamed:self.imageNames[index]];
    if (![self.imageColorCaches objectForKey:@(index)]) {
        [self.imageColorCaches setObject:[self imageAverageColor:cell.imageView.image] forKey:@(index)];
        if (index == 0) {
            self.backgroundView.backgroundColor = [self.imageColorCaches objectForKey:@(index)];
        }
    }
    return cell;
}

#pragma mark - QQPagerViewDelegate
- (void)pagerView:(QQPagerView *)pagerView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    UIColor *fromColor = [self.imageColorCaches objectForKey:@(fromIndex)];
    UIColor *toColor = [self.imageColorCaches objectForKey:@(toIndex)];
    UIColor *backgroundColor = [UIColor qq_colorFromColor:fromColor toColor:toColor progress:progress];
    self.backgroundView.backgroundColor = backgroundColor;
}

#pragma mark - 获取图片平均颜色
- (UIColor *)imageAverageColor:(UIImage *)image {
    unsigned char rgba[4] = {};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (!context) {
        CGColorSpaceRelease(colorSpace);
        return nil;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    if (rgba[3] > 0) {
        return [UIColor colorWithRed:((CGFloat)rgba[0] / rgba[3])
                               green:((CGFloat)rgba[1] / rgba[3])
                                blue:((CGFloat)rgba[2] / rgba[3])
                               alpha:((CGFloat)rgba[3] / 255.0)];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0]) / 255.0
                               green:((CGFloat)rgba[1]) / 255.0
                                blue:((CGFloat)rgba[2]) / 255.0
                               alpha:((CGFloat)rgba[3]) / 255.0];
    }
}

@end
