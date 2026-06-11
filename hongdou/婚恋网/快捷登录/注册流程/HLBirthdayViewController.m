//
//  HLBirthdayViewController.m
//  hongdou
//
//  Created by 李龙 on 2021/5/7.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLBirthdayViewController.h"
#import "HLCityViewController.h"

@interface HLBirthdayViewController ()
@property (weak, nonatomic) IBOutlet UITextField *birthdayTF;

@end

@implementation HLBirthdayViewController

- (IBAction)nextClick:(id)sender {
    
    if (kISNullObject(self.birthdayTF.text)) {
        [MBProgressHUD showMessage:@"请选择生日" view:nil];
        return;
    }
    
    [self uploadGenderWithBirthday:self.birthdayTF.text];
    
}

- (IBAction)selectClick:(id)sender {
    
    // 出生日期
    NSDate *minDate = [NSDate br_setYear:1929 month:01 day:01];
    NSDate *maxDate = [NSDate br_setYear:2009 month:12 day:31];
    
    [BRDatePickerView showDatePickerWithMode:BRDatePickerModeYMD title:@"出生日期" selectValue:@"1985-01-01" minDate:minDate maxDate:maxDate isAutoSelect:NO resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
        
        self.birthdayTF.text = selectValue;
        
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
        
        [self.view showTostWithMessage:@"未选择出生日期"];
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
    [self.view showTostWithMessage:@"未选择出生日期"];
}

- (void)uploadGenderWithBirthday:(NSString *)birthday {
    
    [self.view endEditing:YES];
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":@"birthday",
        @"val":birthday
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [weakSelf.view hideLoading];
            
            [[LoginManager defaultManager] setBirthday:birthday]; // 生日
            
            HLCityViewController *vc = [[HLCityViewController alloc] init];
            
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
