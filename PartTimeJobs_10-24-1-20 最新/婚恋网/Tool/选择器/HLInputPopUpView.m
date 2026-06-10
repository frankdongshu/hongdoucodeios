//
//  HLInputPopUpView.m
//  婚恋网
//
//  Created by iMac on 2019/9/18.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLInputPopUpView.h"

@interface HLInputPopUpView ()

@property (nonatomic,strong) UIView *backGroudView;

@end
@implementation HLInputPopUpView

+ (instancetype)popInputPopUpView{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self initWithView];
    }
    return self;
}
- (void)initWithView{
    self.backGroudView = [[UIView alloc] initWithFrame:CGRectMake(10, kNavigationBarHeight - 10, kScreenWidth - 20, kScreenHeight - kNavigationBarHeight - 20)];
    self.backGroudView.backgroundColor = [UIColor whiteColor];
    
    self.backGroudView.layer.cornerRadius = 10.f;
    self.backGroudView.layer.masksToBounds = YES;
    
    [self addSubview:self.backGroudView];

}

//弹出
- (void)show
{
    [self showInView:[UIApplication sharedApplication].keyWindow];
}

//添加弹出移除的动画效果
- (void)showInView:(UIView *)view
{
    // 浮现
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint point = self.center;
        self.center = point;
    } completion:^(BOOL finished) {
    }];
    [view addSubview:self];
}
- (void)cancleClick{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        CGPoint point = self.center;
        self.center = point;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)sureClick{
    
}
@end
