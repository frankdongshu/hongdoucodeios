//
//  CSPersonInfoController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    LoginNo, // 登录时必填
    LoginYes, // 登录后修改
} IsLog;

@interface CSPersonInfoController : HXBaseViewController

@property (nonatomic, assign) IsLog login;

@end

NS_ASSUME_NONNULL_END
