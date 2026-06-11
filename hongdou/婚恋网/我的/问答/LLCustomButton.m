//
//  LLCustomButton.m
//  hongdou
//
//  Created by 李龙 on 2020/6/23.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLCustomButton.h"

@implementation LLCustomButton

- (void)setImgViewPointX:(CGFloat)imgViewPointX {
    _imgViewPointX = imgViewPointX;
}

- (void)setTitlePointX:(CGFloat)titlePointX {
    _titlePointX = titlePointX;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /** 修改 title 的 frame */
    // 1.获取 titleLabel 的 frame
    CGRect titleLabelFrame = self.titleLabel.frame;
    // 2.修改 titleLabel 的 frame
    titleLabelFrame.origin.x = _titlePointX;
    // 3.重新赋值
    self.titleLabel.frame = titleLabelFrame;
    
    /** 修改 imageView 的 frame */
    // 1.获取 imageView 的 frame
    CGRect imageViewFrame = self.imageView.frame;
    // 2.修改 imageView 的 frame
    imageViewFrame.origin.x = titleLabelFrame.size.width+_imgViewPointX;
    // 3.重新赋值
    self.imageView.frame = imageViewFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
