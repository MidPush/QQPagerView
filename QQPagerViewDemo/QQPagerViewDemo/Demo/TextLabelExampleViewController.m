//
//  TextLabelExampleViewController.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/27.
//

#import "TextLabelExampleViewController.h"
#import "QQPagerView.h"
#import "QQPagerViewCell.h"

@interface TextLabelExampleViewController ()<QQPagerViewDelegate, QQPagerViewDataSource>

@property (nonatomic, strong) QQPagerView *pagerView;
@property (strong, nonatomic) NSArray<NSString *> *titles;

@end

@implementation TextLabelExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titles = @[
        @"1、#张家齐陈芋汐双人10米跳台夺冠#",
        @"2、微信暂停个人帐号新用户注册",
        @"3、主火炬手大坂直美爆冷出局",
        @"4、台风烟花过境后千米江堤变垃圾堆场"
    ];
    
    _pagerView = [[QQPagerView alloc] init];
    _pagerView.delegate = self;
    _pagerView.dataSource = self;
    _pagerView.scrollDirection = QQPagerViewScrollDirectionVertical;
    _pagerView.automaticSlidingInterval = 2.0;
    _pagerView.infinite = YES;
    _pagerView.scrollEnabled = NO;
    _pagerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_pagerView];
    [_pagerView registerClass:[QQPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pagerView.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, 30);
}

#pragma mark - QQPagerViewDataSource
- (NSInteger)numberOfItemsInPagerView:(QQPagerView *)pagerView {
    return self.titles.count;
}

- (UICollectionViewCell *)pagerView:(QQPagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    QQPagerViewCell *cell = [pagerView dequeueReusableCellWithIdentifier:@"cell" forIndex:index];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = self.titles[index];
    return cell;
}

#pragma mark - QQPagerViewDelegate

- (void)pagerView:(QQPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"%@", self.titles[index]);
}


@end
