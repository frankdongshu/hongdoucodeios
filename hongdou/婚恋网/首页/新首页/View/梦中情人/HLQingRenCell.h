//
//  HLQingRenCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLQingRenCellDelegate <NSObject>

- (void)addPhotoMengZhongQingRen;
// 跳转情人详情页
- (void)pushQingRenDetailWithId:(NSString *)uid;

// 问号
- (void)wenhaoClickAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

// 购买会员界面跳转
- (void)pushBuyVipClick;

@end

@interface HLQingRenCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (nonatomic, assign) id <HLQingRenCellDelegate> delegate;

@property (nonatomic, strong) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END
