//
//  HLGaoYanZhiCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLGaoYanZhiCellDelegate <NSObject>

// 跳转详情页
- (void)pushGaoYanZhiDetailWithId:(NSString *)uid;

- (void)pushVipClick;

@end

@interface HLGaoYanZhiCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, assign) id <HLGaoYanZhiCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
