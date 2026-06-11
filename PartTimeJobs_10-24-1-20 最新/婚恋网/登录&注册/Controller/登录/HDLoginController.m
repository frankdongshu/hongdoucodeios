//
//  HDLoginController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/24.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HDLoginController.h"
#import "HLLoginView.h"
#import "HLRegisterViewController.h"
#import "HLResetViewController.h"
#import "HDThridLoginManager.h"
#import "HLAuthenticationViewController.h"
#import "HLBindingViewController.h"
#import "HLUserDetailInfoViewController.h" // 完善信息
#import "HLHTMLLableViewController.h"
#import "MentalityController.h" // 心理咨询登录界面
#import "HLCitySelectorViewController.h" // 选择居住地

@interface HDLoginController ()<UITextFieldDelegate,HLLoginViewDeleagte>
{
    NSArray *cycleImageArr;
}
@property (nonatomic, strong) HLLoginView *loginView;
@property (nonatomic, strong) HLUser *userInfo;

@end

@implementation HDLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    
    
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UILabel *lab = [[UILabel alloc] init];
    lab.frame = CGRectMake(0, 0, 0, 44);
    lab.text = @"学生家长";
    
    self.sc_navigationBar.titleView = lab;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToAuthPhoneAction:) name:LoginNeedBindPhoneNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissVC) name:DismissLoginView object:nil];
    [self loginView];
    
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:NO completion:nil];
    
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
    
    [self.view showLoading];

    if (![NSString isValidateTelNumber:self.loginView.phoneTextField.text])//没有通过正则表达式
    {
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
        return;
    }
    if (self.loginView.secretTextField.text.length==0){
        [self.view showTostWithMessage:@"请输入密码!"];
        return;
        
    }
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLLOGIN withDictionary:@{@"mobile":self.loginView.phoneTextField.text,@"password":self.loginView.secretTextField.text,@"device":[[UIDevice currentDevice] deviceModelName]} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~!~%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            // 登陆成功
            //保存是否需要自动登录
            [[LoginManager defaultManager] setIsLogin:YES];

            [[LoginManager defaultManager] setLoginType:NativeLogin]; //手机密码登录
            
            weakSelf.userInfo = [HLUser mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];

            
            [[LoginManager defaultManager] setAccount:weakSelf.userInfo.username]; // 用户名
            [[LoginManager defaultManager] setPassword:weakSelf.userInfo.password]; // 密码
            [[LoginManager defaultManager] setUserid:weakSelf.userInfo.userid]; // 用户id
            //保存最后登录的用户昵称
            [[LoginManager defaultManager] setNickName:weakSelf.userInfo.nickname];
            [[LoginManager defaultManager] setToken:[dictionary[@"data"] objectForKey:@"token"]];
            [[LoginManager defaultManager] setAvatar:weakSelf.userInfo.head];
            [[LoginManager defaultManager] setFans:weakSelf.userInfo.fans.length ? weakSelf.userInfo.fans : @"0"];
            [[LoginManager defaultManager] setFollows:weakSelf.userInfo.follow.length ? weakSelf.userInfo.follow : @"0"];
            [[LoginManager defaultManager] setBalance:weakSelf.userInfo.balance.length ? weakSelf.userInfo.balance : @"0.0"];
            
            [self requestCurrentUserInfoWithUid:[LoginManager defaultManager].userid];
            
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {

                    NSLog(@"添加别名成功");

                }

            } seq:0];
            
            // 登录极光IM
            [self loginJpush];
            
            // 通知相对界面需要刷新
//            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            
            // 是否需要完善信息
            [self loadRequest];

        }else{
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"登陆失败,请重新登陆"];
    }];
    
    
}

// 请求当前用户的信息
- (void)requestCurrentUserInfoWithUid:(NSString *)uid{
    
    NSDictionary *params = @{
        @"uid":uid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLGET_UserINFO withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            NSLog(@"~~~~~%@",dictionary[@"data"][@"memberdata"]);
            
            [[LoginManager defaultManager] setMemberdata:dictionary[@"data"][@"memberdata"]];
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:error.localizedDescription];
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
            // 1 已经完善  0 需要去完善
            if (![[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) {
                [weakSelf pushUserDetailInfo];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            }
        }
    } failure:^(NSError * _Nonnull error) {

    }];

}
// 是否需要先完善个人信息
- (void)pushUserDetailInfo{
//    HLUserDetailInfoViewController *userDetailInfoVC = [[HLUserDetailInfoViewController alloc] init];
//    userDetailInfoVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:userDetailInfoVC animated:YES];
    
    //居住地
    HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
    citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
        
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"habitation":model.cityID
        };
        
        [kAppDelegate.window showLoading];
        [HLHTTPSessionManager postDataWithNSString:HLEdit_UserEVPI withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                [kAppDelegate.window hideLoading];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UpdateImageOrNickname object:nil];
                // 通知相对界面需要刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [kAppDelegate.window showErrorWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError * _Nonnull error) {
            [kAppDelegate.window showErrorWithMessage:error.localizedDescription];
        }];
        
    };
    citySelectVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:citySelectVC animated:YES];
        
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

    HLResetViewController *resetVC = [[HLResetViewController alloc] init];
    [self.navigationController pushViewController:resetVC animated:YES];
}
// 心理咨询界面
- (void)xinLiZiXunClick {
    MentalityController *vc = [[MentalityController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// qq登录
- (void)verityLoginButtonClick{
    [self dismisskeyBoard];

    [[HDThridLoginManager sharedManager] openQQ];

}

// 微信登录
- (void)wechatLoginButtonClick{
    [self dismisskeyBoard];

    [[HDThridLoginManager sharedManager] openWeixin];

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
    [HLHTTPSessionManager postDataWithNSString:HLThird_QQLOGIN withDictionary:@{@"openid":userid} success:^(NSDictionary * _Nonnull dictionary) {
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) { // 登录成功
            [self.view hideLoading];
            
            //保存是否需要自动登录
            [[LoginManager defaultManager] setIsLogin:YES];
            //三方登录
            [[LoginManager defaultManager] setLoginType:NeedBindAccount];
            //保存最后登录的手机号
            [[LoginManager defaultManager] setAccount:[dictionary[@"data"][@"data"] objectForKey:@"username"]];
            [[LoginManager defaultManager] setPassword:[dictionary[@"data"][@"data"] objectForKey:@"password"]]; // 密码
            [[LoginManager defaultManager] setUserid:[dictionary[@"data"][@"data"] objectForKey:@"id"]];
            //保存最后登录的用户昵称
            [[LoginManager defaultManager] setNickName:[dictionary[@"data"][@"data"] objectForKey:@"nickname"]];
            [[LoginManager defaultManager] setToken:[dictionary[@"data"][@"data"] objectForKey:@"token"]];
            [[LoginManager defaultManager] setAvatar:[dictionary[@"data"][@"data"] objectForKey:@"head"]];
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]];
            

            [self requestCurrentUserInfoWithUid:[LoginManager defaultManager].userid];
            
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                if (iResCode == 0) {
                    NSLog(@"qq添加别名成功");
                } else {
                    NSLog(@"qq添加别名失败");
                }

            } seq:0];
            
            
            if (![[dictionary[@"data"] objectForKey:@"type"] boolValue]) { // 为0时没有在后台注册, 进入绑定界面进行绑定
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginNeedBindPhoneNoti object:@{@"type":[dictionary[@"data"] objectForKey:@"in"],@"openid":userid}];
                
            } else {
                // 是否需要完善信息
                [self loadRequest];
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
