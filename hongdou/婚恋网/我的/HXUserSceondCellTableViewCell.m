//
//  HXUserSceondCellTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/3/28.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HXUserSceondCellTableViewCell.h"

@interface HXUserSceondCellTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contenrLabel;

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end

@implementation HXUserSceondCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setCellInfo:(NSString *)imageName withTitle:(NSString *)title withContent:(NSString *)content withContentImage:(NSString *)contentImageName{
    [_titleImageView setImage:[UIImage imageNamed:imageName]];
    _titleLabel.text = title;
    _contenrLabel.text = content;
    [_contentImageView setImage:[UIImage imageNamed:contentImageName]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
