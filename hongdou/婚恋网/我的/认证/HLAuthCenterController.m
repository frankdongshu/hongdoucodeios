//
//  HLAuthCenterController.m
//  hongdou
//
//  Created by 维康1 on 2019/11/27.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLAuthCenterController.h"
#import "HLPhoneVerityViewController.h" // 手机认证
#import <RPSDK/RPSDK.h>
#import "HLAuthOhterPhoto.h"

@interface HLAuthCenterController ()<UITableViewDelegate, UITableViewDataSource> {
    BOOL _isIdCardAuth;
    BOOL _isHeaderAuth;
    BOOL _isPhoneAuth;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@property (nonatomic, strong) NSArray *otherAuthArray;

@end

@implementation HLAuthCenterController

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@{@"img":@"cer_person_no",
                       @"name":@"手机实名认证"},
                     @{@"img":@"cer_person_no",
                       @"name":@"真人头像认证"},
                     @{@"img":@"shenfenzheng_nor_ico",
                       @"name":@"身份证认证"},
                     @{@"img":@"xuelii_nor_ico",
                       @"name":@"学历认证"},
                     @{@"img":@"che_nor_ico",
                       @"name":@"车辆认证"},
                     @{@"img":@"zhiye_nor_ico",
                       @"name":@"职业认证"},
                     @{@"img":@"fangzi_nor_ico",
                       @"name":@"房产认证"}];
    }
    return _dataArr;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, self.view.size.width, self.view.size.height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuse"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArr[indexPath.row][@"name"];
    cell.imageView.image = [UIImage imageNamed:self.dataArr[indexPath.row][@"img"]];
    cell.textLabel.font = kScaleFont(15);
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    cell.detailTextLabel.font = kScaleFont(15);
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {

        // 手机实名认证
        HLPhoneVerityViewController *phoneVerityVC = [[HLPhoneVerityViewController alloc] init];
        phoneVerityVC.block = ^{
            // 手机是否认证
            [self isAuth];
        };
        phoneVerityVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:phoneVerityVC animated:YES];
    }
    else if (indexPath.row == 1) { // 真人头像认证
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
                            [self isAuthFace];
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
    else if (indexPath.row == 2) { // 真人身份证认证
        
        if (!self->_isPhoneAuth) {
            [MBProgressHUD showMessage:@"您还没有进行手机号实名认证哦~" view:nil];
            return;
        }
        if (!self->_isHeaderAuth) {
            [MBProgressHUD showMessage:@"您还没有进行真人头像认证哦~" view:nil];
            return;
        }
        
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
                            [self isIdCard];
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
    else { // 其他认证
        
        if (!_isIdCardAuth) {
            [MBProgressHUD showMessage:@"您还没有进行身份证认证哦~" view:nil];
            return;
        }
        
        HLAuthOhterPhoto *vc = [[HLAuthOhterPhoto alloc] init];
        vc.typeString = self.otherAuthArray[indexPath.row-3];
        vc.block = ^{
            
            // 其他认证信息
            [self isAuthOther];
            
        };
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"认证中心";
    
    [self.view addSubview:self.tableView];
    
    self.otherAuthArray = @[@"D",@"V",@"P",@"R"];
    
    // 手机是否认证
    [self isAuth];
    // 实人是否认证
    [self isAuthFace];
    // 是否身份证认证成功
    [self isIdCard];
    // 其他认证信息
    [self isAuthOther];
}

// 是否手机实名认证
- (void)isAuth {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLVerity_Statue withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"是否手机实名认证: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSArray *cells = self.tableView.visibleCells;
            UITableViewCell *cell = cells[0];
            
            if ([dictionary[@"data"][@"att"] integerValue] == 0) { // 未认证
                
                cell.detailTextLabel.text = @"去认证";
                cell.detailTextLabel.textColor = [UIColor purpleColor];
                cell.imageView.image = [UIImage imageNamed:@"cer_phone_no"];
                
            } else { // 已认证
                
                self->_isPhoneAuth = YES;
                
                cell.detailTextLabel.text = @"已认证";
                cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                cell.userInteractionEnabled = NO;
                cell.imageView.image = [UIImage imageNamed:@"cer_phone_yes"];
                
            }
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 是否人脸认证成功
- (void)isAuthFace {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/certification" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"人脸认证结果: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSArray *cells = self.tableView.visibleCells;
            UITableViewCell *cell = cells[1];
            
            if (![[dictionary[@"data"][@"VerifyStatus"] stringValue] isEqualToString:@"1"]) { // 未认证
                
                cell.detailTextLabel.text = @"去认证";
                cell.detailTextLabel.textColor = [UIColor purpleColor];
                cell.imageView.image = [UIImage imageNamed:@"cer_person_no"];
                
            } else { // 已认证
                
                self->_isHeaderAuth = YES;
                
                cell.detailTextLabel.text = @"已认证";
                cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                cell.userInteractionEnabled = NO;
                cell.imageView.image = [UIImage imageNamed:@"cer_person_yes"];
                
            }
        } else {
            // code 202 尚未认证
            NSArray *cells = self.tableView.visibleCells;
            UITableViewCell *cell = cells[1];
            
            cell.detailTextLabel.text = @"去认证";
            cell.detailTextLabel.textColor = [UIColor purpleColor];
            cell.imageView.image = [UIImage imageNamed:@"cer_person_no"];
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 是否身份证认证成功
- (void)isIdCard {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/identification" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"身份证认证结果: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSArray *cells = self.tableView.visibleCells;
            UITableViewCell *cell = cells[2];
            
            if (![[dictionary[@"data"][@"VerifyStatus"] stringValue] isEqualToString:@"1"]) { // 未认证
                
                cell.detailTextLabel.text = @"去认证";
                cell.detailTextLabel.textColor = [UIColor purpleColor];
                cell.imageView.image = [UIImage imageNamed:@"shenfenzheng_nor_ico"];
                
            } else { // 已认证
                
                self->_isIdCardAuth = YES;
                
                cell.detailTextLabel.text = @"已认证";
                cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                cell.userInteractionEnabled = NO;
                cell.imageView.image = [UIImage imageNamed:@"shenfenzheng_per_ico"];
                
            }
        } else {
            
            // code 202 尚未认证
            NSArray *cells = self.tableView.visibleCells;
            UITableViewCell *cell = cells[2];
            
            cell.detailTextLabel.text = @"去认证";
            cell.detailTextLabel.textColor = [UIColor purpleColor];
            cell.imageView.image = [UIImage imageNamed:@"shenfenzheng_nor_ico"];
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

// 其他认证信息
- (void)isAuthOther {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_certification" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"其他认证结果: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSArray *cells = self.tableView.visibleCells;
            
            for (NSDictionary *dic in dictionary[@"data"]) {
                if ([dic[@"type"] isEqualToString:@"学历"]) {
                    UITableViewCell *cell = cells[3];
                    cell.detailTextLabel.text = dic[@"state"];
                    
                    if (![dic[@"state"] isEqualToString:@"已认证"]) {
                        cell.imageView.image = [UIImage imageNamed:@"xuelii_nor_ico"];
                        cell.detailTextLabel.textColor = [UIColor purpleColor];
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"xuelii_per_ico"];
                        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                    }
                    
                }
                if ([dic[@"type"] isEqualToString:@"车辆"]) {
                    UITableViewCell *cell = cells[4];
                    
                    cell.detailTextLabel.text = dic[@"state"];
                    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                    
                    if (![dic[@"state"] isEqualToString:@"已认证"]) {
                        cell.imageView.image = [UIImage imageNamed:@"che_nor_ico"];
                        cell.detailTextLabel.textColor = [UIColor purpleColor];
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"che_per_ico"];
                        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                    }
                    
                }
                if ([dic[@"type"] isEqualToString:@"职业"]) {
                    UITableViewCell *cell = cells[5];
                    
                    cell.detailTextLabel.text = dic[@"state"];
                    
                    if (![dic[@"state"] isEqualToString:@"已认证"]) {
                        cell.imageView.image = [UIImage imageNamed:@"zhiye_nor_ico"];
                        cell.detailTextLabel.textColor = [UIColor purpleColor];
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"zhiye_pre_ico"];
                        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                    }
                    
                }
                if ([dic[@"type"] isEqualToString:@"房产"]) {
                    UITableViewCell *cell = cells[6];
                    
                    cell.detailTextLabel.text = dic[@"state"];
                    
                    if (![dic[@"state"] isEqualToString:@"已认证"]) {
                        cell.imageView.image = [UIImage imageNamed:@"fangzi_nor_ico"];
                        cell.detailTextLabel.textColor = [UIColor purpleColor];
                    } else {
                        cell.imageView.image = [UIImage imageNamed:@"fangzi_per_ico"];
                        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
                    }
                    
                }
            }
            
            
            
        } else {
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
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
