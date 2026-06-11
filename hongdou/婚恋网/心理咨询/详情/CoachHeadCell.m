//
//  CoachHeadCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CoachHeadCell.h"

@implementation CoachHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.contentView az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xF3B2A1],[UIColor colorWithHex:0xEE7998]] locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
