//
//  HLTabBarController.m
//  婚恋网
//
//  Created by iMac on 2019/2/28.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLTabBarController.h"
#import "HLLoginViewController.h"

#import "HLPhoneNumberLoginVC.h"

#import "HDThridLoginManager.h"
#import <AuthenticationServices/AuthenticationServices.h>

#import "HLNickNameViewController.h" // 昵称设置
#import "HLHeadViewController.h" // 头像设置
#import "HLSexViewController.h" // 性别设置
#import "HLBirthdayViewController.h" // 生日设置
#import "HLCityViewController.h" // 城市设置

#import "HLBindingViewController.h"


@interface HLTabBarController ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@property (strong, nonatomic) UIButton *phoneBtn;
@property (strong, nonatomic) UIView *bgBtsView;
@property (weak, nonatomic) UIView *customView;

@end

@implementation HLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加监听
    [self addNotification];
    
    [self setTabBarItemsTitle];
    
}

// 添加监听
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin) name:SHOWLOGIN object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isWanShan:) name:@"isWanShan" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToAuthPhoneAction:) name:LoginNeedBindPhoneNoti object:nil];
    
}

// 设置TabBarItem标题
- (void)setTabBarItemsTitle {
    
    NSArray *titles = [NSArray arrayWithObjects:TabBarItemTitle1,TabBarItemTitle2,TabBarItemTitle3,TabBarItemTitle4, nil];
    
    for (int i=0; i<titles.count; i++) {
        UITabBarItem *item = [[self.viewControllers objectAtIndex:i] tabBarItem];
        item.title = [titles objectAtIndex:i];
    }
    
}


- (void)showLogin{
    
    [[LoginManager defaultManager] doLogout];
    
    //告诉服务器，我退出登录
    //    [VKHTTPSessionManager userLogoutActionsuccess:nil failure:nil];
    
    
//    HLLoginViewController*loginVC = [[HLLoginViewController alloc] init];
//    HXNavigationController *nvc = [[HXNavigationController alloc]initWithRootViewController:loginVC];
//    // 解决 ios13 presentViewController不能铺满全屏
//    nvc.modalPresentationStyle = 0;
//    [self presentViewController:nvc animated:YES completion:^{
//        
//    }];
    
    [self customFullScreenUI];
    
    
    [self.view showLoadMessageAtCenter];
    [JVERIFICATIONService getAuthorizationWithController:self hide:NO animated:YES timeout:5*1000 completion:^(NSDictionary *result) {
        NSLog(@"一键登录 result:%@", result);
        [self.view hide];
        
        if ([[result[@"code"] stringValue] isEqualToString:@"6000"]) {
            [self loginClickWithLoginToken:result[@"loginToken"]];
        }
        else if ([[result[@"code"] stringValue] isEqualToString:@"6002"]) {
            // 退出登录界面
        }
        else {
            
            HLPhoneNumberLoginVC *mvc = [[HLPhoneNumberLoginVC alloc] init];
            mvc.isPhoneNum = YES;
            
            HXNavigationController *nvc = [[HXNavigationController alloc] initWithRootViewController:mvc];
            nvc.modalPresentationStyle = 0;
            [self presentViewController:nvc animated:YES completion:nil];
        }
        
    } actionBlock:^(NSInteger type, NSString *content) {
        NSLog(@"一键登录 actionBlock :%ld %@", (long)type , content);
        
        if (type == 1) { // 授权页关闭
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
        }
        
    }];
}

- (UIButton *)phoneBtn {
    if (!_phoneBtn) {
        _phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneBtn addTarget:self action:@selector(phoneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_phoneBtn setTitle:@"手机号登录" forState:UIControlStateNormal];
        [_phoneBtn setTitleColor:[UIColor colorWithRed:143/255.0 green:143/255.0 blue:151/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    }
    
    return _phoneBtn;
}

- (void)phoneBtnClick:(id)sender{
    
    [self.view hide];
    
    UIViewController *vc =  [self topViewController];
    
    HLPhoneNumberLoginVC *mvc = [[HLPhoneNumberLoginVC alloc] init];
    
    [vc.navigationController pushViewController:mvc animated:YES];
    
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PhoneNumberLoginViewController *phoneVC =  [story instantiateViewControllerWithIdentifier:@"PhoneNumberLoginViewController"];
//    [vc.navigationController pushViewController:phoneVC animated:YES];
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

/*设置全屏样式UI*/
- (void)customFullScreenUI{
    
    JVUIConfig *config = [[JVUIConfig alloc] init];
    config.navReturnImg = [UIImage imageNamed:@"back"];
    config.navCustom = NO;
    config.shouldAutorotate = NO;
    config.autoLayout = YES;
    
    config.navColor = [UIColor whiteColor];
    config.sloganTextColor = [UIColor colorWithRed:187/255.0 green:188/255.0 blue:197/255.0 alpha:1/1.0];
    
    config.navReturnHidden = NO;
    config.privacyTextFontSize = 12;
    
    //    config.navColor = [UIColor redColor];
    //    config.navBarBackGroundImage = [UIImage imageNamed:@"cmccLogo"];
    config.privacyTextAlignment = NSTextAlignmentLeft;
    //    config.numberFont = [UIFont systemFontOfSize:10];
    //    config.logBtnFont = [UIFont systemFontOfSize:5];
    //    config.privacyShowBookSymbol = YES;
    //    config.privacyLineSpacing = 5;
    //    config.agreementNavBackgroundColor = [UIColor redColor];
    //    config.sloganFont = [UIFont systemFontOfSize:30];
    //    config.checkViewHidden = YES;
    config.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    /*
    config.customLoadingViewBlock = ^(UIView *View) {
        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:View animated:YES];
        hub.backgroundColor = [UIColor clearColor];
        hub.label.text = @"正在登录..";
        [hub showAnimated:YES];
    };
    */
    
    /*
    config.customPrivacyAlertViewBlock = ^(UIViewController *vc) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请点击同意协议" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [vc presentViewController:alert animated:true completion:nil];
    };
     */
    
    
    //logo
    config.logoImg = [UIImage imageNamed:@"cmccLogo"];
    CGFloat logoWidth = 76;
    CGFloat logoHeight = logoWidth;
    JVLayoutConstraint *logoConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *logoConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeTop multiplier:1 constant:76];
    JVLayoutConstraint *logoConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:logoWidth];
    JVLayoutConstraint *logoConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:logoHeight];
    config.logoConstraints = @[logoConstraintX,logoConstraintY,logoConstraintW,logoConstraintH];
    
    
    
    //号码栏
    JVLayoutConstraint *numberConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *numberConstraintY = [JVLayoutConstraint constraintWithAttribute: NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemLogo attribute:NSLayoutAttributeBottom multiplier:1 constant:16];
    JVLayoutConstraint *numberConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:130];
    JVLayoutConstraint *numberConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:25];

    config.numberConstraints = @[numberConstraintX,numberConstraintY,numberConstraintW,numberConstraintH];
    
    //slogan展示
    JVLayoutConstraint *sloganConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *sloganConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNumber attribute:NSLayoutAttributeBottom   multiplier:1 constant:8];
    JVLayoutConstraint *sloganConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:130];
    JVLayoutConstraint *sloganConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:20];
    
    config.sloganConstraints = @[sloganConstraintX,sloganConstraintY,sloganConstraintW,sloganConstraintH];
    
    
    //登录按钮
    UIImage *login_nor_image = [self imageNamed:@"loginBtn_Nor"];
    UIImage *login_dis_image = [self imageNamed:@"loginBtn_Dis"];
    UIImage *login_hig_image = [self imageNamed:@"loginBtn_Hig"];
    if (login_nor_image && login_dis_image && login_hig_image) {
        config.logBtnImgs = @[login_nor_image, login_dis_image, login_hig_image];
    }
    CGFloat loginButtonWidth = login_nor_image.size.width?:100;
    CGFloat loginButtonHeight = login_nor_image.size.height?:100;
    JVLayoutConstraint *loginConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *loginConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSlogan attribute:NSLayoutAttributeBottom multiplier:1 constant:22];
    JVLayoutConstraint *loginConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:loginButtonWidth];
    JVLayoutConstraint *loginConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:loginButtonHeight];
    config.logBtnConstraints = @[loginConstraintX,loginConstraintY,loginConstraintW,loginConstraintH];
    config.logBtnHorizontalConstraints = config.logBtnConstraints;
    
    //勾选框
    
    UIImage * uncheckedImg = [UIImage imageNamed:@"checkBox_unSelected"];
    UIImage * checkedImg = [UIImage imageNamed:@"checkBox_selected"];
    CGFloat checkViewWidth = 11;
    CGFloat checkViewHeight = 11;
    CGFloat spacing = (kScreenWidth - 300)/2;

    config.uncheckedImg = uncheckedImg;
    config.checkedImg = checkedImg;
    JVLayoutConstraint *checkViewConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeRight multiplier:1 constant:spacing];
    JVLayoutConstraint *checkViewConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemPrivacy attribute:NSLayoutAttributeBottom multiplier:1 constant:-20];
    
    JVLayoutConstraint *checkViewConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:checkViewWidth];
    JVLayoutConstraint *checkViewConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:checkViewHeight];
    config.checkViewConstraints = @[checkViewConstraintX,checkViewConstraintY,checkViewConstraintW,checkViewConstraintH];
    //隐私
    config.privacyState = YES;
    config.privacyTextFontSize = 11;
    config.privacyTextAlignment = NSTextAlignmentCenter;
    config.appPrivacyColor = @[[UIColor colorWithRed:187/255.0 green:188/255.0 blue:197/255.0 alpha:1/1.0],[UIColor colorWithRed:137/255.0 green:152/255.0 blue:255/255.0 alpha:1/1.0]];
    
    JVLayoutConstraint *privacyConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *privacyConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:400];

    JVLayoutConstraint *privacyConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeBottom multiplier:1 constant:-25];
    JVLayoutConstraint *privacyConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:14];
    
    
    config.privacyConstraints = @[privacyConstraintX,privacyConstraintW,privacyConstraintY,privacyConstraintH];
    
    JVLayoutConstraint *privacyConstraintY1 = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeBottom multiplier:1 constant:-16];

    config.privacyHorizontalConstraints = @[privacyConstraintX,privacyConstraintW,privacyConstraintH,privacyConstraintY1];
    
    //loading
    JVLayoutConstraint *loadingConstraintX = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    JVLayoutConstraint *loadingConstraintY = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemSuper attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    JVLayoutConstraint *loadingConstraintW = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeWidth multiplier:1 constant:30];
    JVLayoutConstraint *loadingConstraintH = [JVLayoutConstraint constraintWithAttribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:JVLayoutItemNone attribute:NSLayoutAttributeHeight multiplier:1 constant:30];
    config.loadingConstraints = @[loadingConstraintX,loadingConstraintY,loadingConstraintW,loadingConstraintH];
    /*
     设置一键登录页gif背景
     config.authPageGifImagePath = [[NSBundle mainBundle] pathForResource:@"auth" ofType:@"gif"];
     */
    
    /*
     设置一键登录页视频背景
     NSString *urlStr = @"http://video01.youju.sohu.com/88a61007-d1be-4e82-8d74-2b87ba7797f72_0_0.mp4";
     [config setVideoBackgroudResource:urlStr placeHolder:@"cmBackground.jpeg"];
     **/
    
    /*
     config.authPageBackgroundImage = [UIImage imageNamed:@"背景图"];
     config.navColor = [UIColor redColor];
     config.preferredStatusBarStyle = 0;
     config.navText = [[NSAttributedString alloc] initWithString:@"自定义标题"];
     config.navReturnImg = [UIImage imageNamed:@"自定义返回键"];
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(0, 0, 44, 44);
     button.backgroundColor = [UIColor greenColor];
     config.navControl = [[UIBarButtonItem alloc] initWithCustomView:button];
     config.logoHidden = NO;
     config.logBtnText = @"自定义登录按钮文字";
     config.logBtnTextColor = [UIColor redColor];
     config.numberColor = [UIColor blueColor];
     config.appPrivacyOne = @[@"应用自定义服务条款1",@"https://www.jiguang.cn/about"];
     config.appPrivacyTwo = @[@"应用自定义服务条款2",@"https://www.jiguang.cn/about"];
     config.privacyComponents = @[@"文本1",@"文本2",@"文本3",@"文本4"];
     config.appPrivacyColor = @[[UIColor redColor], [UIColor blueColor]];
     config.sloganTextColor = [UIColor redColor];
     config.navCustom = NO;
     config.numberSize = 24;
     config.privacyState = YES;
     */
    //隐私协议添加下划线
    [config addPrivacyTextAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range: NSMakeRange(5, 10)];

    [JVERIFICATIONService customUIWithConfig:config customViews:^(UIView *customAreaView) {
        
        
        self.customView = customAreaView;
        UIView *btnsView = [self btnsView];
        self.bgBtsView = btnsView;
        [self caculateCustomUIFrame];
        [customAreaView addSubview:self.phoneBtn];
        [customAreaView addSubview:btnsView];
         
        
    }];
    
}

- (void)caculateCustomUIFrame{
    if (!self.customView) {
        return;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    NSLog(@"customView:%@,orientation:%ld",self.customView,(long)[UIDevice currentDevice].orientation);
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGFloat x = (width - 78)/2;
        CGFloat y = height - 320;
        if(height > 736){
            y = height - 546;
        }else if(height == 736 ){
            y = height - 380;
        }
        CGFloat statBarItemHeight = 49+35;
        if (@available(iOS 11.0, *)) {
            statBarItemHeight  += self.view.safeAreaInsets.bottom;
        }
        self.phoneBtn.frame = CGRectMake(x, 320, 78 , 18);
        self.bgBtsView.frame = CGRectMake((width-300)/2, 320+18+80, 300, 67);
        
        self.phoneBtn.hidden = NO;

    }else{
        
        self.phoneBtn.hidden = YES;
        self.phoneBtn.frame = CGRectMake(0, 0, 78, 18);
        self.bgBtsView.frame = CGRectMake((width-300)/2, height-67-65, 300, 67);
    }
}

- (UIView*)btnsView{
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 67)];
    NSArray *imgs = @[@"qq",@"qq",@"wechat"];
    CGFloat width = 32 , height = 32;
    CGFloat padding = 21;
    CGFloat orgX = (300 - width *3 - padding*2)/2;
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
    return btnView;
}

- (void)thirdPatyLogin:(UIButton*)sender{

    switch (sender.tag) {
        case 10: // 苹果登录占位
            {
                
            }
                break;
        case 11: // QQ
            {
                [[HDThridLoginManager sharedManager] openQQWithNumber:NO];
                
            }
                break;
        case 12:// 微信
            {
                [[HDThridLoginManager sharedManager] openWeixinWithBind:NO isNumber:NO];
            }
                break;
        default:
            break;
    }
    
}

- (UIImage *)imageNamed:(NSString *)imageName{
    if (![imageName isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JVerificationResource" ofType:@"bundle"];
    UIImage *image= [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",imageName]]];
    return image;
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
            
            [[LoginManager defaultManager] setBirthday:dictionary[@"data"][@"birthday"]]; // 生日
            [[LoginManager defaultManager] setHabitation:dictionary[@"data"][@"habitation"]]; // 所在地
            
            [[LoginManager defaultManager] setBalance:dictionary[@"data"][@"balance"]]; // 余额
            
            if (kISNullObject(dictionary[@"data"][@"member"]) || ![self checkProductDate:dictionary[@"data"][@"member"]]) {
                [[LoginManager defaultManager] setIsVip:NO];
            } else {
                [[LoginManager defaultManager] setIsVip:YES];
            }
            
            
            
            // 获取咨询师信息
            [self requestData];
            
            // 设置别名
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {

                    NSLog(@"添加别名成功");

                }

            } seq:0];
            
            // 是否需要完善信息
            [self isWanShan:nil];
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}

// 获取用户信息
- (void)requestData {
    
    if (kISNullObject([LoginManager defaultManager].userid)) {
        return;
    }
    
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
                [self isWanShan:nil];
            }
            
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:@"登陆失败,请重新登陆"];
    }];

}

//跳到授权界面去绑定手机号
- (void)jumpToAuthPhoneAction:(NSNotification *)notify{
    HLBindingViewController *authenVC = [[HLBindingViewController alloc] init];
    // 绑定类型
    NSDictionary * infoDic = [notify object];
    authenVC.type = [infoDic valueForKey:@"type"];
    authenVC.openID = [infoDic valueForKey:@"openid"];
    
    UIViewController *vc =  [self topViewController];
    [vc.navigationController pushViewController:authenVC animated:YES];
}

// 是否完善
- (void)isWanShan:(NSNotification *)notifi {
    
    NSLog(@"%@",[LoginManager defaultManager].nickName);
    NSLog(@"%@",[LoginManager defaultManager].avatar);
    NSLog(@"%@",[LoginManager defaultManager].gender);
    NSLog(@"%@",[LoginManager defaultManager].birthday);
    NSLog(@"%@",[LoginManager defaultManager].habitation);
    
    UIViewController *theVC = [self topViewController];
    
    // 是否需要完善信息
    if (kISNullObject([LoginManager defaultManager].nickName)) {
        HLNickNameViewController *vc = [[HLNickNameViewController alloc] init];
        [theVC.navigationController pushViewController:vc animated:YES];
    } else {
        
        if (kISNullObject([LoginManager defaultManager].avatar)) {
            HLHeadViewController *vc = [[HLHeadViewController alloc] init];
            [theVC.navigationController pushViewController:vc animated:YES];
        } else {
            
            if (kISNullObject([LoginManager defaultManager].gender)) {
                HLSexViewController *vc = [[HLSexViewController alloc] init];
                [theVC.navigationController pushViewController:vc animated:YES];
            } else {
                
                if (kISNullObject([LoginManager defaultManager].birthday)) {
                    HLBirthdayViewController *vc = [[HLBirthdayViewController alloc] init];
                    [theVC.navigationController pushViewController:vc animated:YES];
                } else {
                    
                    if (kISNullObject([LoginManager defaultManager].habitation)) {
                        HLCityViewController *vc = [[HLCityViewController alloc] init];
                        [theVC.navigationController pushViewController:vc animated:YES];
                    } else {
                        
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"WELCOME_iMG" object:nil];
                        
                        
                        if ([notifi.object boolValue]) {
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"PHONE_LOGIN_OUT" object:nil];
                            
                        } else {
                            [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}


#pragma mark - ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    // 返回一个 window，present 登录界面需要用到
    return [UIApplication sharedApplication].delegate.window;
}

#pragma mark AppleIDLogin end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
