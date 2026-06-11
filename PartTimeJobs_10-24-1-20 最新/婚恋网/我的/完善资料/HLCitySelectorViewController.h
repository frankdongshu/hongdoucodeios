//
//  HLCitySelectorViewController.h
//  hongdou
//
//  Created by iMac on 2019/9/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"
#import "HLListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RegisterBack,
    UpdateBack,
} BackType;

typedef void(^SelectorCityBlock)(HLCityModel *model);

@interface HLCitySelectorViewController : HXBaseViewController

@property (nonatomic, copy) SelectorCityBlock selectorCityBlock;

@property (nonatomic, assign) BackType backType;

@end

NS_ASSUME_NONNULL_END
