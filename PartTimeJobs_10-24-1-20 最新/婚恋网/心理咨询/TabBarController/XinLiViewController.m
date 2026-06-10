//
//  XinLiViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "XinLiViewController.h"
#import "HomeController.h"
#import "MessageController.h"
#import "TeacherFindController.h"
#import "MineController.h"

@interface XinLiViewController ()

@end

@implementation XinLiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.tintColor = REDColor;
    
    UINavigationController *homeNav = [self createNavigationWithController:[[HomeController alloc] init] title:@"首页" image:@"tabbar_home" selectImage:@"home_sel"];
    
    UINavigationController *findNav = [self createNavigationWithController:[[TeacherFindController alloc] init] title:@"发现" image:@"tabbar_find" selectImage:@"find_sel"];
    
    UINavigationController *messageNav = [self createNavigationWithController:[[MessageController alloc] init] title:@"消息" image:@"tabbar_class" selectImage:@"message_sel"];
    
    UINavigationController *mineNav = [self createNavigationWithController:[[MineController alloc] init] title:@"我的" image:@"tabbar_account" selectImage:@"mine_sel"];
    
    
    self.viewControllers = @[homeNav,findNav,messageNav,mineNav];
    
}

// 私有方法,用于生成一个导航控制器
- (UINavigationController *) createNavigationWithController:(UIViewController *)vc title:(NSString *)title image:(NSString *)imgName selectImage:(NSString *)selImgName {
    
    HXNavigationController *nav = [[HXNavigationController alloc] initWithRootViewController:vc];
    
    vc.navigationItem.title = title;
    // imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:imgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
 
    return nav;
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
