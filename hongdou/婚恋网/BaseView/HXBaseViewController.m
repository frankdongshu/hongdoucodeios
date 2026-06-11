//
//  HXBaseViewController.m
//  eplatform-edu
//
//  Created by iMac on 16/8/2.
//  Copyright © 2016年 华夏大地教育网. All rights reserved.
//

#import "HXBaseViewController.h"

@interface HXBaseViewController ()

@end

@implementation HXBaseViewController

-(BOOL)isLogin
{
    return [[LoginManager defaultManager] isLogin];
}
-(BOOL)isVip
{
    return [[LoginManager defaultManager] isVip];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kControllerViewBackgroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    
    
    if (@available(iOS 15.0, *)) { // iOS15系统导航问题
        UINavigationBarAppearance * bar = [UINavigationBarAppearance new];
        bar.backgroundColor = [UIColor whiteColor];
        bar.backgroundEffect = nil;
        self.navigationController.navigationBar.scrollEdgeAppearance = bar;
        self.navigationController.navigationBar.standardAppearance = bar;

        UITabBarAppearance *bar2 = [UITabBarAppearance new];
        bar2.backgroundColor = [UIColor whiteColor];
        bar2.backgroundEffect = nil;
        self.tabBarController.tabBar.scrollEdgeAppearance = bar2;
        self.tabBarController.tabBar.standardAppearance = bar2;
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveThemeChangeNotification
{
    self.view.backgroundColor = kControllerViewBackgroundColor;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return kStatusBarStyle;
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
