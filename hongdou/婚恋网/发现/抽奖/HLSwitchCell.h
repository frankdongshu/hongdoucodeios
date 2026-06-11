//
//  HLSwitchCell.h
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLSwitchCellDeleagte <NSObject>

- (void)refreshTableView;

@end

@interface HLSwitchCell : UITableViewCell

@property (nonatomic,assign) id <HLSwitchCellDeleagte>delegate;

@property (nonatomic, strong) UISwitch *theSwitch;

@property (nonatomic, assign)BOOL statu;

@end

NS_ASSUME_NONNULL_END
