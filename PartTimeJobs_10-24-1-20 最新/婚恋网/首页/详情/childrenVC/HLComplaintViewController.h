//
//  HLComplaintViewController.h
//  hongdou
//
//  Created by iMac on 2019/10/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HongDouUser,
    ZiXunShi,
} PersonType;


@interface HLComplaintViewController : HXBaseViewController

@property (nonatomic, assign) PersonType pertEnum;

@property (nonatomic, strong) NSString *userMobile;


@end

NS_ASSUME_NONNULL_END
