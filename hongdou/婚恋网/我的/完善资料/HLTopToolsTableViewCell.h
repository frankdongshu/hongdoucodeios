//
//  HLTopToolsTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/9/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^topToolsCellSelectCityBlock)(HLCityModel *model);

@interface HLTopToolsTableViewCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray <UIButton *>*buttonArr;

@property (nonatomic, copy) topToolsCellSelectCityBlock selectCityBlock;

@property (nonatomic, strong) NSArray *dataArry;


@end

NS_ASSUME_NONNULL_END
