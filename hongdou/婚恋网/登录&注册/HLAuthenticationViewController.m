//
//  HLAuthenticationViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/24.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLAuthenticationViewController.h"
#import "HLBindingViewController.h"

@interface HLAuthenticationViewController ()

@property (nonatomic, strong)HXBarButtonItem *leftBarItem;

@end

@implementation HLAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sc_navigationBar.title = @"身份认证";
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
}
- (IBAction)bindingPhoneNumClick:(id)sender {
    HLBindingViewController *bindingVC = [[HLBindingViewController alloc] init];
    
    bindingVC.type = self.type;
    bindingVC.openID = self.openId;
    
    [self.navigationController pushViewController:bindingVC animated:YES];
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
