//
//  MentalityController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/3.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "MentalityController.h"
#import "CSHomeCityViewController.h" // 城市选择
#import "CSUserInfoViewController.h" // 信息填写
#import "CSPersonInfoController.h" // 个人信息
#import "CSProjectTypeController.h" // 咨询类型
#import "XinLiViewController.h" // 心理咨询TabBarController

@interface MentalityController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>{
    int _totalTime; // 倒计时
}
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *getVertifyCodeBtn;
@property (nonatomic,strong) NSTimer *timer; // 定时器

@end

@implementation MentalityController

// 禁用侧滑返回手势
- (void)forbiddenGesture {
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self forbiddenGesture];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UILabel *lab = [[UILabel alloc] init];
    lab.frame = CGRectMake(0, 0, 0, 44);
    lab.text = @"家教老师";
    
    self.sc_navigationBar.titleView = lab;
    
    [self.getVertifyCodeBtn addTarget:self action:@selector(getVertifyCodeHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    
}
// 获取验证码
- (void)getVertifyCodeHandle:(UIButton *)sender {
    
    if (self.phoneTF.text.length == 0) {
        [self.view showTostWithMessage:@"手机号不可为空"];
        return;
    }
    if (![self.phoneTF.text isMobileNumber]) {
        [self.view showTostWithMessage:@"请输入正确的手机号"];
        return;
    }
    
    
    // 让btn处于不可点击状态
    sender.userInteractionEnabled = NO;
    
    _totalTime = 60;
    
    if (@available(iOS 10.0, *)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            NSString *s = [NSString stringWithFormat:@"%02ds",self->_totalTime--];

            [self.getVertifyCodeBtn setTitle:s forState:UIControlStateNormal];
           
            if (self->_totalTime == 0) {
                self.getVertifyCodeBtn.userInteractionEnabled = YES;
                // 改变按钮透明度
                sender.alpha = 1.0;
                [self.getVertifyCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
                
                [self.timer invalidate];
                
                self.timer = nil;
            }
        }];
    }
    else {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHanle:) userInfo:nil repeats:YES];
        
    }
    
    // 网络请求
    [self getVerifyCode];
    
}
// 请求验证码
- (void)getVerifyCode {
    
    NSDictionary *params = @{
        @"mobile":self.phoneTF.text
    };
    
    [HTTPSessionManger postDataWithNSString:@"/index/sms" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.view showTostWithMessage:dictionary[@"msg"]];
            
        } else {
            
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"请求失败"];
    }];
    
    
}

// 获取验证码定时器触发方法
- (void)timerHanle:(NSTimer *)t {
    
    NSString *s = [NSString stringWithFormat:@"%02d",_totalTime--];
    
    [self.getVertifyCodeBtn setTitle:s forState:UIControlStateNormal];
    
    if (_totalTime == 0) {
        self.getVertifyCodeBtn.userInteractionEnabled = YES;
        // 改变按钮透明度
        self.getVertifyCodeBtn.alpha = 1.0;
        
        [self.getVertifyCodeBtn setTitle:@"再次获取验证码" forState:UIControlStateNormal];
        
        [self.timer invalidate];
        
        self.timer = nil;
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本
    NSString *content = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 201) {
        return content.length <= 11;
    }
    else if (textField.tag == 202) {
    
        return content.length <= 4;
    }
    else {
        return YES;
    }
    
}

#pragma mark - 登录触发方法
- (IBAction)goClick:(UIButton *)sender {
    // 关闭键盘
    [self.view endEditing:YES];
    
//    if (![self.phoneTF.text isMobileNumber]) {
//        [self.view showTostWithMessage:@"请填写正确的手机号"];
//        return;
//    }
    if (self.codeTF.text.length == 0) {
        [self.view showTostWithMessage:@"请填写验证码"];
        return;
    }
    
    NSDictionary *params = @{
        @"mobile":self.phoneTF.text,
        @"sms":self.codeTF.text
    };
    
    [self.view showLoading];
    [HTTPSessionManger postDataWithNSString:@"/index/logon" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"登录信息: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin mj_objectWithKeyValues:dictionary[@"data"]];
            
            NSData *uData = [NSKeyedArchiver archivedDataWithRootObject:u];
            
            [[NSUserDefaults standardUserDefaults] setObject:uData forKey:Login_USER];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self requestData]; // 获取详细
            
        } else {
            
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:@"请求失败"];
    }];
    
}
// 免责声明
- (IBAction)mianZeClick:(UIButton *)sender {
    
    NSLog(@"免责声明");
}

// 安全手册
- (IBAction)anQuanShouCeClick:(UIButton *)sender {
    NSLog(@"安全手册");
}

#pragma mark - 创建导航控制器
- (void)createNav {
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, kScreenWidth, 44)];
    
    [self.view addSubview:navView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 0, 30, 44);
    [backBtn setImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:backBtn];
    
}
#pragma mark - 导航返回按钮触发
- (void)backClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

// 获取用户信息
- (void)requestData {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/get_coach" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"获取其他信息: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            
            u.head = dictionary[@"data"][@"head"]; // 头像
            u.intelligence = dictionary[@"data"][@"intelligence"]; // 资质
            u.education = dictionary[@"data"][@"education"]; // 最高学历
            u.school = dictionary[@"data"][@"school"]; // 学校
            u.major = dictionary[@"data"][@"major"]; // 专业
            u.descr = dictionary[@"data"][@"description"]; // 个人介绍
            u.motto = dictionary[@"data"][@"motto"]; // 职业格言
            u.teaching = dictionary[@"data"][@"teaching"]; // 授课方式
            u.cost_low = dictionary[@"data"][@"cost_low"]; // 最低值
            u.cost_high = dictionary[@"data"][@"cost_high"]; // 最高值
            u.qq = dictionary[@"data"][@"qq"]; // QQ
            u.wx = dictionary[@"data"][@"wx"]; // 微信
            u.contact = dictionary[@"data"][@"contact"]; // 电话
            u.papers = dictionary[@"data"][@"papers"]; // 证件照
            u.identity = dictionary[@"data"][@"identity"]; // 教师身份
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in dictionary[@"data"][@"curriculum"]) {
                [arr addObject:dic[@"id"]];
            }
            u.curriculum = arr; // 咨询类型, 取id
            
            [MyLogin updateUser:u];
            
            [JMSGUser loginWithUsername:[NSString stringWithFormat:@"mind_%@",[MyLogin getCurrentLoginUser].mobile] password:@"Daxuesheng321" completionHandler:^(id resultObject, NSError *error) {
                if (!error) {
                    NSLog(@"心理咨询-极光IM登录成功: %@",resultObject);
                } else {
                    NSLog(@"心理咨询-极光IM登录失败: %@",error);
                }
            }];
            
            if (!u.city) { // 城市选择
                CSHomeCityViewController *vc = [[CSHomeCityViewController alloc]init];
                vc.cityType = CityNo;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                if (!u.sex) { // 信息填写
                    CSUserInfoViewController *vc = [[CSUserInfoViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    
                    if (kISNullObject(u.intelligence) ||
                        kISNullObject(u.education) ||
                        kISNullObject(u.school) ||
                        kISNullObject(u.major) ||
                        kISNullObject(u.descr) ||
                        kISNullObject(u.teaching) ||
                        kISNullObject(u.cost_low)
                        ) {
                        
                        CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
                        vc.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    } else {
                        
                        if (kISNullObject([MyLogin getCurrentLoginUser].curriculum)) {
                            CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
                            vc.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:vc animated:YES];
                        } else {
                            
                            XinLiViewController *vc = [[XinLiViewController alloc] init];
                            vc.modalPresentationStyle = 0;
                            [self presentViewController:vc animated:YES completion:nil];
                            
                        }
                        
                    }
                    
                }
            }
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:@"请求失败"];
    }];
}

#pragma mark - 是否必填全部上传
- (void)requestIsMust {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/must" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (kISNullObject([MyLogin getCurrentLoginUser].curriculum)) {
                CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                
                XinLiViewController *vc = [[XinLiViewController alloc] init];
                vc.modalPresentationStyle = 0;
                [self presentViewController:vc animated:YES completion:nil];
                
            }
            
        } else {
            
            CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:@"请求失败"];

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
