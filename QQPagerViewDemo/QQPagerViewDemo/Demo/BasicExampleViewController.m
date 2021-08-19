//
//  BasicExampleViewController.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/26.
//

#import "BasicExampleViewController.h"
#import "QQPagerView.h"
#import "QQPagerViewCell.h"
#import "QQPageControl.h"

@interface BasicExampleViewController ()<UITableViewDataSource, UITableViewDelegate, QQPagerViewDelegate, QQPagerViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QQPagerView *pagerView;
@property (nonatomic, strong) QQPageControl *pageControl;

@property (strong, nonatomic) NSArray<NSString *> *sectionTitles;
@property (strong, nonatomic) NSArray<NSString *> *configurationTitles;
@property (strong, nonatomic) NSArray<NSString *> *decelerationDistanceOptions;
@property (strong, nonatomic) NSArray<NSString *> *imageNames;
@property (assign, nonatomic) NSInteger numberOfItems;

@end

@implementation BasicExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sectionTitles = @[@"Configurations", @"Deceleration Distance", @"Item Size", @"Interitem Spacing", @"Number Of Items"];
    self.configurationTitles = @[@"Automatic sliding", @"Infinite"];
    self.decelerationDistanceOptions = @[@"Automatic", @"1", @"2"];
    self.imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg", @"7.jpg"];
    self.numberOfItems = self.imageNames.count;
    
    _pagerView = [[QQPagerView alloc] init];
    _pagerView.delegate = self;
    _pagerView.dataSource = self;
    _pagerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_pagerView];
    [_pagerView registerClass:[QQPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    _pageControl = [[QQPageControl alloc] init];
    _pageControl.numberOfPages = self.numberOfItems;
    [self.view addSubview:_pageControl];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pagerView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, 193);
    
    _pageControl.frame = CGRectMake(0, CGRectGetMaxY(_pagerView.frame) - 40, CGRectGetWidth(_pagerView.frame), 40);
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(_pagerView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_pagerView.frame));
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.configurationTitles.count;
        case 1:
            return self.decelerationDistanceOptions.count;
        case 2:
        case 3:
        case 4:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // Configurations
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            cell.textLabel.text = self.configurationTitles[indexPath.row];
            if (indexPath.row == 0) {
                // Automatic Sliding
                cell.accessoryType = self.pagerView.automaticSlidingInterval > 0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            } else if (indexPath.row == 1) {
                // IsInfinite
                cell.accessoryType = self.pagerView.infinite ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            return cell;
        }
        case 1: {
            // Decelaration Distance
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            cell.textLabel.text = self.decelerationDistanceOptions[indexPath.row];
            switch (indexPath.row) {
                case 0:
                    // Hardcode like '-1' is bad for readability, but there haven't been a better solution to export a swift constant to objective-c yet.
                    cell.accessoryType = self.pagerView.decelerationDistance == QQPagerViewAutomaticDistance ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 1:
                    cell.accessoryType = self.pagerView.decelerationDistance == 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case 2:
                    cell.accessoryType = self.pagerView.decelerationDistance == 2 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                default:
                    break;
            }
            return cell;
        }
        case 2: {
            // Item Spacing
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"slider_cell"];
                
                UISlider *slider = [[UISlider alloc] init];
                slider.frame = CGRectMake((CGRectGetWidth(self.view.frame) -300) * 0.5, (CGRectGetHeight(cell.frame) - CGRectGetHeight(slider.frame)) * 0.5, 300, slider.frame.size.height);
                [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:slider];
            }
            UISlider *slider = cell.contentView.subviews.firstObject;
            slider.tag = 1;
            slider.value = ({
                CGFloat scale = self.pagerView.itemSize.width/self.pagerView.frame.size.width;
                CGFloat value = (0.5-scale)*2;
                value;
            });
            slider.continuous = YES;
            return cell;
        }
        case 3: {
            // Interitem Spacing
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"slider_cell"];
                
                UISlider *slider = [[UISlider alloc] init];
                slider.frame = CGRectMake((CGRectGetWidth(self.view.frame) -300) * 0.5, (CGRectGetHeight(cell.frame) - CGRectGetHeight(slider.frame)) * 0.5, 300, slider.frame.size.height);
                [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:slider];
            }
            UISlider *slider = cell.contentView.subviews.firstObject;
            slider.tag = 2;
            slider.value = self.pagerView.interitemSpacing / 20.0;
            slider.continuous = YES;
            return cell;
        }
        case 4: {
            // Number Of Items
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"slider_cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"slider_cell"];
                
                UISlider *slider = [[UISlider alloc] init];
                slider.frame = CGRectMake((CGRectGetWidth(self.view.frame) -300) * 0.5, (CGRectGetHeight(cell.frame) - CGRectGetHeight(slider.frame)) * 0.5, 300, slider.frame.size.height);
                [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:slider];
            }
            UISlider *slider = cell.contentView.subviews.firstObject;
            slider.tag = 3;
            slider.value = self.numberOfItems / 7.0;
            slider.minimumValue = 1.0 / 7;
            slider.maximumValue = 1.0;
            slider.continuous = NO;
            return cell;
        }
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 || indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                // Automatic Sliding
                self.pagerView.automaticSlidingInterval = 3.0 - self.pagerView.automaticSlidingInterval;
            } else if (indexPath.row == 1) {
                // IsInfinite
                self.pagerView.infinite = !self.pagerView.infinite;
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0:
                    self.pagerView.decelerationDistance = QQPagerViewAutomaticDistance;
                    break;
                case 1:
                    self.pagerView.decelerationDistance = 1;
                    break;
                case 2:
                    self.pagerView.decelerationDistance = 2;
                    break;
                default:
                    break;
            }
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 40 : 20;
}

#pragma mark - QQPagerViewDataSource
- (NSInteger)numberOfItemsInPagerView:(QQPagerView *)pagerView {
    return self.numberOfItems;
}

- (UICollectionViewCell *)pagerView:(QQPagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    QQPagerViewCell *cell = [pagerView dequeueReusableCellWithIdentifier:@"cell" forIndex:index];
    cell.imageView.image = [UIImage imageNamed:self.imageNames[index]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    return cell;
}

#pragma mark - QQPagerViewDelegate

- (void)pagerView:(QQPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index {
    [pagerView deselectItemAtIndex:index animated:YES];
    [pagerView scrollToItemAtIndex:index animated:YES];
    NSLog(@"点击了第%ld张图片", index);
}

- (void)pagerViewWillEndDragging:(QQPagerView *)pagerView targetIndex:(NSInteger)targetIndex {
    self.pageControl.currentPage = targetIndex;
}

- (void)pagerViewDidEndDecelerating:(QQPagerView *)pagerView {
    self.pageControl.currentPage = pagerView.currentIndex;
}

- (void)pagerViewDidEndScrollingAnimation:(QQPagerView *)pagerView {
    self.pageControl.currentPage = pagerView.currentIndex;
}

- (void)sliderValueChanged:(UISlider *)sender {
    switch (sender.tag) {
        case 1: {
            CGFloat scale = 0.5 * (1 + sender.value); // [0.5 - 1.0]
            self.pagerView.itemSize = CGSizeApplyAffineTransform(self.pagerView.frame.size, CGAffineTransformMakeScale(scale, scale));
            break;
        }
        case 2: {
            self.pagerView.interitemSpacing = sender.value * 20; // [0 - 20]
            break;
        }
        case 3: {
            self.numberOfItems = roundf(sender.value * 7);
            self.pageControl.numberOfPages = self.numberOfItems;
            [self.pagerView reloadData];
            break;
        }
        default:
            break;
    }
}

@end
