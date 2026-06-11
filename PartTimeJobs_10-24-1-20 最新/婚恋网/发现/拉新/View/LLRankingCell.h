//
//  LLRankingCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLActivityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLRankingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rankingLab;
@property (weak, nonatomic) IBOutlet UIImageView *medalImgV;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UILabel *cityLab;

- (void)setActivityInfo:(LLActivityModel *)actModel withCurrentIndex:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
