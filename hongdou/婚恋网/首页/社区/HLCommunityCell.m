//
//  HLCommunityCell.m
//  hongdou
//
//  Created by user on 2022/3/15.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLCommunityCell.h"

@implementation HLCommunityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backView.layer.borderColor = [UIColor systemGray5Color].CGColor;
    self.backView.layer.borderWidth = .8;
    self.backView.layer.cornerRadius = 8;
    self.backView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
