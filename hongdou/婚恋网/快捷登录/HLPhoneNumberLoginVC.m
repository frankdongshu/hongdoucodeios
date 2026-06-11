//
//  HLPhoneNumberLoginVC.m
//  hongdou
//
//  Created by 李龙 on 2021/5/6.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLPhoneNumberLoginVC.h"
#import "HLCodeNumberVC.h"
#import <AuthenticationServices/AuthenticationServices.h>
#import "HDThridLoginManager.h"


@interface HLPhoneNumberLoginVC ()<UITextFieldDelegate,ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation HLPhoneNumberLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popClick) name:@"PHONE_LOGIN_OUT" object:nil];
    
    
    // 其他登录
    [self btnsView];
    
}

-(void)popClick {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (void)logOut {
    
    [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
    
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnsView {
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nextBtn.frame)+100, kScreenWidth, 67)];
    NSArray *imgs = @[@"qq",@"qq",@"wechat"];
    CGFloat width = 32 , height = 32;
    CGFloat padding = 21;
    CGFloat orgX = (kScreenWidth - width *3 - padding*2)/2;
    for (int i = 0; i < imgs.count; i++) {
        
        if (i == 0) {
            if (@available(iOS 13.0, *)) {

                ASAuthorizationAppleIDButton *signInButton = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeSignIn style:ASAuthorizationAppleIDButtonStyleBlack];

                signInButton.frame = CGRectMake(orgX + i*width + i*padding, 0, width, height);

                signInButton.layer.masksToBounds = YES;
                signInButton.layer.cornerRadius = 16;

                [signInButton addTarget:self action:@selector(signInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [btnView addSubview:signInButton];
                
            }
            
            continue;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 10;
        [btn setImage:[UIImage imageNamed:imgs[i]] forState:UIControlStateNormal];
        btn.frame = CGRectMake(orgX + i*width + i*padding, 0, width, height);
        [btn addTarget:self action:@selector(thirdPatyLogin:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:btn];
    }
    [self.view addSubview:btnView];
}

- (void)thirdPatyLogin:(UIButton*)sender{

    switch (sender.tag) {
        case 10: // 苹果登录占位
            {
                
            }
                break;
        case 11: // QQ
            {
                [[HDThridLoginManager sharedManager] openQQWithNumber:YES];
                
            }
                break;
        case 12:// 微信
            {
                [[HDThridLoginManager sharedManager] openWeixinWithBind:NO isNumber:YES];
            }
                break;
        default:
            break;
    }
    
}

- (IBAction)nextClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.phoneTF.text isMobileNumber]) {
        [MBProgressHUD showMessage:@"手机号错误" view:nil];
        return;
    }
    
    HLCodeNumberVC *vc = [[HLCodeNumberVC alloc] init];
    vc.phoneNumber = self.phoneTF.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return current.length <= 11;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
    
}

// 苹果账号登录触发方法
- (void)signInButtonClicked:(ASAuthorizationAppleIDButton *)signInButton  API_AVAILABLE(ios(13.0)) {
    
    //基于用户的Apple ID授权用户，生成用户授权请求的一种机制
    ASAuthorizationAppleIDProvider *provide = [[ASAuthorizationAppleIDProvider alloc] init];
    //创建新的AppleID 授权请求
    ASAuthorizationAppleIDRequest *request = provide.createRequest;
    //在用户授权期间请求的联系信息
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    //由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
    ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    //设置授权控制器通知授权请求的成功与失败的代理
    controller.delegate = self;
    //设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
    controller.presentationContextProvider = self;
    //在控制器初始化期间启动授权流
    [controller performRequests];
}

#pragma mark - ASAuthorizationControllerDelegate
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0))
{
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
    }
    NSLog(@"%@", errorMsg);
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0))
{
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *credential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        
        NSString *userID = credential.user;
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
        
        [self appleDidLoginWithIdentityToken:identityToken UserId:userID];
    }
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
            
            [[LoginManager defaultManager] setBirthday:dictionary[@"data"][@"data"][@"birthday"]]; // 生日
            [[LoginManager defaultManager] setHabitation:dictionary[@"data"][@"data"][@"habitation"]]; // 所在地
            
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]];
            
            if (kISNullObject(dictionary[@"data"][@"data"][@"member"]) || ![self checkProductDate:dictionary[@"data"][@"data"][@"member"]]) {
                [[LoginManager defaultManager] setIsVip:NO];
            } else {
                [[LoginManager defaultManager] setIsVip:YES];
            }
            
            // 获取咨询师信息
            [self requestData];
            
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
                
                // 是否需要完善信息
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isWanShan" object:[NSNumber numberWithBool:YES]];
            }
            
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:@"登陆失败,请重新登陆"];
    }];

}

// 获取用户信息
- (void)requestData {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/show" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/show: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            
            MyLogin *u = [MyLogin mj_objectWithKeyValues:dictionary[@"data"]];
            
            u.descr = dictionary[@"data"][@"description"]; // 因关键字冲突, 单独赋值
            u.sex = dictionary[@"data"][@"gender"];
            
            NSData *uData = [NSKeyedArchiver archivedDataWithRootObject:u];
            
            [[NSUserDefaults standardUserDefaults] setObject:uData forKey:Login_USER];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 获取已选课程
            [self requestSelect];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}

// 获取已选课程
- (void)requestSelect {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/get_coach_curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/get_coach_curriculum: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in dictionary[@"data"]) {
                for (NSDictionary *dic1 in dic[@"lists"]) {
                    [arr addObject:dic1[@"id"]];
                }
            }
            u.curriculum = arr; // 咨询类型, 取id
            
            [MyLogin updateUser:u];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    // 返回一个 window，present 登录界面需要用到
    return [UIApplication sharedApplication].delegate.window;
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
