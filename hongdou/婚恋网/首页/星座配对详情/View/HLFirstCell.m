//
//  HLFirstCell.m
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLFirstCell.h"

@implementation HLFirstCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.xingZuoVsLab.layer.masksToBounds = YES;
    self.xingZuoVsLab.layer.cornerRadius = 13;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
