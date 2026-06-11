//
//  HLWishCell.m
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLWishCell.h"

@implementation HLWishCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imgView.layer.cornerRadius = 7;
    self.imgView.layer.masksToBounds = YES;
    
    self.imgView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imgView.layer.borderWidth = 1;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
