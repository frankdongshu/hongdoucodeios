//
//  LLActivityCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLActivityCell.h"

@implementation LLActivityCell

- (void)setActivityInfo:(LLActivityModel *)actModel withCurrentIndex:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self.imgV sd_setImageWithURL:[NSURL URLWithString:actModel.being.pic]];
        self.nameLab.text = actModel.being.name;
        self.timeLab.text = [NSString stringWithFormat:@"%@-%@",actModel.being.start_time,actModel.being.end_time];
        self.numLab.text = [NSString stringWithFormat:@"%@以上可参与",actModel.being.mininv];
        self.awardNumLab.text = [NSString stringWithFormat:@"排名前%@可获得奖品",actModel.being.number];
        self.explainLab.text = actModel.being.introduce;
    }
    else {
        
        LLFutureModel *mod = actModel.future[indexPath.row];
        
        [self.imgV sd_setImageWithURL:[NSURL URLWithString:mod.pic]];
        self.nameLab.text = mod.name;
        self.timeLab.text = [NSString stringWithFormat:@"%@-%@",mod.start_time,mod.end_time];
        self.numLab.text = [NSString stringWithFormat:@"%@以上可参与",mod.mininv];
        self.awardNumLab.text = [NSString stringWithFormat:@"排名前%@可获得奖品",mod.number];
        self.explainLab.text = mod.introduce;
        
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.numLab.textColor = kRGBA(255, 92, 121, 1);
    self.awardNumLab.textColor = kRGBA(255, 92, 121, 1);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
