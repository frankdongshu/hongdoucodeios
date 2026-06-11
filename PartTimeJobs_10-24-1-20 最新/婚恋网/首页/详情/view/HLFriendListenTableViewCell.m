//
//  HLFriendListenTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFriendListenTableViewCell.h"

@implementation HLFriendListenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.palanceLabel.layer.cornerRadius = 6.f;
    self.palanceLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
