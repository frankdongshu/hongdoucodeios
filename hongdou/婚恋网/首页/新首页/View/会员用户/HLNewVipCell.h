//
//  HLNewVipCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLNewVipCellDelegate <NSObject>

// 跳转开通会员界面
- (void)pushVip;

// 跳转详情页
- (void)pushVipDetailWithId:(NSString *)uid;

@end

@interface HLNewVipCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, assign) id <HLNewVipCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
