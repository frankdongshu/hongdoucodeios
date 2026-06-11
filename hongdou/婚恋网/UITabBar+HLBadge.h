//
//  UITabBar+HLBadge.h
//  hongdou
//
//  Created by 维康1 on 2019/12/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (HLBadge)

- (void)showBadgeOnItemIndex:(int)index unNumber:(NSString *)unNumber;
- (void)hideBadgeOnItemIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
