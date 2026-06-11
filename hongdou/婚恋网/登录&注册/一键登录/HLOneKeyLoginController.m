//
//  HLOneKeyLoginController.m
//  hongdou
//
//  Created by 维康1 on 2020/9/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLOneKeyLoginController.h"
#import "HLMessageController.h" // 短信登录
#import "HLUserDetailInfoViewController.h" // 完善信息
#import <JVERIFICATIONService.h> // 一键登录

@interface HLOneKeyLoginController ()
@property (weak, nonatomic) IBOutlet UIButton *oneKeyBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;

@end

@implementation HLOneKeyLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.title = @"一键登录";
    
    
    self.oneKeyBtn.layer.borderWidth = 1;
    self.oneKeyBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.oneKeyBtn.layer.cornerRadius = 20;
    
    
    self.messageBtn.layer.cornerRadius = 20;
    
    
}

// 一键登录
- (IBAction)oneKeyClick:(id)sender {
    
    JVUIConfig *config = [[JVUIConfig alloc] init];
    config.privacyState = YES; // 默认勾选同意
    config.checkViewHidden = YES; // 隐藏选择框
    
    [JVERIFICATIONService customUIWithConfig:config];
    
    [JVERIFICATIONService getAuthorizationWithController:self hide:YES animated:YES timeout:15*1000 completion:^(NSDictionary *result) {
        NSLog(@"一键登录 result:%@", result);
        
        if ([[result[@"code"] stringValue] isEqualToString:@"6000"]) {
            [self loginClickWithLoginToken:result[@"loginToken"]];
        } else {
            [MBProgressHUD showMessage:result[@"content"] view:nil];
        }
        
    } actionBlock:^(NSInteger type, NSString *content) {
        NSLog(@"一键登录 actionBlock :%ld %@", (long)type , content);
    }];
    
}

// 短信登录
- (IBAction)messageClick:(id)sender {
    
    HLMessageController *vc = [[HLMessageController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

// 一键登录
- (void)loginClickWithLoginToken:(NSString *)token {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"message":token
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/oneClickLogin" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/oneClickLogin %@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            [MBProgressHUD hideLoading];
            
            //保存是否需要自动登录
            [[LoginManager defaultManager] setIsLogin:YES];
            
            [[LoginManager defaultManager] setUserid:dictionary[@"data"][@"id"]]; // 用户id
            [[LoginManager defaultManager] setToken:dictionary[@"data"][@"token"]]; // token
            [[LoginManager defaultManager] setWxOpenId:dictionary[@"data"][@"WXid"]]; // 微信openid
            
            [[LoginManager defaultManager] setAccount:dictionary[@"data"][@"username"]]; // 手机号
            [[LoginManager defaultManager] setPassword:dictionary[@"data"][@"password"]]; // 密码
            [[LoginManager defaultManager] setAvatar:dictionary[@"data"][@"head"]]; // 头像
            [[LoginManager defaultManager] setNickName:dictionary[@"data"][@"nickname"]]; // 昵称
            [[LoginManager defaultManager] setGender:dictionary[@"data"][@"gender"]]; // 性别
            [[LoginManager defaultManager] setBalance:dictionary[@"data"][@"balance"]]; // 余额
            
            if (kISNullObject(dictionary[@"data"][@"member"]) || ![self checkProductDate:dictionary[@"data"][@"member"]]) {
                [[LoginManager defaultManager] setIsVip:NO];
            } else {
                [[LoginManager defaultManager] setIsVip:YES];
            }
            
            // 设置别名
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {

                    NSLog(@"添加别名成功");

                }

            } seq:0];
            
            // 是否需要完善信息
            [self loadRequest];
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}

- (void)loginJpush {
    
    [JMSGUser loginWithUsername:[LoginManager defaultManager].account password:@"91110113" devicesInfo:^(NSArray<__kindof JMSGDeviceInfo *> * _Nonnull devices) {
        
        NSLog(@"---->%@",devices);
        
    } completionHandler:^(id resultObject, NSError *error) {
        
        if (!error) {
            NSLog(@"极光IM登录成功: %@",resultObject);
        } else {
            NSLog(@"极光IM登录失败: %@",error);
        }
        
    }];
    
}

// 是否已经完善信息
- (void)loadRequest{
    if (!self.isLogin) {
        return;
    }
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLISPerfect withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            if (![[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) { // 需要完善
                [weakSelf pushUserDetailInfo];
            } else { // 已经完善
                
                // 登录极光IM
                [self loginJpush];
                
                
            }
        }
    } failure:^(NSError * _Nonnull error) {

    }];

}
// 是否需要先完善个人信息
- (void)pushUserDetailInfo{
    HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 与当前时间比较是否过期
- (BOOL)checkProductDate: (NSString *)tempDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:tempDate];
    
    // 判断是否大于当前时间
    if ([date earlierDate:[NSDate date]] != date) {
        
        return NO;
    } else {
        
        return YES;
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
