//
//  LLTeachingPriceController.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PriceDefaultType,
    PriceFaBuType,
} priceType;

typedef void(^SureBlock)(void);
typedef void(^PriBlock)(NSString *fromStr, NSString *toStr);

@interface LLTeachingPriceController : HXBaseViewController

@property (nonatomic, copy) SureBlock sureBlock;

@property (nonatomic, copy) PriBlock priceBlock;

@property (nonatomic, assign) priceType priType;


@property (nonatomic, strong) NSString *fromString, *toString;

@end

NS_ASSUME_NONNULL_END
