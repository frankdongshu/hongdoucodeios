//
//  HLCoPlaintSelectTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/22.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RefreshBlock)(void);


@interface HLCoPlaintSelectTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@property (nonatomic, strong) HLListModel *listModel;
@property (nonatomic, copy) RefreshBlock refreshBlock;

@end

NS_ASSUME_NONNULL_END
