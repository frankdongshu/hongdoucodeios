//
//  HXContextTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/5/20.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXContextTableViewCell.h"

@implementation HXContextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.myVoiceTextView.editable = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
