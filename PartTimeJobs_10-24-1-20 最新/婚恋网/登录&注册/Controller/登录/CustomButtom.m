//
//  CustomButtom.m
//  ShuShangShuo
//
//  Created by 这是一个笑脸 on 2019/7/17.
//  Copyright © 2019 lanmao. All rights reserved.
//

#import "CustomButtom.h"

@implementation CustomButtom

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setType:(ZYGButtonEdgeInsetsStyle)type{
    _type = type;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGRect customRect =   [super imageRectForContentRect:contentRect];
    customRect.origin.x = contentRect.size.width /2.0 - customRect.size.width / 2.0;
    customRect.origin.y = 24;
    return customRect;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect customRect =   [super titleRectForContentRect:contentRect];
    customRect.origin.x = 0;
    customRect.size.width = contentRect.size.width;
    customRect.origin.y = self.imageView.frame.size.height + self.imageView.frame.origin.y + 8;
    return customRect;
}

@end
