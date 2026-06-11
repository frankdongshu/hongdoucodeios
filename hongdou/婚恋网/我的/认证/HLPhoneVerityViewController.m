//
//  HLPhoneVerityViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPhoneVerityViewController.h"

@interface HLPhoneVerityViewController ()
@property (weak, nonatomic) IBOutlet UILabel *phoneNuberLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextFileld;
@property (weak, nonatomic) IBOutlet UITextField *cordIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation HLPhoneVerityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"手机实名认证";
    [self initContollerView];
    
}

- (void)initContollerView{
    NSString *phoneNuber = [LoginManager defaultManager].account;
    NSString *numberString = [phoneNuber stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    self.phoneNuberLabel.text = numberString;
    
    [self.sureButton az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:153/255.0 green:95/255.0 blue:248/255.0 alpha:1.0],[UIColor colorWithRed:93/255.0 green:87/255.0 blue:237/255.0 alpha:1.0]] locations:@[@(0.0),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
}

- (IBAction)sureClick:(id)sender {
    if (_nameTextFileld.isFirstResponder || _cordIDTextField.isFirstResponder) {
        [_nameTextFileld resignFirstResponder];
        [_cordIDTextField resignFirstResponder];
    }
    
    if (self.nameTextFileld.text==0) {
        [self.view showTostWithMessage:@"请输入您的姓名"];
        return;
    }
    if (![NSString cly_verifyIDCardString:self.cordIDTextField.text]) {
        [self.view showTostWithMessage:@"请输入正确的身份证号"];
        return;
    }
    
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"name":self.nameTextFileld.text,
        @"ID":self.cordIDTextField.text
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLVerity_PhoneNnber withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            if ([[dictionary[@"data"][@"attestation"] stringValue] isEqualToString:@"1"]) {
                self.block();
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
                [MBProgressHUD showMessage:@"认证成功" view:nil];
                
            } else {
                [weakSelf.view showTostWithMessage:@"认证失败!"];
            }
            
        } else {
            
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [weakSelf.view showTostWithMessage:@"实名验证失败"];
        
    }];
}

#pragma mark 取消键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_nameTextFileld.isFirstResponder || _cordIDTextField.isFirstResponder) {
        [_nameTextFileld resignFirstResponder];
        [_cordIDTextField resignFirstResponder];
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
