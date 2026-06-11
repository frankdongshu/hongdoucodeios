//
//  HLRegisterViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/14.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLRegisterViewController.h"
#import "HLSucessViewController.h"
#import "HLAuthenticationViewController.h"
#import "HDThridLoginManager.h"

#import "HLUserDetailInfoViewController.h" // 需要完善信息
#import "HLHTMLLableViewController.h"

@interface HLRegisterViewController ()<UITextFieldDelegate>
{
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *centerView;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextFile;
@property (weak, nonatomic) IBOutlet UITextField *verityTextFile;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFile;
@property (weak, nonatomic) IBOutlet UIButton *verityButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *backLable;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
//标志位
@property (nonatomic,assign)NSInteger volidationTime;//验证码获取时间;
//数据
@property (nonatomic,copy)NSString *volidationStr;//获取到的验证字符串

@property (nonatomic, strong) YYLabel *loginProtocol;

@end

@implementation HLRegisterViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    //    self.sc_navigationBar.title = @"注册";
    
    [self initContollerView];
    [self createNavig];
    
    [self createProtocol];
    
}

// 协议阅读
- (void)createProtocol {
    
    __weak typeof(self) weakSelf = self;
    
    _loginProtocol = ({
        _loginProtocol = [[YYLabel alloc]  init];
        
        NSString *mianZe = @"免责声明";
        NSString *yinSi = @"隐私政策";
        
        NSString *context = [NSString stringWithFormat:@"登录即同意红豆佳缘 %@ 和 %@",yinSi,mianZe];
        
        NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:context];
        lawTitle.font = [UIFont systemFontOfSize:14];
        
        [lawTitle setTextHighlightRange:[context rangeOfString:mianZe] color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
            htmlVC.navTitle = @"免责声明";
            htmlVC.type = @"disclaimer";
            [self.navigationController pushViewController:htmlVC animated:YES];
            
            
        }];
        
        [lawTitle setTextHighlightRange:[context rangeOfString:yinSi] color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
            htmlVC.navTitle = @"隐私政策";
            htmlVC.type = @"privacy";
            [self.navigationController pushViewController:htmlVC animated:YES];
            
        }];
        
        
        _loginProtocol.attributedText = lawTitle;
        [_loginProtocol setTextAlignment:NSTextAlignmentCenter];
        [self.bottomView addSubview:_loginProtocol];
        [_loginProtocol mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.bottomView.mas_left);
            make.right.equalTo(weakSelf.bottomView.mas_right);
            make.bottom.equalTo(weakSelf.bottomView.mas_bottom).offset(-20.f);
            make.height.mas_equalTo(@(18.f));
            make.width.mas_offset(weakSelf.bottomView.width);
        }];
        _loginProtocol;
    });
    
}


- (void)createNavig{
    UILabel *titleLbale = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, 44)];
    titleLbale.text =@"注册";
    titleLbale.textAlignment = NSTextAlignmentCenter;
    titleLbale.font = [UIFont systemFontOfSize:17];
    titleLbale.backgroundColor = [UIColor clearColor];
    titleLbale.textColor = [UIColor whiteColor];
    self.sc_navigationBar.titleView = titleLbale;
}
- (void)initContollerView{
    [_headerView az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:189/255.0 green:100/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:130/255.0 green:92/255.0 blue:244/255.0 alpha:1.0]] locations:@[@(0.0),@(0.7),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    _centerView.layer.shadowOffset =CGSizeMake(0,1);
    [_phoneTextFile textFileTitle:@"phone" leftWidth:14 heigth:55];
    _phoneTextFile.delegate = self;
    _phoneTextFile.tag = 529;
    [_verityTextFile textFileTitle:@"mima" leftWidth:14 heigth:55];
    self.verityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.verityButton.titleLabel.text = @"获取验证码";
    self.verityButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_passwordTextFile textFileTitle:@"suo" leftWidth:14 heigth:55];
    _passwordTextFile.delegate = self;
    _passwordTextFile.tag = 530;
    [_registerButton az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:153/255.0 green:95/255.0 blue:248/255.0 alpha:1.0],[UIColor colorWithRed:93/255.0 green:87/255.0 blue:237/255.0 alpha:1.0]] locations:@[@(0.0),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"已有账号去登陆"];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, str.length)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backClick)];
    [_backLable addGestureRecognizer:tap];
    _backLable.attributedText = str;
}

#pragma mark 点击事件
- (void)backClick{
    [self removeTimer];
    [self.navigationController popViewControllerAnimated:YES];
}
// 发送验证码事件
- (IBAction)sendVolitionClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.phoneTextFile.text isValidateTelNumber]) {
        [MBProgressHUD showMessage:@"请输入正确的手机号码" view:nil];
        
    } else if (self.volidationTime != 0) {
        [MBProgressHUD showMessage:[NSString stringWithFormat:@"请在%ld秒后再点击发送按钮",(long)self.volidationTime] view:nil];
    } else {
        
        [MBProgressHUD showLoading];
        [HLHTTPSessionManager postDataWithNSString:HLSEND_CODE withDictionary:@{@"mobile":self.phoneTextFile.text,@"type":@"1"} success:^(NSDictionary * _Nonnull dictionary) {
            if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
                [MBProgressHUD hideLoading];
                
                NSLog(@"%@",dictionary);
                
                self.volidationTime = 60;
                [self addTimerForMessage];
//                [weakSelf getCaptcha];
                
            } else {
                [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            }
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    //    weakSelf.volidationStr = [dictionary objectForKey:@"code"];//保存验证
}

- (void)getCaptcha{
    WeakSelf(weakSelf);
    
    [HLHTTPSessionManager postDataWithNSString:HLSEE_CODE withDictionary:@{@"mobile":self.phoneTextFile.text} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.volidationTime = 60;
            [self addTimerForMessage];
            weakSelf.volidationStr = [dictionary[@"data"] objectForKey:@"captcha"];
            weakSelf.verityTextFile.text = self.volidationStr;
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

// 注册事件
- (IBAction)registerClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.phoneTextFile.text isValidateTelNumber]) {
        [MBProgressHUD showMessage:@"请输入正确的手机号码" view:nil];
        
    } else if (self.verityTextFile.text.length < 1) {
        [MBProgressHUD showMessage:@"请输入验证码" view:nil];

    } else if (self.passwordTextFile.text.length < 6 || self.passwordTextFile.text.length > 12) {
        [MBProgressHUD showMessage:@"请输入6-12位密码" view:nil];

    } else {
        
        [MBProgressHUD showLoading];
        
        NSDictionary *params = @{
            @"mobile":self.phoneTextFile.text,
            @"sms":self.verityTextFile.text,
            @"password":self.passwordTextFile.text,
            @"device":[[UIDevice currentDevice] deviceModelName]
        };
        
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLREGISTER withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/index/register %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                [MBProgressHUD hideLoading];
                
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                
                [[LoginManager defaultManager] setUserid:dictionary[@"data"][@"id"]];
                [[LoginManager defaultManager] setToken:dictionary[@"data"][@"token"]];
                
                [[LoginManager defaultManager] setAccount:dictionary[@"data"][@"username"]];
                
                
                // 通知相对界面需要刷新
//                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                // 是否完善信息
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"isPerfectInfo" object:nil];
                
                [weakSelf removeTimer];
                
                // 是否需要完善信息
                [self loadRequest];

            } else {
                [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            }
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
    }
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
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
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



// QQ登录
- (IBAction)qqLoginClick:(id)sender {
    // 登录成功后  绑定手机号
//    HLAuthenticationViewController *authVC  = [[HLAuthenticationViewController alloc] init];
//    [self.navigationController pushViewController:authVC animated:YES];
    
    [[HDThridLoginManager sharedManager] openQQWithNumber:NO];
}
//微信登录
- (IBAction)wechatLoginClick:(id)sender {
    // 登录成功后  绑定手机号
//    HLAuthenticationViewController *authVC  = [[HLAuthenticationViewController alloc] init];
//    [self.navigationController pushViewController:authVC animated:YES];
    
    [[HDThridLoginManager sharedManager] openWeixinWithBind:NO isNumber:NO];
}

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
        self.verityButton.titleLabel.text = titleStr;
        self.verityButton.userInteractionEnabled = NO;
        self.verityButton.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        [self removeTimer];
        self.verityButton.titleLabel.text = @"获取验证码";
        self.verityButton.userInteractionEnabled = YES;
        self.verityButton.backgroundColor = kRGBA(143, 108, 245, 1);
    }
}
- (void)removeTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark 取消键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_phoneTextFile.isFirstResponder || _verityTextFile.isFirstResponder || _passwordTextFile.isFirstResponder) {
        [_phoneTextFile resignFirstResponder];
        [_passwordTextFile resignFirstResponder];
        [_verityTextFile resignFirstResponder];
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
