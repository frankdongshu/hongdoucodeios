//
//  HLBindingViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/24.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLBindingViewController.h"
#import "HLBindingSucesseViewController.h"
#import "HLCenterView.h"

@interface HLBindingViewController ()<HLCenterViewDeleagte,UITextFieldDelegate>
{
    NSTimer *timer;
}

@property (nonatomic, strong) UILabel *titleLbale;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong)HXBarButtonItem *leftBarItem;

@property (nonatomic, strong) HLCenterView *centerView;

@property ( nonatomic , strong) HLUser *userInfo;

//标志位
@property (nonatomic,assign)NSInteger volidationTime;//验证码获取时间;
//数据
@property (nonatomic,copy)NSString *volidationStr;//获取到的验证字符串


// 切换绑定已有账号
@property (nonatomic, strong) UIButton *switchBindBtn;
// 跳过
@property (nonatomic, strong) UIButton *skipBtn;

@end

@implementation HLBindingViewController

- (UIButton *)skipBtn {
    if (!_skipBtn) {
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipBtn.frame = CGRectMake(15, CGRectGetMaxY(self.centerView.sureButton.frame)+30, 100, 30);
        [_skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [_skipBtn setTitleColor:kRGBA(141, 100, 240, 1) forState:UIControlStateNormal];
        [_skipBtn addTarget:self action:@selector(skipClick) forControlEvents:UIControlEventTouchUpInside];
        _skipBtn.titleLabel.font = kFontSize(14);
    }
    return _skipBtn;
}

- (UIButton *)switchBindBtn {
    if (!_switchBindBtn) {
        _switchBindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchBindBtn.frame = CGRectMake(CGRectGetMaxX(self.skipBtn.frame)+10, CGRectGetMaxY(self.centerView.sureButton.frame)+30, 200, 30);
        [_switchBindBtn setTitle:@"绑定已注册手机号" forState:UIControlStateNormal];
        [_switchBindBtn setTitleColor:kRGBA(141, 100, 240, 1) forState:UIControlStateNormal];
        [_switchBindBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
        _switchBindBtn.titleLabel.font = kFontSize(14);
    }
    return _switchBindBtn;
}

- (void)switchClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        self.titleLbale.text = @"绑定已注册手机号";
        [_switchBindBtn setTitle:@"绑定手机号" forState:UIControlStateNormal];
        self.centerView.passwordTF.hidden = YES;
        
    } else {
        self.titleLbale.text = @"绑定手机号";
        [_switchBindBtn setTitle:@"绑定已注册手机号" forState:UIControlStateNormal];
        self.centerView.passwordTF.hidden = NO;
    }
    
}

// 跳过
- (void)skipClick {
    
    NSDictionary *params = @{
        @"openid":self.openID,
        @"in":self.type
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/index/direct" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self removeTimer];
            
            [[LoginManager defaultManager] setIsLogin:YES];
            [[LoginManager defaultManager] setIsEditInfo:YES];
                            
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
            
            // 通知相对界面需要刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            
            [weakSelf removeTimer];
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [weakSelf.view showTostWithMessage:@"请求失败, 请重试"];
    }];
    
}

- (void)loadView{
    [super loadView];
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        [self removeTimer];
        [[LoginManager defaultManager] doLogout];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    
    [self createView];
    
}
- (void)createView{
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth/75*41)];
    [self.headerView az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:189/255.0 green:100/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:130/255.0 green:92/255.0 blue:244/255.0 alpha:1.0]] locations:@[@(0.0),@(0.7),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    [self.view addSubview:self.headerView];
    
    self.titleLbale = [[UILabel alloc] initWithFrame:CGRectMake(80, kStatusBarHeight, kScreenWidth - 160, 44)];
    self.titleLbale.text = @"绑定手机号";
    self.titleLbale.textAlignment = NSTextAlignmentCenter;
    self.titleLbale.font = [UIFont systemFontOfSize:17];
    self.titleLbale.backgroundColor = [UIColor clearColor];
    self.titleLbale.textColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLbale];
    
    self.centerView = [HLCenterView initWithXib:CGRectMake(0, 102, kScreenWidth, 350) delegate:self];
    [self.centerView addSubview:self.skipBtn];
    [self.centerView addSubview:self.switchBindBtn];
    [self.view addSubview:_centerView];
}
#pragma mark click
// 发送验证码
- (void)verityButtonClick{
    
    if (![NSString isValidateTelNumber:self.centerView.phoneNumberTF.text])//没有通过正则表达式
    {
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
    }
    else if (self.volidationTime != 0)
    {
        [self.view showTostWithMessage:[NSString stringWithFormat:@"请在%ld秒后再点击发送按钮",(long)self.volidationTime]];
    }
    else {
        
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLSEND_CODE withDictionary:@{@"mobile":self.centerView.phoneNumberTF.text} success:^(NSDictionary * _Nonnull dictionary) {
            if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
                                
                self.volidationTime = 60;
                [self addTimerForMessage];
                
            }else{
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"获取验证码失败,请重新获取"];
        }];
        
        
    }
    
}
// 获取验证码
- (void)getCaptcha{
    WeakSelf(weakSelf);
    
    [HLHTTPSessionManager postDataWithNSString:HLSEE_CODE withDictionary:@{@"mobile":self.centerView.phoneNumberTF.text} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.volidationTime = 60;
            [self addTimerForMessage];
            weakSelf.volidationStr = [dictionary[@"data"] objectForKey:@"captcha"];
            weakSelf.centerView.verityTF.text = self.volidationStr;
        }else{
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"获取验证码失败,请重新获取"];
    }];
}


// 绑定点击事件
- (void)sureButtonClick{
    
    
    if (![NSString isValidateTelNumber:self.centerView.phoneNumberTF.text]) {
        
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
        
    } else if (kISNullString(self.centerView.verityTF.text)) {
        
        [self.view showTostWithMessage:@"请输入验证码"];
        
    } else if (kISNullString(self.centerView.passwordTF.text) && !self.switchBindBtn.selected) {
        
        [self.view showTostWithMessage:@"请输入密码!"];
        
    } else {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
            @"mobile":self.centerView.phoneNumberTF.text,
            @"sms":self.centerView.verityTF.text,
            @"openid":self.openID,
            @"in":self.type
        }];
        
        if (!self.switchBindBtn.selected) {
            [params setValue:self.centerView.passwordTF.text forKey:@"password"];
        }
        
        NSLog(@"%@",params);
        
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLBINDIN_PHONE withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"- - - - - - - %@",dictionary);
            
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                [self removeTimer];
//                // 绑定成功
                // 注册成功
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                [[LoginManager defaultManager] setIsEditInfo:YES];
                
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

                
                // 通知相对界面需要刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                
                [weakSelf removeTimer];
                [weakSelf.navigationController popToRootViewControllerAnimated:NO];

            }else{
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"获取验证码失败,请重新获取"];
        }];
    }
    
}

#pragma mark NSTimer
//定时器 60S  不让用户一直获取验证码
-(void)addTimerForMessage
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)timerAction:(NSTimer *)timer
{
    NSLog(@"_____1");
    if (self.volidationTime != 0)
    {
        self.volidationTime = self.volidationTime - 1;
        NSString *titleStr = [NSString stringWithFormat:@"%ld秒",(long)self.volidationTime];
        self.centerView.verityBtn.titleLabel.text = titleStr;
    }
    else
    {
        [self removeTimer];
        self.centerView.verityBtn.titleLabel.text = @"获取验证码";
        
    }
}
- (void)removeTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 529) { // 限制手机输入字数
        return current.length <= 11;
    }
    
    
    return YES;
    
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
