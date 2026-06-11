//
//  CSHomeCityViewController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/6.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    CityNo,
    CityYes,
} CityListType;

typedef void(^SureBlock)(void);

@interface CSHomeCityViewController : HXBaseViewController

@property (nonatomic, assign) CityListType cityType;

@property (nonatomic, copy) SureBlock sureBlock;

@end

NS_ASSUME_NONNULL_END
