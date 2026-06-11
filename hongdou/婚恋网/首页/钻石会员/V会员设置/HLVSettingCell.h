//
//  HLVSettingCell.h
//  hongdou
//
//  Created by 维康1 on 2020/8/21.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLSwitchCellDeleagte <NSObject>

- (void)refreshTableView;

@end

@interface HLVSettingCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *swicthOn;

@property (nonatomic,assign) id <HLSwitchCellDeleagte>delegate;

@property (nonatomic, assign)BOOL statu;

@property (nonatomic, assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
