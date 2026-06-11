//
//  HLPhotoTopTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPhotoTopTableViewCell.h"

@implementation HLPhotoTopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)publicClick:(id)sender {
    if (self.publicPhotoBlock) {
        self .publicPhotoBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
