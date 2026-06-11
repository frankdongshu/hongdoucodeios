//
//  HLMemberTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/11/1.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLMemberTableViewCell.h"

@implementation HLMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMemberModel:(HLMemberModel *)memberModel{
    _memberModel = memberModel;
    self.titleLabel.text = memberModel.title;
    self.payPriceLabel.text = [NSString stringWithFormat:@"¥ %@",memberModel.money];
    
    NSString *textStr = [NSString stringWithFormat:@"%@", memberModel.price];
    //中划线
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
    // 赋值
    self.orginPriceLabel.attributedText = attribtStr;
    
    self.discountLabel.text = memberModel.discount;

}

- (IBAction)payBuyProduct:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectBuyButtonWithProductID:)]) {
        
//        [self.delegate didSelectBuyButtonWithProductID:self.memberModel.spid];
        [self.delegate didSelectBuyButtonWithProductID:self.memberModel.ProductId];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
