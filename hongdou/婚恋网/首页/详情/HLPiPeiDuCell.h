//
//  HLPiPeiDuCell.h
//  hongdou
//
//  Created by 李龙 on 2020/6/23.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZCircleProgress.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLPiPeiDuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ZZCircleProgress *circleView;
@property (weak, nonatomic) IBOutlet UILabel *sameAskLab;
@property (weak, nonatomic) IBOutlet UILabel *sameDaAn;
@property (weak, nonatomic) IBOutlet UILabel *desLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

@end

NS_ASSUME_NONNULL_END
