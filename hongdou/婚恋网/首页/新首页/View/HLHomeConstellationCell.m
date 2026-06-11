//
//  HLHomeConstellationCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/2.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLHomeConstellationCell.h"

@implementation HLHomeConstellationCell

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    self.xingzuoLab.text = [NSString stringWithFormat:@"作为%@的你，",kISNullObject(dic[@"constellation"])?@"":dic[@"constellation"]];
    
    self.loveStarView.scorePercent = [dic[@"love_star"] floatValue]*0.2;
    self.loveStarView.allowIncompleteStar = YES;
    
    self.supeiLab.text = [NSString stringWithFormat:@"速配星座是: %@",kISNullObject(dic[@"grxz"])?@"":dic[@"grxz"]];
    self.jianyiLab.text = dic[@"love_txt"];
    
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
