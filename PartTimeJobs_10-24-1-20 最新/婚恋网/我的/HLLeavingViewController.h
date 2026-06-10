//
//  HLLeavingViewController.h
//  hongdou
//
//  Created by iMac on 2019/10/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    Student,
    Teacher,
} MyIdentity; // 身份选择

@interface HLLeavingViewController : HXBaseViewController

@property (nonatomic, assign) MyIdentity type;

@end

NS_ASSUME_NONNULL_END
