//
//  HXuserDetailHeaderTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/3/29.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HXuserDetailHeaderTableViewCell.h"



@implementation HXuserDetailHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headerImageView.layer.cornerRadius = 36.f;
    self.headerImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (IBAction)alterheadImageClick:(id)sender {
    if (self.alterHeadBlock) {
        [self alterHeadBlock];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
