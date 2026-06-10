//
//  HLLeavingViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLLeavingViewController.h"

@interface HLLeavingViewController ()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeHolderlabel;

@property (nonatomic, strong) UILabel *showNumLabel;

@property (nonatomic, strong) HXBarButtonItem *leftBarItem;

@end

@implementation HLLeavingViewController

-(void)loadView
{
    [super loadView];
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"客服留言";
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    [self creatUITextView];
}
- (void)creatUITextView{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(5, kNavigationBarHeight+5, kScreenWidth - 10, 180)];
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    
    self.placeHolderlabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 6 , kScreenWidth - 23 , 21)];
    self.placeHolderlabel.font = [UIFont systemFontOfSize:16];
    self.placeHolderlabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
    self.placeHolderlabel.text = @"请输入内容";
    [self.textView addSubview:self.placeHolderlabel];
    
    UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, kNavigationBarHeight + 200, kScreenWidth - 60 , 44)];
    [updateBtn setTitle:@"提交" forState:UIControlStateNormal];
    
    if (self.type == Teacher) {
        updateBtn.backgroundColor = REDColor;
    } else {
        [updateBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    }
    
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateBtn.layer.cornerRadius = 22.f;
    updateBtn.layer.masksToBounds = YES;
    [updateBtn addTarget:self action:@selector(uploadLeaving) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateBtn];
    
   
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
}
- (void)textViewDidEndEditing:(UITextView *)textView{
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
    // 字数限制操作
    if ([textView.text length] == 0) {
        [self.placeHolderlabel setHidden:NO];
    }
    else{
        [self.placeHolderlabel setHidden:YES];
    }
    
}

- (void)uploadLeaving{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    
    if (self.textView.text.length < 1) {
        [self.view showTostWithMessage:@"请输入内容"];
        return;
    }
    
    NSDictionary *dic = @{
        @"uid":self.type == Teacher?[MyLogin getCurrentLoginUser].userid:[LoginManager defaultManager].userid,
        @"message":self.textView.text
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLLeave_Message withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
            [MBProgressHUD showSuccess:[dictionary objectForKey:@"msg"] toView:appDelegate.window];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请重新点击提交按钮提交"];

    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
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
