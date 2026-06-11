//
//  HLConstellationCell.h
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWStarRateView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLConstellationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *containerLab;
@property (weak, nonatomic) IBOutlet UILabel *oneLab;
@property (weak, nonatomic) IBOutlet UILabel *twoLab;
@property (weak, nonatomic) IBOutlet UILabel *threeLab;
@property (weak, nonatomic) IBOutlet UILabel *fourLab;
@property (weak, nonatomic) IBOutlet CWStarRateView *pdStarView;
@property (weak, nonatomic) IBOutlet CWStarRateView *lqStarView;
@property (weak, nonatomic) IBOutlet CWStarRateView *tcStarView;

@property (nonatomic, strong) NSDictionary *theDic;

@end

NS_ASSUME_NONNULL_END
