//
//  HLTeacherViewController.m
//  hongdou
//
//  Created by 维康1 on 2021/7/21.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLTeacherViewController.h"
#import "CSPersonInfoController.h" // 编辑信息
#import "CSProjectTypeController.h" // 课程项目
#import "LLBugVipController.h" // 开通会员
#import "LLBuyNumberController.h" // 购买联系方式显示次数
#import <RPSDK/RPSDK.h>

@interface HLTeacherViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *titleArray;

@property (strong, nonatomic) NSString *messageString;

@property (strong, nonatomic) NSDictionary *succDic;

@end

@implementation HLTeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"咨询师注册";
    
    self.titleArray = @[@[@"编辑信息",@"课程设置",@"刷新设置",@"身份认证",@"头像认证"],@[@"显示联系方式",@"排名刷新置顶"]];
    self.succDic = [NSDictionary dictionary];
    
    [self.view addSubview:self.tableView];
    
    self.messageString = [NSString string];
    
    [self requestIsTeather];
    
    [self isAllAuth];
}

// 是否是咨询师
- (void)requestIsTeather {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/mind/ismind" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        
        NSLog(@"/mind/ismind: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            self.messageString = @"提示:\n您已成为咨询师";
            
        } else {
            self.messageString = @"提示:\n审核通过后身份会转化为咨询师, 如需继续使用交友功能, 请用其他手机注册使用";
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:error.localizedDescription];
    }];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return _tableView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if (section == 1) {
        return self.messageString;
    } else {
        return nil;
    }
    
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.titleArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuse"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    NSArray *arr = self.titleArray[indexPath.section];
    
    cell.textLabel.text = arr[indexPath.row];
    cell.textLabel.font = kScaleFont(15);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    UIImageView *succImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"renzheng_succ"]];
    UIImageView *failImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"renzheng_fail"]];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            if ([[self.succDic[@"bj"] stringValue] isEqualToString:@"1"]) {
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
        if (indexPath.row == 1) {
            if ([[self.succDic[@"kc"] stringValue] isEqualToString:@"1"]) {
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
        if (indexPath.row == 2) {
            if ([[self.succDic[@"sx"] stringValue] isEqualToString:@"1"]) {
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
        if (indexPath.row == 3) {
            if ([[self.succDic[@"sf"] stringValue] isEqualToString:@"1"]){
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
        if (indexPath.row == 4) {
            if ([[self.succDic[@"tx"] stringValue] isEqualToString:@"1"]){
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
    }
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            if ([[self.succDic[@"xs"] stringValue] isEqualToString:@"1"]){
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
        if (indexPath.row == 1) {
            if ([[self.succDic[@"sx"] stringValue] isEqualToString:@"1"]){
                cell.accessoryView = succImgV;
            } else {
                cell.accessoryView = failImgV;
            }
        }
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) { // 编辑信息
            
            CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (indexPath.row == 1) { // 课程设置
            
            CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (indexPath.row == 2) { // 刷新置顶
            
            [self updateIsBuyWithUrl:@"/mind/new_ranking"];
            
        } else if (indexPath.row == 3) { // 身份认证
            
            [self shenfenzhengrenzheng];
            
        } else { // 头像认证
            [self touxiangrenzheng];
        }
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { // 显示联系方式
            [self updateIsBuyWithUrl:@"/mind/is_newmember"];
            
        } else { // 排名刷新置顶
            [self updateIsBuyWithUrl:@"/mind/is_newranking"];
        }
    }
    
}

// 是否购买联系方式/刷新置顶功能
- (void)updateIsBuyWithUrl:(NSString *)url {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@: %@",url,dictionary);
        
        if (![[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            if ([url isEqualToString:@"/mind/is_newmember"]) {
                [self getAlertControllerToVipViewWithMessage:@"请购买联系方式可显功能" andType:@"购买联系方式"];
            } else {
                [self getAlertControllerToVipViewWithMessage:@"请购买置顶功能" andType:@"购买置顶"];
            }
            
            
        } else {
            // 已经显示联系方式
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:error.localizedDescription];
    }];
    
}

// 获取认证信息
- (void)isAllAuth {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"mobile":[LoginManager defaultManager].account
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/mindtxt" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"/mind/mindtxt: %@",dictionary);
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.succDic = dictionary[@"data"];
            
            [self.tableView reloadData];
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

// 真人头像认证
- (void)touxiangrenzheng {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":[LoginManager defaultManager].avatar
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/getAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"-- %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [RPSDK startWithVerifyToken:dictionary[@"data"][@"VerifyToken"]
                         viewController:self
                             completion:^(RPResult * _Nonnull result) {
                // 建议接入方调用实人认证服务端接口 DescribeVerifyResult，
                // 来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                NSLog(@"真人头像认证结果：%@", result);
                switch (result.state) {
                    case RPStatePass:
                        // 认证通过。
                        NSLog(@"真人头像认证成功");
                        // 实人是否认证
                        [self isAllAuth];
                        break;
                    case RPStateFail:
                        // 认证不通过。
                        break;
                    case RPStateNotVerify:
                        // 未认证。
                        // 通常是用户主动退出或者姓名身份证号实名校验不匹配等原因导致。
                        // 具体原因可通过 result.errorCode 和 result.message 来区分（详见错误码说明）。
                        break;
                }
            }];
        } else {
            
            [MBProgressHUD showMessage:@"获取Token失败" view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    
}

// 身份证认证
- (void)shenfenzhengrenzheng {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/idAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [RPSDK startWithVerifyToken:dictionary[@"data"][@"VerifyToken"]
                         viewController:self
                             completion:^(RPResult * _Nonnull result) {
                // 建议接入方调用实人认证服务端接口 DescribeVerifyResult，
                // 来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                NSLog(@"真人身份证认证结果：%@", result);
                switch (result.state) {
                    case RPStatePass:
                        // 认证通过。
                        NSLog(@"真人身份证认证成功");
                        // 是否身份证认证成功
                        [self isAllAuth];
                        break;
                    case RPStateFail:
                        // 认证不通过。
                        break;
                    case RPStateNotVerify:
                        // 未认证。
                        // 通常是用户主动退出或者姓名身份证号实名校验不匹配等原因导致。
                        // 具体原因可通过 result.errorCode 和 result.message 来区分（详见错误码说明）。
                        break;
                }
            }];
            
        } else {
            [MBProgressHUD showMessage:@"获取Token失败" view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)getAlertControllerToVipViewWithMessage:(NSString *)message andType:(NSString *)type {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([type isEqualToString:@"购买置顶"]) {
            LLBugVipController *vc = [[LLBugVipController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            LLBuyNumberController *vc = [[LLBuyNumberController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
    [action setValue:REDColor forKey:@"titleTextColor"];
    
    [alertC addAction:action];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
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
