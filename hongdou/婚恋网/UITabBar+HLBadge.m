//
//  UITabBar+HLBadge.m
//  hongdou
//
//  Created by 维康1 on 2019/12/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "UITabBar+HLBadge.h"

#define TabbarItemNums 5.0


@implementation UITabBar (HLBadge)

// 显示红点
- (void)showBadgeOnItemIndex:(int)index unNumber:(NSString *)unNumber {

    [self removeBadgeOnItemIndex:index];
    // 新建小红点
    UILabel *bview = [[UILabel alloc]init];
    bview.textAlignment = NSTextAlignmentCenter;
    bview.text = unNumber;
    bview.font = [UIFont systemFontOfSize:13];
    bview.textColor = kRGB(234,234,245);
    bview.tag = 888 + index;
    bview.layer.cornerRadius = 8;
    bview.clipsToBounds = YES;
    bview.backgroundColor = kRGB(251,75,120);
    CGRect tabFram = self.frame;
    
    float percentX = (index+0.18) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFram.size.width);
    CGFloat y = 5;
    bview.frame = CGRectMake(x, y, 16, 16);
    [self addSubview:bview];
    [self bringSubviewToFront:bview];
}

// 隐藏红点
- (void)hideBadgeOnItemIndex:(int)index {

    [self removeBadgeOnItemIndex:index];
}
// 移除控件
- (void)removeBadgeOnItemIndex:(int)index {

    for (UILabel *subView in self.subviews) {
        if (subView.tag == 888 + index) {
            [subView removeFromSuperview];
        }
    }
}




@end
