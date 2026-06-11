//
//  HLCodeNumberVC.m
//  hongdou
//
//  Created by 李龙 on 2021/5/6.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLCodeNumberVC.h"

#import "HWTFCursorView.h" // 基础版 - 下划线 - 有光标

#import "HLNickNameViewController.h" // 昵称设置
#import "HLHeadViewController.h" // 头像设置
#import "HLSexViewController.h" // 性别设置
#import "HLBirthdayViewController.h" // 生日设置
#import "HLCityViewController.h" // 城市设置

#import "HLUserDetailInfoViewController.h" // 完善信息

@interface HLCodeNumberVC (){
    NSTimer *timer;
}

// 验证码视图占位
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

// 验证码视图
@property (nonatomic, strong) HWTFCursorView *codeView;

//验证码获取时间
@property (nonatomic,assign)NSInteger volidationTime;

@end

@implementation HLCodeNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    // 验证码视图
    self.codeView = [[HWTFCursorView alloc] initWithCount:4 margin:20];
    [self.coverView addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(self.coverView);
    }];
    
    // 获取验证码
    [self requestCodeClick:nil];
    
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logOut {
    
    [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
    
}

// 获取验证码
- (IBAction)requestCodeClick:(id)sender {
    
    [self.view endEditing:YES];
    
    [MBProgressHUD showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLSEND_CODE withDictionary:@{@"mobile":self.phoneNumber} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.volidationTime = 60;
            [self addTimerForMessage];
        } else {
            
            [self.codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

// 验证码登录
- (IBAction)nextClick:(id)sender {
    
    if (self.codeView.code.length == 0) {
        [MBProgressHUD showMessage:@"请输入验证码" view:nil];
        return;
    }
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"mobile":self.phoneNumber,
        @"sms":self.codeView.code
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
            
            
            [self removeTimer];
            
            // 是否需要完善信息
            if (kISNullObject(dictionary[@"data"][@"nickname"])) {
//                HLNickNameViewController *vc = [[HLNickNameViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
                
                HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                if (kISNullObject(dictionary[@"data"][@"head"])) {
//                    HLHeadViewController *vc = [[HLHeadViewController alloc] init];
//                    [self.navigationController pushViewController:vc animated:YES];
                    
                    HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    
                    if (kISNullObject(dictionary[@"data"][@"gender"])) {
//                        HLSexViewController *vc = [[HLSexViewController alloc] init];
//                        [self.navigationController pushViewController:vc animated:YES];
                        
                        HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        
                        if (kISNullObject(dictionary[@"data"][@"birthday"])) {
//                            HLBirthdayViewController *vc = [[HLBirthdayViewController alloc] init];
//                            [self.navigationController pushViewController:vc animated:YES];
                            
                            HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                            [self.navigationController pushViewController:vc animated:YES];
                        } else {
                            
                            if (kISNullObject(dictionary[@"data"][@"habitation"])) {
//                                HLCityViewController *vc = [[HLCityViewController alloc] init];
//                                [self.navigationController pushViewController:vc animated:YES];
                                
                                HLUserDetailInfoViewController *vc = [[HLUserDetailInfoViewController alloc] init];
                                [self.navigationController pushViewController:vc animated:YES];
                            } else {
                                
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"WELCOME_iMG" object:nil];
                                
                                [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
                                
                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD showMessage:error.localizedDescription view:nil];
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

// 与当前时间比较是否是不过期
- (BOOL)checkProductDate: (NSString *)tempDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *date = [dateFormatter dateFromString:tempDate];
//    / 获取时间戳
    NSTimeInterval timeStamp = [date timeIntervalSince1970];

    NSLog(@"timeStamp");
//    // 判断是否大于当前时间
//    if ([date earlierDate:[NSDate date]] != date) {
//        
//        return NO;
//    } else {
//        
//        return YES;
//    }
    // 获取当前日期
    NSDate  *currentDate=[NSDate date];
    NSTimeInterval currentTimeStamp = [currentDate timeIntervalSince1970];
    
    // 比较日期
    if(currentTimeStamp - timeStamp  > 0 ){
        NSLog(@"已过期");
        return NO;
    }else{
        NSLog(@"未过期");
        return YES;
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
        NSString *titleStr = [NSString stringWithFormat:@"%lds",(long)self.volidationTime];
        
        [self.codeBtn setTitle:titleStr forState:UIControlStateNormal];
        
        self.codeBtn.userInteractionEnabled = NO;
    }
    else
    {
        [self removeTimer];
        [self.codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        
        self.codeBtn.userInteractionEnabled = YES;
    }
}
- (void)removeTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
    
}

- (void)dealloc {
    [self removeTimer];
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
