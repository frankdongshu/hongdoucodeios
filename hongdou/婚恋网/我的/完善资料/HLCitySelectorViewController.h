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
typedef void(^SelectorCityBlock)(HLCityModel *model);

@interface HLCitySelectorViewController : HXBaseViewController

@property (nonatomic, copy) SelectorCityBlock selectorCityBlock;



@end

NS_ASSUME_NONNULL_END
