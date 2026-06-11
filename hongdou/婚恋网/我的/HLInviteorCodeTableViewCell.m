//
//  HLInviteorCodeTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLInviteorCodeTableViewCell.h"

@implementation HLInviteorCodeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 7.5f;
    self.layer.masksToBounds = YES;
    
    self.inviteImgV.layer.masksToBounds = YES;
    self.inviteImgV.layer.cornerRadius = 17.5;
}
- (IBAction)inviteClick:(id)sender {
    if (self.inviteBlock) {
        self.inviteBlock();
    }
    
}

// 复制按钮
- (IBAction)fuZhiClick:(UIButton *)sender {
    
    //系统级别
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.contentLabel.text;
    
    [kAppDelegate.window showSuccessWithMessage:@"复制成功"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
