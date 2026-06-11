//
//  HLUpdateNicknameViewController.m
//  婚恋网
//
//  Created by jxzhang on 2019/4/20.
//  Copyright © 2019. All rights reserved.
//

#import "HLUpdateNicknameViewController.h"

@interface HLUpdateNicknameViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIAlertView * alert;

@property (nonatomic, strong) HXBarButtonItem *leftBarItem;

@property (nonatomic, strong) HXBarButtonItem *rigthBarItem;


@property (nonatomic, strong) UITextField *textFiled;

@property (nonatomic, strong) UILabel *showMessage;


@end

@implementation HLUpdateNicknameViewController
-(void)loadView
{
    [super loadView];
    
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        if (![self.textFiled.text isEqualToString:[LoginManager defaultManager].nickName]) {
            self.alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称修改未保存,确定退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            self.alert.tag = 110;
            [self.alert show];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    self.rigthBarItem = [[HXBarButtonItem alloc] initWithTitle:@"完成" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if (self.textFiled.text.length>0) {
            [self indexPathRowModifyUserEditeInfo];
        }
    }];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 110){
            
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"昵称";
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationBar.rightBarButtonItem = self.rigthBarItem;
    self.view.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:234/255.f alpha:1.0];
    [self createTextFile];
}
- (void)createTextFile{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+20, kScreenWidth, 44)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    self.textFiled = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 25, 44)];
    [backView addSubview:self.textFiled];
    [self.textFiled setTextColor:[UIColor colorWithHex:0x333333]];
    [self.textFiled setTintColor:kNavigationBarColor];
    [self.textFiled setFont:[UIFont systemFontOfSize:14]];
    self.textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFiled.borderStyle = UITextBorderStyleNone;
    self.textFiled.keyboardType = UIKeyboardTypeASCIICapable;
    self.textFiled.placeholder = @"请输入昵称";
    if (self.isLogin) {
        self.textFiled.text = [LoginManager defaultManager].nickName;
    }
    self.textFiled.delegate = self;
    
    self.showMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, kNavigationBarHeight + 64, kScreenWidth - 30, 30)];
    self.showMessage.textColor = [UIColor redColor];
    self.showMessage.textAlignment = NSTextAlignmentLeft;
    self.showMessage.font = kFontTitleSmallnext;
    self.showMessage.text = @"* 昵称长度为2-16位";
//    [self.view addSubview:self.showMessage];
}

#pragma personInfoAlter
/**
 * 修改基本信息
 */
- (void)indexPathRowModifyUserEditeInfo{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nickName" object:self.textFiled.text];
}
//当textField编辑结束时调用的方法

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}

//按下Done按钮的调用方法，我们让键盘消失

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.textFiled.isFirstResponder) {
        [self.textFiled resignFirstResponder];
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
