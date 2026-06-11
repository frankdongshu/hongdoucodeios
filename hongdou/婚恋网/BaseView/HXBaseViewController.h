//
//  HXBaseViewController.h
//  eplatform-edu
//
//  Created by iMac on 16/8/2.
//  Copyright © 2016年 华夏大地教育网. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXBaseViewController : UIViewController

@property(nonatomic,assign,readonly)BOOL isLogin;
@property(nonatomic,assign,readonly)BOOL isVip;

- (void)didReceiveThemeChangeNotification;

@end
