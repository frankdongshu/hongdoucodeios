//
//  LLFaBuCell.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLFaBuCell.h"

@implementation LLFaBuCell

- (void)setModel:(LLFaBuModel *)model {
    _model = model;
    
    self.keChengLab.text = model.curriculum;
    self.priceLab.text = [NSString stringWithFormat:@"%@/%@ 小时",model.cost_low,model.cost_high];
    
    self.biaoQianLab.text = [NSString stringWithFormat:@"%@|%@",model.identity,[model.teaching stringByReplacingOccurrencesOfString:@"," withString:@"|"]];
    
    self.miaoShuLab.text = [NSString stringWithFormat:@"描述: %@",model.demand];
    self.shiJianLab.text = model.addtime;
    
    self.deleteBtn.tag = model.iid;
    
}

- (IBAction)deleteClick:(UIButton *)sender {
    
    if([_delegate respondsToSelector:@selector(removeClickWithIdx:)]){
        [_delegate removeClickWithIdx:sender.tag];
    }
    
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
