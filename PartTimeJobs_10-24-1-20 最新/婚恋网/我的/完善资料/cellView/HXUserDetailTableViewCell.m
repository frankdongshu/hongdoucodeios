//
//  HXUserDetailTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/3/29.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HXUserDetailTableViewCell.h"

@implementation HXUserDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setCellTitle:(NSString *)title withprompt:(NSString *)prompt withContent:(NSString *)content{
    _titleLable.text = title;
    _promptLable.text = prompt;
    _contentLabel.text = content;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
