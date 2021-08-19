//
//  TransformerExampleViewController.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/7/27.
//

#import "TransformerExampleViewController.h"
#import "QQPagerView.h"
#import "QQPagerViewCell.h"

@interface TransformerExampleViewController ()<UITableViewDataSource, UITableViewDelegate, QQPagerViewDelegate, QQPagerViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QQPagerView *pagerView;

@property (strong, nonatomic) NSArray<NSString *> *imageNames;
@property (strong, nonatomic) NSArray<NSString *> *transformerNames;
@property (assign, nonatomic) NSInteger typeIndex;


@end

@implementation TransformerExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageNames = @[@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", @"5.jpg", @"6.jpg", @"7.jpg"];
    self.transformerNames = @[@"cross fading", @"zoom out", @"depth", @"linear", @"overlap", @"ferris wheel", @"inverted ferris wheel", @"coverflow", @"cubic"];
    
    _pagerView = [[QQPagerView alloc] init];
    _pagerView.delegate = self;
    _pagerView.dataSource = self;
    _pagerView.infinite = YES;
    [self.view addSubview:_pagerView];
    [_pagerView registerClass:[QQPagerViewCell class] forCellWithReuseIdentifier:@"cell"];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    self.typeIndex = 0;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _pagerView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, 193);
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(_pagerView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_pagerView.frame));
    
    self.typeIndex = self.typeIndex;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transformerNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.transformerNames[indexPath.row];
    cell.accessoryType = indexPath.row == self.typeIndex ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.typeIndex = indexPath.row;
    [tableView reloadRowsAtIndexPaths:tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Transformers";
}

#pragma mark - QQPagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(QQPagerView *)pagerView
{
    return self.imageNames.count;
}

- (UICollectionViewCell *)pagerView:(QQPagerView *)pagerView cellForItemAtIndex:(NSInteger)index
{
    QQPagerViewCell * cell = [pagerView dequeueReusableCellWithIdentifier:@"cell" forIndex:index];
    cell.imageView.image = [UIImage imageNamed:self.imageNames[index]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    return cell;
}

#pragma mark - QQPagerViewDelegate

- (void)pagerView:(QQPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index
{
    [pagerView deselectItemAtIndex:index animated:YES];
    [pagerView scrollToItemAtIndex:index animated:YES];
}

#pragma mark - Private properties

- (void)setTypeIndex:(NSInteger)typeIndex
{
    _typeIndex = typeIndex;
    QQPagerViewTransformerType type;
    switch (typeIndex) {
        case 0: {
            type = QQPagerViewTransformerTypeCrossFading;
            break;
        }
        case 1: {
            type = QQPagerViewTransformerTypeZoomOut;
            break;
        }
        case 2: {
            type = QQPagerViewTransformerTypeDepth;
            break;
        }
        case 3: {
            type = QQPagerViewTransformerTypeLinear;
            break;
        }
        case 4: {
            type = QQPagerViewTransformerTypeOverlap;
            break;
        }
        case 5: {
            type = QQPagerViewTransformerTypeFerrisWheel;
            break;
        }
        case 6: {
            type = QQPagerViewTransformerTypeInvertedFerrisWheel;
            break;
        }
        case 7: {
            type = QQPagerViewTransformerTypeCoverFlow;
            break;
        }
        case 8: {
            type = QQPagerViewTransformerTypeCubic;
            break;
        }
        default:
            type = QQPagerViewTransformerTypeZoomOut;
            break;
    }
    self.pagerView.transformer = [[QQPagerViewTransformer alloc] initWithType:type];
    switch (type) {
        case QQPagerViewTransformerTypeCrossFading:
        case QQPagerViewTransformerTypeZoomOut:
        case QQPagerViewTransformerTypeDepth: {
            self.pagerView.itemSize = QQPagerViewAutomaticSize;
            self.pagerView.decelerationDistance = 1;
            break;
        }
        case QQPagerViewTransformerTypeLinear:
        case QQPagerViewTransformerTypeOverlap: {
            CGAffineTransform transform = CGAffineTransformMakeScale(0.6, 0.75);
            self.pagerView.itemSize = CGSizeApplyAffineTransform(self.pagerView.frame.size, transform);
            self.pagerView.decelerationDistance = QQPagerViewAutomaticDistance;
            break;
        }
        case QQPagerViewTransformerTypeFerrisWheel:
        case QQPagerViewTransformerTypeInvertedFerrisWheel: {
            self.pagerView.itemSize = CGSizeMake(180, 140);
            self.pagerView.decelerationDistance = QQPagerViewAutomaticDistance;
            break;
        }
        case QQPagerViewTransformerTypeCoverFlow: {
            self.pagerView.itemSize = CGSizeMake(220, 170);
            self.pagerView.decelerationDistance = QQPagerViewAutomaticDistance;
            break;
        }
        case QQPagerViewTransformerTypeCubic: {
            CGAffineTransform transform = CGAffineTransformMakeScale(0.9, 0.9);
            self.pagerView.itemSize = CGSizeApplyAffineTransform(self.pagerView.frame.size, transform);
            self.pagerView.decelerationDistance = 1;
            break;
        }
        default:
            break;
    }
}


@end
