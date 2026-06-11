//
//  HDTagViewController.m
//  hongdou
//
//  Created by 维康1 on 2020/6/15.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HDTagViewController.h"
#import "HDSelectTagController.h"
#import "MKJTagViewTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface HDTagViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *imgArray, *titleArray;

@end

static NSString *identyfy = @"MKJTagViewTableViewCell";

@implementation HDTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sc_navigationBar.title = @"标签";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.imgArray = @[@[@"biaoqian"],@[@"dongman",@"dianying",@"lvyou",@"lingshi",@"yundong",@"yinyue"]];
    self.titleArray = @[@[@"个性"],@[@"动漫",@"影视",@"旅游",@"美食",@"运动",@"音乐"]];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:identyfy bundle:nil] forCellReuseIdentifier:identyfy];
    
    [self.view addSubview:self.tableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, 40)];
    lab.text = @[@"我的标签",@"兴趣爱好"][section];
    
    [view addSubview:lab];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.imgArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.imgArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKJTagViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identyfy forIndexPath:indexPath];
    [self configCell:cell indexpath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    cell.imageView.image = [UIImage imageNamed:self.imgArray[indexPath.section][indexPath.row]];
    return cell;
}

- (void)configCell:(MKJTagViewTableViewCell *)cell indexpath:(NSIndexPath *)indexpath
{
    [cell.tagView removeAllTags];
    cell.tagView.preferredMaxLayoutWidth = kScreenWidth -30;
    cell.tagView.padding = UIEdgeInsetsMake(20, 60, 20, 20);
    cell.tagView.lineSpacing = 15;
    cell.tagView.interitemSpacing = 15;
    cell.tagView.singleLine = NO;
    // 给出两个字段，如果给的是0，那么就是变化的,如果给的不是0，那么就是固定的
//        cell.tagView.regularWidth = 80;
        cell.tagView.regularHeight = 30;
    
    NSArray *arr = [NSArray array];
    
    if (indexpath.section == 0) {
        arr = self.dataArray[indexpath.row][@"label"];
    } else {
        arr = self.dataArray[indexpath.row+1][@"label"];
    }
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKTag *tag = [[SKTag alloc] initWithText:arr[idx]];
        
        tag.font = [UIFont systemFontOfSize:12];
        
        
        if (indexpath.section == 0) {
            if (indexpath.row == 0) { // 个性
                tag.textColor = kRGBA(255, 92, 122, 1);
                tag.bgColor = kRGBA(252, 240, 242, 1);
            }
        } else {
            if (indexpath.row == 0) { // 动漫
                tag.textColor = kRGBA(234, 90, 175, 1);
                tag.bgColor = kRGBA(254, 227, 243, 1);
            }
            if (indexpath.row == 1) { // 影视
                tag.textColor = kRGBA(165, 109, 241, 1);
                tag.bgColor = kRGBA(242, 231, 255, 1);
            }
            if (indexpath.row == 2) { // 旅游
                tag.textColor = kRGBA(66, 196, 228, 1);
                tag.bgColor = kRGBA(223, 249, 255, 1);
            }
            if (indexpath.row == 3) { // 美食
                tag.textColor = kRGBA(251, 184, 56, 1);
                tag.bgColor = kRGBA(253, 247, 235, 1);
            }
            if (indexpath.row == 4) { // 运动
                tag.textColor = kRGBA(92, 179, 99, 1);
                tag.bgColor = kRGBA(236, 254, 237, 1);
            }
            if (indexpath.row == 5) { // 音乐
                tag.textColor = kRGBA(117, 169, 255, 1);
                tag.bgColor = kRGBA(235, 244, 253, 1);
            }
        }
        
        
        tag.cornerRadius = 15;
        tag.enable = YES;
        tag.padding = UIEdgeInsetsMake(5, 10, 5, 10);
        [cell.tagView addTag:tag];
    }];
    
    cell.tagView.didTapTagAtIndex = ^(NSUInteger index, UIButton *btn)
    {
        NSLog(@"点击了%ld",index);
    };
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:identyfy configuration:^(id cell) {
       
        [self configCell:cell indexpath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HDSelectTagController *vc = [[HDSelectTagController alloc] init];
    
    vc.typeString = self.titleArray[indexPath.section][indexPath.row];
    
    if (indexPath.section == 0) {
        vc.tagArray = self.dataArray[indexPath.row][@"label"];
    } else {
        vc.tagArray = self.dataArray[indexPath.row+1][@"label"];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
