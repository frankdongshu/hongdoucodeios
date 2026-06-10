//
//  LLFindJiaJiaoCell.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLFindJiaJiaoCell.h"

@implementation LLFindJiaJiaoCell


- (void)setModel:(LLFaBuModel *)model {
    _model = model;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.head]];
    
    self.titleLab.text = [NSString stringWithFormat:@"%@ %@",model.nickname,model.city];
    self.priceLab.text = [NSString stringWithFormat:@"%@-%@/小时",model.cost_low,model.cost_high];
    
    self.tagLab.text = [NSString stringWithFormat:@"%@  | %@",model.education,[model.school stringByReplacingOccurrencesOfString:@"," withString:@"|"]];
    
    self.descLab.text = [NSString stringWithFormat:@"介绍: %@",model.demand];
    self.timeLab.text = model.addtime;
    
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
