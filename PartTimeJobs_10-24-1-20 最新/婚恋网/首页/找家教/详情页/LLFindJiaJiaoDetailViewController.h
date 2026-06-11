//
//  LLFindJiaJiaoDetailViewController.h
//  PartTimeJobs
//
//  Created by houli on 2024/10/24.
//  Copyright © 2024 红豆-婚恋网. All rights reserved.
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
@interface LLFindJiaJiaoDetailViewController : UIViewController
@property (nonatomic, strong) CSCoachDetailModel *model;
@property (nonatomic, strong) CSHomeModel *userMod;

@property (nonatomic, copy) SureBlock sureBlock;

@property (nonatomic, assign) AppType isApp;
@end

NS_ASSUME_NONNULL_END
