//
//  HLSwitchTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/9/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HLSwitchCellDeleagte <NSObject>

- (void)refreshTableView;

@end

@interface HLSwitchTableViewCell : HXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *swicthOn;

@property (nonatomic,assign) id <HLSwitchCellDeleagte>delegate;

@property (nonatomic, assign)BOOL statu;

@property (nonatomic, assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
