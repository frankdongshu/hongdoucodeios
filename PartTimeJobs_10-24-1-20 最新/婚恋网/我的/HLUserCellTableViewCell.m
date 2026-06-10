//
//  HLUserCellTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/3/26.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLUserCellTableViewCell.h"

@interface HLUserCellTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contenrLabel;

@end

@implementation HLUserCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellInfo:(NSString *)imageName withTitle:(NSString *)title withContent:(NSString *)content{
    [_titleImageView setImage:[UIImage imageNamed:imageName]];
    _titleLabel.text = title;
    _contenrLabel.text = content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
