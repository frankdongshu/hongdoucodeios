//
//  HLAlertOpenVipView.m
//  hongdou
//
//  Created by 维康1 on 2020/8/24.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLAlertOpenVipView.h"

@implementation HLAlertOpenVipView


- (instancetype)initWithFrame:(CGRect)frame andMessage:(NSString *)message {
    if ([super initWithFrame:frame]) {
        
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(50, kScreenHeight/2-100, kScreenWidth-100, 200);
        view.backgroundColor = [UIColor whiteColor];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 8;
        
        [self addSubview:view];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 150)];
        lab.text = message;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor darkGrayColor];
        
        [view addSubview:lab];
        
        
        // 横分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame), view.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor systemGray5Color];
        [view addSubview:lineView];
        
        
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), view.frame.size.width/2-0.5, 49);
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        leftBtn.tag = 222;
        [leftBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:leftBtn];
        
        // 竖分割线
        UIView *shuLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftBtn.frame), CGRectGetMaxY(lab.frame), 1, 49)];
        shuLineView.backgroundColor = [UIColor systemGray5Color];
        [view addSubview:shuLineView];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(CGRectGetMaxX(shuLineView.frame), CGRectGetMaxY(lineView.frame), view.frame.size.width/2-0.5, 49);
        [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        rightBtn.tag = 223;
        [rightBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:rightBtn];
        
        
    }
    return self;
}

- (void)sureClick:(UIButton *)sender {
    
    if (sender.tag == 222) {
        [self removeSelf];
    } else {
        [self removeSelf];
        self.SelectBlock();
    }
    
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
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
