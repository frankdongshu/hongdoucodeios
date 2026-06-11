//
//  HLSecondCell.h
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStarRateView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSecondCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pdLab; // 配对指数
@property (weak, nonatomic) IBOutlet UILabel *lqLab; // 两情相悦指数
@property (weak, nonatomic) IBOutlet UILabel *tcLab; // 天长地久指数
@property (weak, nonatomic) IBOutlet CWStarRateView *pdStarView;
@property (weak, nonatomic) IBOutlet CWStarRateView *lqStarView;
@property (weak, nonatomic) IBOutlet CWStarRateView *tcStarView;

@property (nonatomic, strong) NSDictionary *contentDic;

@end

NS_ASSUME_NONNULL_END
