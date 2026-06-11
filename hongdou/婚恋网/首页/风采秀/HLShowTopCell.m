//
//  HLShowTopCell.m
//  hongdou
//
//  Created by user on 2022/8/4.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLShowTopCell.h"

@implementation HLShowTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.navHeight.constant = -kNavBarHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
