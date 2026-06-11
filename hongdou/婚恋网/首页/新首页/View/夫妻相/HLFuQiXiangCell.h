//
//  HLFuQiXiangCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLFuQiXiangCellDelegate <NSObject>

// 夫妻相跳转详情页
- (void)pushFuQiXiangDetail;

@end

@interface HLFuQiXiangCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *dic;
@property (weak, nonatomic) IBOutlet UIImageView *benRenImgV;
@property (weak, nonatomic) IBOutlet UIImageView *taImgView;

@property (nonatomic, assign) id <HLFuQiXiangCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
