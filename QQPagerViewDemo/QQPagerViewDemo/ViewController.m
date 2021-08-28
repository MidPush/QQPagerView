//
//  ViewController.m
//  QQPagerViewDemo
//
//  Created by Mac on 2021/8/19.
//

#import "ViewController.h"
#import "BasicExampleViewController.h"
#import "TransformerExampleViewController.h"
#import "PageControlExampleViewController.h"
#import "CustomCellExampleViewController.h"
#import "TextLabelExampleViewController.h"
#import "PageControlExample2ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"QQPagerView";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Banner Example";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Transformer Example";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"TextLabel Example";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"CustomCell Example";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"PageControl Example";
    } else if (indexPath.row == 5) {
        cell.textLabel.text = @"PageControl2 Example";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = nil;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        vc = [[BasicExampleViewController alloc] init];
    } else if (indexPath.row == 1) {
        vc = [[TransformerExampleViewController alloc] init];
    } else if (indexPath.row == 2) {
        vc = [[TextLabelExampleViewController alloc] init];
    } else if (indexPath.row == 3) {
        vc = [[CustomCellExampleViewController alloc] init];
    } else if (indexPath.row == 4) {
        vc = [[PageControlExampleViewController alloc] init];
    } else if (indexPath.row == 5) {
        vc = [[PageControlExample2ViewController alloc] init];
    }
    vc.title = cell.textLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
