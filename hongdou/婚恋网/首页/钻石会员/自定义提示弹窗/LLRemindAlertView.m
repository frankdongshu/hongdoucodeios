//
//  LLRemindAlertView.m
//  hongdou
//
//  Created by 维康1 on 2020/8/25.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLRemindAlertView.h"

@implementation LLRemindAlertView




- (void)showSelf {
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

- (void)removeSelf {
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
