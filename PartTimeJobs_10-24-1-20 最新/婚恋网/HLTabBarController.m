//
//  HLTabBarController.m
//  婚恋网
//
//  Created by iMac on 2019/2/28.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLTabBarController.h"
#import "HLLoginViewController.h"
@interface HLTabBarController ()

@end

@implementation HLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTabBarItemsTitle];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x815CF4]} forState:UIControlStateSelected];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin) name:SHOWLOGIN object:nil];
    
}
- (void)showLogin{
    
    [[LoginManager defaultManager] doLogout];
    
    //告诉服务器，我退出登录
    //    [VKHTTPSessionManager userLogoutActionsuccess:nil failure:nil];
    
    
    HLLoginViewController*loginVC = [[HLLoginViewController alloc] init];
    HXNavigationController *nvc = [[HXNavigationController alloc]initWithRootViewController:loginVC];
    // 解决 ios13 presentViewController不能铺满全屏
    nvc.modalPresentationStyle = 0;
    [self presentViewController:nvc animated:YES completion:^{
        
    }];
}
//设置TabBarItem标题
-(void)setTabBarItemsTitle
{
    
    self.tabBar.tintColor = REDColor;
    NSArray * titles = [NSArray arrayWithObjects:TabBarItemTitle1,TabBarItemTitle2,TabBarItemTitle3,TabBarItemTitle4, nil];
    
    NSArray *selectImgs = @[@"home_sel",@"find_sel",@"message_sel",@"mine_sel"];
    
    for (int i=0;i<titles.count;i++) {
        UITabBarItem * item = [[self.viewControllers objectAtIndex:i] tabBarItem];
//        item.title = [titles objectAtIndex:i];
        item.selectedImage = [[UIImage imageNamed:selectImgs[i]] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
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
