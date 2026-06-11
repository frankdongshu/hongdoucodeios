//
//  CSEducationDetailCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSEducationDetailCell.h"

@implementation CSEducationDetailCell

- (void)setFrame:(CGRect)frame
{
    //修改cell的左右边距为10;
    //修改cell的Y值下移10;
    //修改cell的高度减少10;

    static CGFloat margin = 15;
    frame.origin.x = margin;
    frame.size.width -= 2 * frame.origin.x;

    [super setFrame:frame];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = kRGBA(244, 244, 249, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
