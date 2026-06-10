//
//  UITableViewCell+HYLHelp.h
//  HYLSurveillant
//
//  Created by Jy on 2017/7/28.
//  Copyright © 2017年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (HYLHelp)

/**
 *  添加两端没有中断的线
 */
- (void)addLineNoBreak ;

/**
 *  添加两端中断的线
 */
- (void)addLineWithBreak ;

/**
 *  添加左端中断的线
 */
- (void)addLinleftBreak ;

@end
