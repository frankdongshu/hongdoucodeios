//
//  CSProjectTypeController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/11.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    TypeNo, // 登录时必填
    TypeYes, // 登录后修改
} ProjectType;

@interface CSProjectTypeController : HXBaseViewController

@property (nonatomic, assign) ProjectType projType;

@end

NS_ASSUME_NONNULL_END
