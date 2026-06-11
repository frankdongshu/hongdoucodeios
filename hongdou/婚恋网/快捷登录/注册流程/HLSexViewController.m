//
//  HLSexViewController.m
//  hongdou
//
//  Created by 李龙 on 2021/5/7.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLSexViewController.h"
#import "HLBirthdayViewController.h"

@interface HLSexViewController ()
@property (weak, nonatomic) IBOutlet UITextField *sexTF;

@end

@implementation HLSexViewController

- (IBAction)selectClick:(id)sender {
    
    [BRStringPickerView showPickerWithTitle:@"性别" dataSourceArr:@[@"男", @"女"] selectIndex:0 resultBlock:^(BRResultModel * _Nullable resultModel) {
        
        self.sexTF.text = resultModel.value;
        
    }];
    
}

- (IBAction)nextClick:(id)sender {
    
    if (kISNullObject(self.sexTF.text)) {
        [MBProgressHUD showMessage:@"请选择性别" view:nil];
        return;
    }
    
    if ([self.sexTF.text isEqualToString:@"男"]) {
        [self uploadGenderWithGender:@"1"];
    } else {
        [self uploadGenderWithGender:@"2"];
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.view showTostWithMessage:@"未选择性别"];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [self logOut];
        
    }];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [self selectClick:nil];
}

- (void)logOut {
    
    [[LoginManager defaultManager] doLogout];
    [MyLogin logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
    
    [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)back:(id)sender {
    [self.view showTostWithMessage:@"未选择性别"];
}

- (void)uploadGenderWithGender:(NSString *)gender {
    
    [self.view endEditing:YES];
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":@"gender",
        @"val":gender
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [weakSelf.view hideLoading];
            
            [[LoginManager defaultManager] setGender:gender]; // 性别
            
            HLBirthdayViewController *vc = [[HLBirthdayViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
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
