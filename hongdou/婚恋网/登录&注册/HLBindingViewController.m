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

#import "HLNickNameViewController.h" // 昵称设置
#import "HLHeadViewController.h" // 头像设置
#import "HLSexViewController.h" // 性别设置
#import "HLBirthdayViewController.h" // 生日设置
#import "HLCityViewController.h" // 城市设置
#import "HLUserDetailInfoViewController.h"

@interface HLBindingViewController ()<HLCenterViewDeleagte,UITextFieldDelegate>
{
    NSTimer *timer;
}

@property (nonatomic, strong) UILabel *titleLbale;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) HLCenterView *centerView;

@property ( nonatomic , strong) HLUser *userInfo;

//标志位
@property (nonatomic,assign)NSInteger volidationTime;//验证码获取时间;
//数据
@property (nonatomic,copy)NSString *volidationStr;//获取到的验证字符串

@end

@implementation HLBindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self removeTimer];
        [[LoginManager defaultManager] doLogout];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    [self createView];
    
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    self.centerView = [HLCenterView initWithXib:CGRectMake(0, 102, self.view.frame.size.width, 350) delegate:self];
    [self.view addSubview:_centerView];
}


// 发送验证码
- (void)verityButtonClick{
    
    if (![self.centerView.phoneNumberTF.text isValidateTelNumber]) {
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
    } else if (self.volidationTime != 0) {
        [self.view showTostWithMessage:[NSString stringWithFormat:@"请在%ld秒后再点击发送按钮",(long)self.volidationTime]];
    } else {
        
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
    
    if (![self.centerView.phoneNumberTF.text isValidateTelNumber]) {
        
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
        
    } else if (kISNullString(self.centerView.verityTF.text)) {
        
        [self.view showTostWithMessage:@"请输入验证码"];
        
    } else {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
            @"mobile":self.centerView.phoneNumberTF.text,
            @"sms":self.centerView.verityTF.text,
            @"openid":self.openID,
            @"in":self.type,
            @"password":@"123456"
        }];
        
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLBINDIN_PHONE withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/index/binding: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"] ) {// 绑定成功
                [self removeTimer];
                
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
                [[LoginManager defaultManager] setBirthday:dictionary[@"data"][@"birthday"]]; // 生日
                [[LoginManager defaultManager] setHabitation:dictionary[@"data"][@"habitation"]]; // 居住地

                // 获取咨询师信息
                [self requestData];
                
                [self isWanShan];

            } else {
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"获取验证码失败,请重新获取"];
        }];
    }
    
}

// 是否完善
- (void)isWanShan {
    
    NSLog(@"%@",[LoginManager defaultManager].nickName);
    NSLog(@"%@",[LoginManager defaultManager].avatar);
    NSLog(@"%@",[LoginManager defaultManager].gender);
    NSLog(@"%@",[LoginManager defaultManager].birthday);
    NSLog(@"%@",[LoginManager defaultManager].habitation);
    
    
    // 是否需要完善信息
    if (kISNullObject([LoginManager defaultManager].nickName)) {
//        HLNickNameViewController *vc = [[HLNickNameViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
        
        HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
        if (kISNullObject([LoginManager defaultManager].avatar)) {
//            HLHeadViewController *vc = [[HLHeadViewController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
            
            HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            
            if (kISNullObject([LoginManager defaultManager].gender)) {
//                HLSexViewController *vc = [[HLSexViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
                
                HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                
                if (kISNullObject([LoginManager defaultManager].birthday)) {
//                    HLBirthdayViewController *vc = [[HLBirthdayViewController alloc] init];
//                    [self.navigationController pushViewController:vc animated:YES];
                    
                    HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    
                    if (kISNullObject([LoginManager defaultManager].habitation)) {
//                        HLCityViewController *vc = [[HLCityViewController alloc] init];
//                        [self.navigationController pushViewController:vc animated:YES];
                        
                        HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        
                        // 登录极光IM
                        [self loginJpush];
                        
                        
                        
                        
                        // 通知相对界面需要刷新
//                        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                        
                        [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
                        
                        [self removeTimer];
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
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

#pragma mark - NSTimer
//定时器 60S  不让用户一直获取验证码
- (void)addTimerForMessage {
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)timerAction:(NSTimer *)timer {
    NSLog(@"_____1");
    if (self.volidationTime != 0)
    {
        self.volidationTime = self.volidationTime - 1;
        NSString *titleStr = [NSString stringWithFormat:@"%ld秒",(long)self.volidationTime];
        
        [self.centerView.verityBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    else
    {
        [self removeTimer];
        
        [self.centerView.verityBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        
    }
}

- (void)removeTimer {
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
