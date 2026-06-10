//
//  HXNavigationBar.m
//  HXNavigationController
//
//  Created by iMac on 16/7/21.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import "HXNavigationBar.h"

@interface HXNavigationBar ()
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@end

@implementation HXNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = (CGRect){0, 0, kScreenWidth, kNavigationBarHeight};
        _backgroundAlpha = 1;
        
        self.backgroundColor = kNavigationBarColor;
        
        self.lineView = [[UIView alloc] initWithFrame:(CGRect){0, kNavigationBarHeight, kScreenWidth, 0.5}];
        self.lineView.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.84 alpha:1];
        [self addSubview:self.lineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)setCurrentNavColor:(UIColor *)currentNavColor{
    _currentNavColor = currentNavColor;

    // 外部使用调用方法
    /*
    self.sc_navigationBar.currentNavColor = [UIColor yellowColor];
     */
    self.backgroundColor = [currentNavColor colorWithAlphaComponent:self.backgroundAlpha];
    self.lineView.backgroundColor = [currentNavColor colorWithAlphaComponent:self.backgroundAlpha];
}

- (void)setColorArray:(NSArray *)colorArray{
    // 外部使用调用方法
    /*
         self.sc_navigationBar.colorArray = @[[UIColor colorWithHex:0xF3B2A1],[UIColor colorWithHex:0xEE7998]];
     //  [UIColor colorWithHex:0xF3B2A1]  colorWithHex 这个方法我是写的扩展类里面的方法 加载的16进制的颜色 你要是这样写会报错  自己写    [UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]

     备注 颜色是从F3B2A1 到这个色值过度  这个根据自己所需要来写
     */
    // locations 是过渡点位置
    //CGPointMake(0,0)起始点  CGPointMake(1.0, 1.0)结束点  左上角 到右下角过度样色
    
    //  az_setGradientBackgroundWithColors 方法 是用UIVIew的扩展类  在.pch 导入#import "UIView+AZGradient.h" 正常使用

    [self az_setGradientBackgroundWithColors:colorArray locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1.0, 1.0)];
    self.lineView.hidden = YES;

    self.titleLabel.textColor = [UIColor whiteColor];
}


-(void)setBackgroundAlpha:(CGFloat)alpha
{
    _backgroundAlpha = alpha;
    self.backgroundColor = [kNavigationBarColor colorWithAlphaComponent:alpha];
    self.lineView.backgroundColor = [kNavigationBarLineColor colorWithAlphaComponent:alpha];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_isTransition) {
        return;
    }
    if (self.notNeedLayoutSubviews) {
        return;
    }
    self.frame = (CGRect){0, self.y, kScreenWidth, kNavigationBarHeight};
    
    self.backgroundColor = [kNavigationBarColor colorWithAlphaComponent:self.backgroundAlpha];
    
    self.lineView.frame=(CGRect){0, kNavigationBarHeight, kScreenWidth, 0.5};
    self.lineView.backgroundColor = [kNavigationBarLineColor colorWithAlphaComponent:self.backgroundAlpha];
    
    if (_leftBarButtonItem) {
        _leftBarButtonItem.view.x = 0;
        _leftBarButtonItem.view.centerY = kStatusBarHeight+22;
    }
    
    if (_rightBarButtonItem) {
        _rightBarButtonItem.view.x = kScreenWidth - _rightBarButtonItem.view.width;
        _rightBarButtonItem.view.centerY = kStatusBarHeight+22;
    }
    
    if (_titleLabel) {
        [_titleLabel sizeToFit];
        NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
        _titleLabel.width = kScreenWidth - otherButtonWidth - 20;
        _titleLabel.centerY = kStatusBarHeight+22;
        _titleLabel.centerX = kScreenWidth/2;
    }
    
    if (_titleView) {
        NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
        _titleView.width = kScreenWidth - otherButtonWidth ;
        _titleView.centerY = kStatusBarHeight+22;
        _titleView.x = self.leftBarButtonItem.view.right;
    }
}

- (void)setTitle:(NSString *)title {
    
    //如果设置了titleLabel，则隐藏titleView，只能二选一
    [_titleView removeFromSuperview];
    _titleView = nil;
    
    _title = title;
    
    if (!title) {
        _titleLabel.text = @"";
        return;
    }
    
    if ([title isEqualToString:_titleLabel.text]) {
        return;
    }
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
        [_titleLabel setTextColor:kNavigationBarTintColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
    }
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
    _titleLabel.width = kScreenWidth - otherButtonWidth - 20;
    _titleLabel.centerY = kStatusBarHeight+22;
    _titleLabel.centerX = kScreenWidth/2;
}

- (void)setTitleView:(UIView *)titleView {
    
    //如果设置了titleView，则隐藏titleLabel
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
    
    [_titleView removeFromSuperview];
    
    _titleView  = titleView;
    
    if (titleView) {
        NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
        _titleView.width = kScreenWidth - otherButtonWidth ;
        _titleView.centerY = kStatusBarHeight+22;
        _titleView.x = self.leftBarButtonItem.view.right;
        [self addSubview:titleView];
    }
}

- (void)setLeftBarButtonItem:(HXBarButtonItem *)leftBarButtonItem {
    
    [_leftBarButtonItem.view removeFromSuperview];
    
    if (leftBarButtonItem) {
        leftBarButtonItem.view.x = 0;
        leftBarButtonItem.view.centerY = kStatusBarHeight+22;
        [self addSubview:leftBarButtonItem.view];
    }
    
    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setRightBarButtonItem:(HXBarButtonItem *)rightBarButtonItem {
    
    [_rightBarButtonItem.view removeFromSuperview];
    
    if (rightBarButtonItem) {
        rightBarButtonItem.view.x = kScreenWidth - rightBarButtonItem.view.width;
        rightBarButtonItem.view.centerY = kStatusBarHeight+22;
        [self addSubview:rightBarButtonItem.view];
    }
    
    _rightBarButtonItem = rightBarButtonItem;
}

//- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems {
//    
//    for (HXBarButtonItem *item in rightBarButtonItems) {
//        item.view.x = kScreenWidth - item.view.width;
//        item.view.centerY = kStatusBarHeight+22;
//        [self addSubview:item.view];
//    }
//    
//}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    
    self.backgroundColor = [kNavigationBarColor colorWithAlphaComponent:self.backgroundAlpha];
    self.lineView.backgroundColor = [kNavigationBarLineColor colorWithAlphaComponent:self.backgroundAlpha];
    [_titleLabel setTextColor:kNavigationBarTintColor];
}

@end
