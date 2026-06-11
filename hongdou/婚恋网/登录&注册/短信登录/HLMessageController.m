//
//  HLMessageController.m
//  hongdou
//
//  Created by 维康1 on 2020/9/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLMessageController.h"
#import "HLUserDetailInfoViewController.h"

@interface HLMessageController ()<UITextFieldDelegate> {
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;


//标志位
@property (nonatomic,assign)NSInteger volidationTime;//验证码获取时间;
//数据
@property (nonatomic,copy)NSString *volidationStr;//获取到的验证字符串

@end

@implementation HLMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.title = @"短信登录";
    
    
    [self.phoneTF textFileTitle:@"phone" leftWidth:20 heigth:55];
    [self.codeTF textFileTitle:@"mima" leftWidth:20 heigth:55];
    self.codeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
}

// 获取验证码
- (IBAction)codeBtnClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.phoneTF.text isMobileNumber]) {
        [MBProgressHUD showMessage:@"请输入正确的手机号码" view:nil];
    } else if (self.volidationTime != 0) {
        [MBProgressHUD showMessage:[NSString stringWithFormat:@"请在%ld秒后再点击发送按钮",(long)self.volidationTime] view:nil];
    } else {
        
        [MBProgressHUD showLoading];
        [HLHTTPSessionManager postDataWithNSString:HLSEND_CODE withDictionary:@{@"mobile":self.phoneTF.text} success:^(NSDictionary * _Nonnull dictionary) {
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                [MBProgressHUD hideLoading];
                
                self.volidationTime = 60;
                [self addTimerForMessage];
            } else {
                [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            }
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
    }
    
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
        self.codeBtn.titleLabel.text = titleStr;
        self.codeBtn.userInteractionEnabled = NO;
    }
    else
    {
        [self removeTimer];
        self.codeBtn.titleLabel.text = @"获取验证码";
        self.codeBtn.userInteractionEnabled = YES;
    }
}
- (void)removeTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

// 登录
- (IBAction)loginClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.phoneTF.text isMobileNumber]) {
        [MBProgressHUD showMessage:@"请输入正确手机号" view:nil];
        return;
    }
    if (self.codeTF.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入验证码" view:nil];
        return;
    }
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"mobile":self.phoneTF.text,
        @"sms":self.codeTF.text
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/smsLogon" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/smsLogon %@",dictionary);
        
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
            
            
            [self removeTimer];
            
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
            // 1 已经完善  0 需要去完善
            if (![[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) {
                [weakSelf pushUserDetailInfo];
            } else {
                
                // 登录极光IM
                [self loginJpush];
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                
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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 529) { // 限制手机输入字数
        return current.length <= 11;
    }
    
    return YES;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
    
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
