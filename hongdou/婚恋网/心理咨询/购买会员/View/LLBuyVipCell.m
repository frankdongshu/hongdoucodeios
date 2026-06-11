//
//  LLBuyVipCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/17.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLBuyVipCell.h"

@implementation LLBuyVipCell

- (void)setTheModel:(LLBuyVipModel *)theModel {
    _theModel = theModel;
    
    self.dayLab.text = [NSString stringWithFormat:@"%@天",theModel.day];
    self.priceLab.text = [NSString stringWithFormat:@"%@元",theModel.money];
    
}
- (IBAction)buyBtnClick:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectBuyButtonWithProductID:)]) {
        [self.delegate didSelectBuyButtonWithProductID:self.theModel.type];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.priceLab.textColor = REDColor;
    
    
    [self.goBtn setTitleColor:REDColor forState:UIControlStateNormal];
    self.goBtn.layer.borderColor = REDColor.CGColor;
    self.goBtn.layer.borderWidth = 1;
    self.goBtn.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
