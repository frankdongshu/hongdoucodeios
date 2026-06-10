//
//  HLPhotoAlbumTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/5/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPhotoAlbumTableViewCell.h"

@implementation HLPhotoAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectHeaderImage1)];
    [self.addImageView addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectHeaderImage2)];
    [self.fristImageView addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectHeaderImage3)];
    [self.secondImageView addGestureRecognizer:tap3];

}


- (void)setUserModel:(HLUser *)userModel{
    _userModel = userModel;
    [self.addImageView sd_setImageWithURL: [NSURL URLWithString:userModel.pic_one] placeholderImage:[UIImage imageNamed:@"add_photo"]];
    [self.fristImageView sd_setImageWithURL: [NSURL URLWithString:userModel.pic_two] placeholderImage:[UIImage imageNamed:@"add_photo"]];
    [self.secondImageView sd_setImageWithURL: [NSURL URLWithString:userModel.pic_three] placeholderImage:[UIImage imageNamed:@"add_photo"]];
}

- (void)selectHeaderImage1{
    if (self.userModel.pic_one.length > 0) {
        // 删除操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoDeleteClick:)]) {
            [self.delegate photoDeleteClick:@"one"];
        }
    }else{
        // 添加操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoAddClick:)]) {
            [self.delegate photoAddClick:@"one"];
        }
    }
    
}
- (void)selectHeaderImage2{
    if (self.userModel.pic_two.length > 0) {
        // 删除操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoDeleteClick:)]) {
            [self.delegate photoDeleteClick:@"two"];
        }
    }else{
        // 添加操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoAddClick:)]) {
            [self.delegate photoAddClick:@"two"];
        }
    }
    
    
}

- (void)selectHeaderImage3{
    if (self.userModel.pic_three.length > 0) {
        // 删除操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoDeleteClick:)]) {
            [self.delegate photoDeleteClick:@"three"];
        }
    }else{
        // 添加操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoAddClick:)]) {
            [self.delegate photoAddClick:@"three"];
        }
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
