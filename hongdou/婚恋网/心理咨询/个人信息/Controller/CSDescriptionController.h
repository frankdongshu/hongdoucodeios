//
//  CSDescriptionController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/17.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SureBlock)(void);

@interface CSDescriptionController : HXBaseViewController

@property (nonatomic, copy) SureBlock sureBlock;

@end

NS_ASSUME_NONNULL_END
