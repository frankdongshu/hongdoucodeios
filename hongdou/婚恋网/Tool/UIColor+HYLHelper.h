//
//  UIColor+HYLHelper.h
//  HYLBeSurveillant
//
//  Created by Jy on 2017/6/27.
//  Copyright © 2017年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *该类别用于将十六位数值的颜色变成UIColor
 */
@interface UIColor (HYLHelper)

/**
 *  用于将十六位数值的颜色变成UIColor，没有透明通道
 *
 *  @param hex 颜色的十六位数值
 *
 *  @return 该色值的Color
 */
+ (UIColor *)colorWithHex:(NSInteger)hex;
/**
 *  用于将十六位数值的颜色变成UIColor，有透明通道
 *
 *  @param hex   颜色的十六位数值
 *  @param alpha 该透明通道的色值
 *
 *  @return 该色值的Color
 */
+ (UIColor *)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;

@end
