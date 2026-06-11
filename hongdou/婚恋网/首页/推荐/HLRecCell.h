//
//  HLRecCell.h
//  hongdou
//
//  Created by user on 2022/4/27.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLRecCellDeleagte <NSObject>

- (void)refreshTableViewWithSwitch:(UISwitch *)theSwitch;

- (void)updateBtnClick;

@end

@interface HLRecCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *swicthOn;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *localLabel;

@property (nonatomic,assign) id <HLRecCellDeleagte>delegate;

@property (nonatomic, assign)BOOL statu;

@property (nonatomic, assign)NSInteger index;

@end

NS_ASSUME_NONNULL_END
