//
//  HLLoginViewController.m
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLLoginViewController.h"
#import "HLLoginView.h"
#import "HLRegisterViewController.h"

#import "HDThridLoginManager.h"
#import "HLAuthenticationViewController.h"
#import "HLBindingViewController.h"
#import "HLUserDetailInfoViewController.h" // 完善信息
#import "HLHTMLLableViewController.h"


#import "HLOneKeyLoginController.h"

@interface HLLoginViewController ()<UITextFieldDelegate,HLLoginViewDeleagte>
{
    NSArray *cycleImageArr;
}
@property (nonatomic, strong) HLLoginView *loginView;
@property (nonatomic, strong) HLUser *userInfo;

@end

@implementation HLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.title = @"登录";
    
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToAuthPhoneAction:) name:LoginNeedBindPhoneNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissVC) name:DismissLoginView object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wanShanClick) name:@"isWanShan" object:nil];
    [self loginView];
    
}

- (void)wanShanClick {
    
//    // 登录极光IM
//    [self loginJpush];
    
    // 是否完善
    [self loadRequest];
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([LoginManager defaultManager].isEditInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ShowDetailInfoView object:nil];
    }
}
- (HLLoginView *)loginView{
    if (!_loginView) {
        _loginView = [[HLLoginView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight) delegate:self];
        
        _loginView.phoneTextField.tag = 529;
        _loginView.secretTextField.tag = 530;
        
        [self.view addSubview:_loginView];
    }
    return _loginView;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 529) { // 限制手机输入字数
        return current.length <= 11;
    }
    if (textField.tag == 530) { // 限制密码为6-12位
        return current.length <= 12;
    }
    
    return YES;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark  click 事件
// 登录事件
- (void)phoneLoginButtonClick:(UIButton *)sender{
    [self dismisskeyBoard];

    if (![self.loginView.phoneTextField.text isValidateTelNumber]) {
        [MBProgressHUD showMessage:@"请输入正确手机号" view:nil];
        return;
    }
    if (self.loginView.secretTextField.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入密码" view:nil];
        return;
    }
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"mobile":self.loginView.phoneTextField.text,
        @"password":self.loginView.secretTextField.text,
        @"device":[[UIDevice currentDevice] deviceModelName]
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLLOGIN withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
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
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLISPerfect withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            if ([[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) { // 已经完善
                
                // 登录极光IM
                [self loginJpush];
                
                
            } else { // 没有完善
                [weakSelf pushUserDetailInfo];
            }
            
        }
        
    } failure:^(NSError * _Nonnull error) {

    }];

}
// 是否需要先完善个人信息
- (void)pushUserDetailInfo{
    HLUserDetailInfoViewController *userDetailInfoVC = [[HLUserDetailInfoViewController alloc] init];
    userDetailInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userDetailInfoVC animated:YES];
}


// 注册
-(void)registClick{
    [self dismisskeyBoard];

    HLRegisterViewController *registerVC = [HLRegisterViewController new];
    [self.navigationController pushViewController:registerVC animated:YES];
}
// 重置密码
- (void)modifyScerctClick{
    [self dismisskeyBoard];

    
}
// 一键登录
- (void)oneKeyLoginScerctClick {
    [self dismisskeyBoard];
    
    HLOneKeyLoginController *vc = [[HLOneKeyLoginController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
// 心理咨询界面
- (void)xinLiZiXunClick {
    
}

// qq登录
- (void)verityLoginButtonClick{
    [self dismisskeyBoard];

    [[HDThridLoginManager sharedManager] openQQWithNumber:NO];

}

// 微信登录
- (void)wechatLoginButtonClick{
    [self dismisskeyBoard];

    [[HDThridLoginManager sharedManager] openWeixinWithBind:NO isNumber:NO];

}

//跳到授权界面去绑定手机号
- (void)jumpToAuthPhoneAction:(NSNotification *)notify{
    [self dismisskeyBoard];
    HLBindingViewController *authenVC = [[HLBindingViewController alloc] init];
    // 绑定类型
    NSDictionary * infoDic = [notify object];
    authenVC.type = [infoDic valueForKey:@"type"];
    authenVC.openID = [infoDic valueForKey:@"openid"];
    [self.navigationController pushViewController:authenVC animated:YES];
}
- (void)dismisskeyBoard{
    if (_loginView.phoneTextField.isFirstResponder || _loginView.secretTextField.isFirstResponder) {
        [_loginView.phoneTextField resignFirstResponder];
        [_loginView.secretTextField resignFirstResponder];
    }
}

// 阅读协议
- (void)statementClickWithTag:(NSString *)tagString {
    
    if ([tagString isEqualToString:@"免责声明"]) {
        HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
        htmlVC.navTitle = @"免责声明";
        htmlVC.type = @"disclaimer";
        [self.navigationController pushViewController:htmlVC animated:YES];
    } else {
        HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
        htmlVC.navTitle = @"隐私政策";
        htmlVC.type = @"privacy";
        [self.navigationController pushViewController:htmlVC animated:YES];
    }
    
}

// Apple 登录
- (void)appleDidLoginWithIdentityToken:(NSString *)identityToken UserId:(NSString *)userid {
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLThird_IOS_LOGIN withDictionary:@{@"openid":userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/iOSLogin %@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) { // 登录成功
            [self.view hideLoading];
            
            [[LoginManager defaultManager] setUserid:[dictionary[@"data"][@"data"] objectForKey:@"id"]];
            [[LoginManager defaultManager] setToken:[dictionary[@"data"][@"data"] objectForKey:@"token"]];
            [[LoginManager defaultManager] setWxOpenId:[dictionary[@"data"][@"data"] objectForKey:@"WXid"]];
            [[LoginManager defaultManager] setAccount:[dictionary[@"data"][@"data"] objectForKey:@"username"]];
            [[LoginManager defaultManager] setPassword:[dictionary[@"data"][@"data"] objectForKey:@"password"]];
            [[LoginManager defaultManager] setNickName:[dictionary[@"data"][@"data"] objectForKey:@"nickname"]];
            [[LoginManager defaultManager] setGender:[dictionary[@"data"][@"data"] objectForKey:@"gender"]];
            [[LoginManager defaultManager] setAvatar:[dictionary[@"data"][@"data"] objectForKey:@"head"]];
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]];
            
            if (kISNullObject(dictionary[@"data"][@"data"][@"member"]) || ![self checkProductDate:dictionary[@"data"][@"data"][@"member"]]) {
                [[LoginManager defaultManager] setIsVip:NO];
            } else {
                [[LoginManager defaultManager] setIsVip:YES];
            }
            
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"别名%@",iAlias);

                if (iResCode == 0) {

                    NSLog(@"qq添加别名成功");

                }

            } seq:0];
            
            if (![[dictionary[@"data"] objectForKey:@"type"] boolValue]) { // 需要绑定
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginNeedBindPhoneNoti object:@{@"type":[dictionary[@"data"] objectForKey:@"in"],@"openid":userid}];
                
            } else { // 已经绑定
                
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isWanShan" object:nil];
            }
            
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:@"登陆失败,请重新登陆"];
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
