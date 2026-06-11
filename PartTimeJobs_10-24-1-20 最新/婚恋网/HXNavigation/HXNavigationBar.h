//
//  HXNavigationBar.h
//  HXNavigationController
//
//  Created by iMac on 16/7/21.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXNavigationBar : UIView

@property (nonatomic, assign  ) BOOL isTransition;
@property (nonatomic, assign  ) BOOL notNeedLayoutSubviews;
@property (nonatomic, assign  ) CGFloat backgroundAlpha;
@property (nonatomic, strong  ) HXBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong  ) HXBarButtonItem *rightBarButtonItem;
//@property (nonatomic, strong) NSArray *rightBarButtonItems;
@property (nonatomic, copy    ) NSString        *title;

@property (nonatomic, strong  ) UIView          *titleView; //如果设置了titleView，则隐藏titleLabel,只能二选一
@property (nonatomic, readonly) UILabel         *titleLabel;

@property (nonatomic,strong)UIColor *currentNavColor; // 改变当前导航颜色  单一颜色
@property (nonatomic,strong)NSArray *colorArray; // 改变当前导航颜色 颜色数组  为了渐变色

@end
