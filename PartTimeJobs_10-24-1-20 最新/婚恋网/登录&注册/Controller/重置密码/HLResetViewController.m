//
//  HLResetViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/24.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLResetViewController.h"
#import "HLCenterView.h"
#import "HLSucessViewController.h"

@interface HLResetViewController ()<HLCenterViewDeleagte,UITextFieldDelegate>
{
    NSTimer *timer;
}
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong)HXBarButtonItem *leftBarItem;

@property (nonatomic, strong) HLCenterView *centerView;

//标志位
@property (nonatomic,assign)NSInteger volidationTime;//验证码获取时间;
//数据
@property (nonatomic,copy)NSString *volidationStr;//获取到的验证字符串

@end

@implementation HLResetViewController

- (void)loadView{
    [super loadView];
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        [self removeTimer];
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
//    [self.headerView az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:189/255.0 green:100/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:130/255.0 green:92/255.0 blue:244/255.0 alpha:1.0]] locations:@[@(0.0),@(0.7),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    self.headerView.backgroundColor = REDColor;
    [self.view addSubview:self.headerView];
    
    UILabel *titleLbale = [[UILabel alloc] initWithFrame:CGRectMake(80, kStatusBarHeight, kScreenWidth - 160, 44)];
    titleLbale.text =@"重置密码";
    titleLbale.textAlignment = NSTextAlignmentCenter;
    titleLbale.font = [UIFont systemFontOfSize:17];
    titleLbale.backgroundColor = [UIColor clearColor];
    titleLbale.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLbale];
    
    self.centerView = [HLCenterView initWithXib:CGRectMake(0, 102, kScreenWidth, 300) delegate:self];
    [self.view addSubview:_centerView];
}
#pragma mark click
// 获取验证码
- (void)verityButtonClick{
    
    if (![NSString isValidateTelNumber:self.centerView.phoneNumberTF.text])//没有通过正则表达式
    {
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
    }
    else if (self.volidationTime != 0)
    {
        [self.view showTostWithMessage:[NSString stringWithFormat:@"请在%ld秒后再点击发送按钮",(long)self.volidationTime]];
    }else{
        // 先请求
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLSEND_CODE withDictionary:@{@"mobile":self.centerView.phoneNumberTF.text,@"type":@"2"} success:^(NSDictionary * _Nonnull dictionary) {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                self.volidationTime = 60;
                [self addTimerForMessage];
//                [weakSelf getCaptcha];
            }else{
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:@"获取验证码失败,请重新获取"];
        }];
    }
    
}
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
// 重置点击事件
- (void)sureButtonClick{
    
    if (![NSString isValidateTelNumber:self.centerView.phoneNumberTF.text])//没有通过正则表达式
    {
        [self.view showTostWithMessage:@"请输入正确的手机号码"];
    }else if (!self.centerView.verityTF.text){
        [self.view showTostWithMessage:@"请输入验证码"];
        
    }else if (self.centerView.passwordTF.text.length < 6 || self.centerView.passwordTF.text.length > 12){
        [self.view showTostWithMessage:@"请输入6-12位密码"];
        
    }else{
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLRERSETPWD withDictionary:@{@"mobile":self.centerView.phoneNumberTF.text,@"sms":self.centerView.verityTF.text,@"device":[[UIDevice currentDevice] deviceModelName],@"password":self.centerView.passwordTF.text} success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"重置密码成功=========----=-=-==-=-=-=%@",dictionary);
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                // 重置成功
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [MBProgressHUD showSuccess:dictionary[@"msg"] toView:app.window];
                
//                HLSucessViewController *successVC = [[HLSucessViewController alloc] init];
//                successVC.navTitle = @"重置成功";
//                successVC.sucessMessage = @"恭喜您，密码重置成功！";
                [weakSelf removeTimer];
//                [self.navigationController pushViewController:successVC animated:YES];
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            }else{
                [weakSelf.view showTostWithMessage:@"修改失败!"];
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
    
    if (textField.tag == 530) { // 限制密码为6-12位
        return current.length <= 12;
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
