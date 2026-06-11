//
//  CSCoachDetailViewController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSCoachDetailModel.h"
#import "CSHomeModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    XinLiApp, // 区分那个app
    HongApp,
} AppType;

typedef void(^SureBlock)(void);

@interface CSCoachDetailViewController : UIViewController

@property (nonatomic, strong) CSCoachDetailModel *model;
@property (nonatomic, strong) CSHomeModel *userMod;

@property (nonatomic, copy) SureBlock sureBlock;

@property (nonatomic, assign) AppType isApp;

@end

NS_ASSUME_NONNULL_END
