//
//  PageControlExample2ViewController.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/28.
//

#import "PageControlExample2ViewController.h"
#import "QQPagerView.h"
#import "QQPagerViewCell.h"
#import "QQPageControlAji.h"
#import "QQPageControlAleppo.h"
#import "QQPageControlChimayo.h"
#import "QQPageControlFresno.h"
#import "QQPageControlJalapeno.h"
#import "QQPageControlJaloro.h"
#import "QQPageControlPaprika.h"
#import "QQPageControlPuya.h"

#import "QQPageControlTwo.h"

@interface PageControlExample2ViewController ()<QQPagerViewDelegate, QQPagerViewDataSource>

@property (nonatomic, strong) QQPagerView *pagerView;
@property (strong, nonatomic) NSArray<NSString *> *imageNames;
@property (nonatomic, strong) NSArray<QQBasePageControl *> *pageControls;

@property (nonatomic, strong) QQPageControlTwo *pageControlTwo;

@end

@implementation PageControlExample2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg"];
    
    _pagerView = [[QQPagerView alloc] init];
    _pagerView.delegate = self;
    _pagerView.dataSource = self;
    _pagerView.automaticSlidingInterval = 2.0;
    _pagerView.infinite = YES;
    [self.view addSubview:_pagerView];
    [_pagerView registerClass:[QQPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    NSArray *pageControlClassNames = @[
        @"QQPageControlAji", @"QQPageControlAleppo",
        @"QQPageControlChimayo", @"QQPageControlFresno",
        @"QQPageControlJalapeno", @"QQPageControlJaloro",
        @"QQPageControlPaprika", @"QQPageControlPuya",
    ];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageControlClassNames.count; i++) {
        QQBasePageControl *pageControl = [[NSClassFromString(pageControlClassNames[i]) alloc] init];
        pageControl.numberOfPages = self.imageNames.count;
        [self.view addSubview:pageControl];
        [array addObject:pageControl];
    }
    _pageControls = [array copy];
    
    _pageControlTwo = [[QQPageControlTwo alloc] init];
    _pageControlTwo.numberOfPages = self.imageNames.count;
    _pageControlTwo.currentPageIndicatorSize = CGSizeMake(20, 10);
    [self.view addSubview:_pageControlTwo];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pagerView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, 150);
    
    CGFloat lastTop = CGRectGetMaxY(_pagerView.frame);
    for (NSInteger i = 0; i < _pageControls.count; i++) {
        QQBasePageControl *pageControl = _pageControls[i];
        pageControl.frame = CGRectMake(0, lastTop + 10, self.view.frame.size.width, 30);
        lastTop = CGRectGetMaxY(pageControl.frame);
    }
    
    _pageControlTwo.frame = CGRectMake(0, lastTop + 10, self.view.frame.size.width, 30);
}

#pragma mark - QQPagerViewDataSource
- (NSInteger)numberOfItemsInPagerView:(QQPagerView *)pagerView {
    return self.imageNames.count;
}

- (UICollectionViewCell *)pagerView:(QQPagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    QQPagerViewCell *cell = (QQPagerViewCell *)[pagerView dequeueReusableCellWithIdentifier:@"cell" forIndex:index];
    cell.imageView.image = [UIImage imageNamed:self.imageNames[index]];
    return cell;
}

#pragma mark - QQPagerViewDelegate
- (void)pagerViewDidScroll:(QQPagerView *)pagerView {
    for (QQBasePageControl *pageControl in self.pageControls) {
        pageControl.progress = pagerView.scrollOffset;
    }
}

- (void)pagerView:(QQPagerView *)pagerView didScrollToItemAtIndex:(NSInteger)index {
    [_pageControlTwo setPage:index animated:YES];
}


@end
