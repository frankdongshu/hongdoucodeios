//
//  UIColor+HYLHelper.m
//  HYLBeSurveillant
//
//  Created by Jy on 2017/6/27.
//  Copyright © 2017年 jy. All rights reserved.
//

#import "UIColor+HYLHelper.h"

@implementation UIColor (HYLHelper)

+ (UIColor *)colorWithHex:(NSInteger)hex {
    return [self colorWithHex:hex alpha:1];
}

+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha {
    
    
    CGFloat red = ((hex & 0xFF0000) >> 16);
    CGFloat green = ((hex & 0xFF00) >> 8);
    CGFloat blue = (hex & 0xFF);
    
    return [UIColor colorWithRed:red / 255.0f
                           green:green / 255.0f
                            blue:blue / 255.0f
                           alpha:alpha];
}


@end
