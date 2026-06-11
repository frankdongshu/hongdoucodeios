//
//  UITextField+HYLHelp.h
//  HYLSurveillant
//
//  Created by Jy on 2017/6/29.
//  Copyright © 2017年 jy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (HYLHelp)

- (void)textfileLayercornerRadius:(CGFloat)radius borderColor:(UIColor *)color titil:(NSString *)title;

- (void)textFileTitle:(NSString *)title leftWidth:(CGFloat)width heigth:(CGFloat)heigth;

- (UIView *)definRigthView;
- (void)chgangePlaceholderColor:(NSString *)placeHolder;
@end
