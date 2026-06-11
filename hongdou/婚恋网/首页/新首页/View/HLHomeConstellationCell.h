//
//  HLHomeConstellationCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/2.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStarRateView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLHomeConstellationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *xingzuoLab;
@property (weak, nonatomic) IBOutlet UILabel *aiqingzhishuLab;
@property (weak, nonatomic) IBOutlet CWStarRateView *loveStarView;
@property (weak, nonatomic) IBOutlet UILabel *supeiLab;
@property (weak, nonatomic) IBOutlet UILabel *jianyiLab;

@property (nonatomic, strong) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END
