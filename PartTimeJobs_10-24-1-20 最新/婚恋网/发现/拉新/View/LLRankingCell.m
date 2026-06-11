//
//  LLRankingCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLRankingCell.h"

@implementation LLRankingCell

- (void)setActivityInfo:(LLActivityModel *)actModel withCurrentIndex:(NSIndexPath *)indexPath {
    
    self.rankingLab.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    if (indexPath.row < 3) { //
        self.medalImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"jiang%ld",indexPath.row]];
    }
    
    LLRankingModel *model = actModel.being.ranking[indexPath.row];
    
    [self.headImgV sd_setImageWithURL:[NSURL URLWithString:model.head]];
    self.numberLab.text = [NSString stringWithFormat:@"%@人",model.c];
    self.nameLab.text = [NSString stringWithFormat:@"%@",model.nickname];
    self.cityLab.text = [NSString stringWithFormat:@"%@",model.habitation];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
