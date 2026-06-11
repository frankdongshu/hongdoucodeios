//
//  MBProgressHUD+Add.m
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+Add.h"

@implementation MBProgressHUD (Add)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    
    if (self) {
        [self hideLoading];
    }
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];

    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:icon] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.label.text = text;

    [hud hideAnimated:YES afterDelay:1.5f];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    
    [self show:error icon:@"error" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success" view:view];
}

+ (void)showMessage:(NSString *)text view:(UIView *)view
{
    if (self) {
        [self hideLoading];
    }
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];

    // Set the text mode to show only text.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.label.textColor = [UIColor redColor];
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, kScreenHeight/2.5);

    [hud hideAnimated:YES afterDelay:2.5f];
}

+ (void)showLoading {
    
    [self showHUDAddedTo:kAppDelegate.window animated:YES];
    
}

+ (void)hideLoading {
    
    [self hideHUDForView:kAppDelegate.window animated:YES];
    
}


@end
