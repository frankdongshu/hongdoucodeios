//
//  HLNickNameViewController.m
//  hongdou
//
//  Created by 李龙 on 2021/5/7.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLNickNameViewController.h"
#import "HLHeadViewController.h"

@interface HLNickNameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nickNameTF;

@end

@implementation HLNickNameViewController

- (IBAction)nextClick:(id)sender {
    
    [self.view endEditing:YES];
    
    if (kISNullObject(self.nickNameTF.text)) {
        [MBProgressHUD showMessage:@"请填写昵称" view:nil];
        return;
    }
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":@"nickname",
        @"val":self.nickNameTF.text
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [weakSelf.view hideLoading];
            
            [[LoginManager defaultManager] setNickName:self.nickNameTF.text];
            
            HLHeadViewController *vc = [[HLHeadViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:error.localizedDescription];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.view showTostWithMessage:@"未设置昵称"];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [self logOut];
        
    }];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

- (void)back:(id)sender {
    [self.view showTostWithMessage:@"未设置昵称"];
}

- (void)logOut {
    
    [[LoginManager defaultManager] doLogout];
    [MyLogin logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
    
    [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// 昵称限制最高9个字符
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return current.length <= 9;
    
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
