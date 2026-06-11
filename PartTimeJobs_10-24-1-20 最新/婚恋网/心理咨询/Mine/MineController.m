//
//  MineController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "MineController.h"
#import "CSPersonInfoController.h"
#import "CSProjectTypeController.h"
#import "LLBugVipController.h"
#import "CSMySettingViewController.h"
#import "HLHTMLLableViewController.h"
#import "HLLeavingViewController.h"

@interface MineController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *imgArr, *titleArr;

@property (nonatomic, strong) UIView *logOutView;

@end

@implementation MineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    self.sc_navigationBar.title = @"个人中心";
    self.sc_navigationBar.colorArray = @[REDColor,REDColor]; // navColor 不好使
    
    self.imgArr = @[@"shezhi_ico",@"shezhi_ico",@"shezhi_ico",@"shezhi_ico",@"shezhi_ico",@"shezhi_ico",@"shezhi_ico",@"shezhi_ico",@"shezhi_ico"];
    self.titleArr = @[@"个人信息",@"选择擅长项目",@"购买会员",@"关于我们",@"安全手册",@"隐私政策",@"服务协议",@"客服留言",@"设置"];
    
    
    [self.view addSubview:self.tableView];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight)];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kTabBarHeight, 0);
        
        _tableView.backgroundColor = kRGB(245, 245, 245);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        // 去掉多余分割线
        _tableView.tableFooterView = [[UIView alloc] init];
        
        _tableView.tableFooterView = self.logOutView;
    }
    return _tableView;
}

- (UIView *)logOutView {
    if (!_logOutView) {
        _logOutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
//        _logOutView.backgroundColor = [UIColor greenColor];
        
        UIButton *logOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        logOutBtn.frame = CGRectMake(20, 100, kScreenWidth-40, 40);
        logOutBtn.layer.cornerRadius = 5;
        logOutBtn.layer.masksToBounds = YES;
        [logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        logOutBtn.backgroundColor = REDColor;
        [logOutBtn addTarget:self action:@selector(logOutClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_logOutView addSubview:logOutBtn];
    }
    return _logOutView;
}

// 退出登录
- (void)logOutClick {
    
    [JMSGUser logout:^(id resultObject, NSError *error) {
        if (!error) {
            NSLog(@"resultObject: %@",resultObject);
        } else {
            NSLog(@"error: %@",error);
        }
    }];
    
    [MyLogin logOut];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.imageView.image = [UIImage imageNamed:self.imgArr[indexPath.row]];
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // 个人信息
        CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
        vc.login = LoginYes;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 1) { // 擅长项目
        CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
        vc.projType = TypeYes;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 2) { // 购买会员
        LLBugVipController *vc = [[LLBugVipController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 3) { // 关于我们
        HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
        htmlVC.navTitle = @"关于我们";
        htmlVC.type = @"concerning";
        htmlVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
    if (indexPath.row == 4) { // 安全手册
        HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
        htmlVC.navTitle = @"安全手册";
        htmlVC.type = @"security";
        htmlVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
    if (indexPath.row == 5) { // 隐私政策
        HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
        htmlVC.navTitle = @"隐私政策";
        htmlVC.type = @"privacy";
        htmlVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
    if (indexPath.row == 6) { // 服务协议
        HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
        htmlVC.navTitle = @"服务协议";
        htmlVC.type = @"service";
        htmlVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
    if (indexPath.row == 7) { // 客服留言
        HLLeavingViewController *leavVC = [[HLLeavingViewController alloc] init];
        leavVC.type = Teacher;
        leavVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:leavVC animated:YES];
    }
    if (indexPath.row == self.titleArr.count-1) { // 设置
        CSMySettingViewController *vc = [[CSMySettingViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
