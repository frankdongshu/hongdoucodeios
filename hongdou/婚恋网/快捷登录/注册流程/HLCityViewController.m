//
//  HLCityViewController.m
//  hongdou
//
//  Created by 李龙 on 2021/5/7.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLCityViewController.h"
#import "HLCitySelectorViewController.h"

@interface HLCityViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cityTF;

@property (strong, nonatomic) NSString *cityId;

@end

@implementation HLCityViewController


- (IBAction)selectClick:(id)sender {
    
    //居住地
    HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
    citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
        
        
        self.cityTF.text = model.cityName;
        self.cityId = model.cityID;

    };
    [self presentViewController:citySelectVC animated:YES completion:nil];
    
    
}

- (IBAction)nextClick:(id)sender {
    
    if (kISNullObject(self.cityId)) {
        [MBProgressHUD showMessage:@"请选择城市" view:nil];
        return;
    }
    
    [self uploadGenderWithCity:self.cityId];
    
}

- (void)uploadGenderWithCity:(NSString *)city {
    
    [self.view endEditing:YES];
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":@"habitation",
        @"val":city
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"===: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [weakSelf.view hideLoading];
            
            [[LoginManager defaultManager] setHabitation:city];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WELCOME_iMG" object:nil];
            
            [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
            
            [self dismissViewControllerAnimated:YES completion:nil];

        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
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
        
        [self.view showTostWithMessage:@"未选择城市"];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [self logOut];
        
    }];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
}

- (void)logOut {
    
    [[LoginManager defaultManager] doLogout];
    [MyLogin logOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
    
    [JVERIFICATIONService dismissLoginControllerAnimated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)back:(id)sender {
    [self.view showTostWithMessage:@"未选择城市"];
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
