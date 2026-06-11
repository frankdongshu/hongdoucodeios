//
//  HXBaseTableViewCell.m
//  HXNavigationController
//
//  Created by iMac on 16/8/1.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import "HXBaseTableViewCell.h"

@implementation HXBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHiddenSelfSeparator:(BOOL)hiddenSelfSeparator
{
    _hiddenSelfSeparator = hiddenSelfSeparator;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    if (_hiddenSelfSeparator) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.82 green:0.82 blue:0.84 alpha:1].CGColor);
    
    if (_fullScreenSeparator) {
        CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
        return;
    }
    
    if (self.isEditing && !self.imageView.image) {
        
        CGContextStrokeRect(context, CGRectMake(40, rect.size.height, rect.size.width - 52, 1));
        
    }else
    {
        CGContextStrokeRect(context, CGRectMake(8, rect.size.height, rect.size.width - 16, 1));
    }
    
}
@end
