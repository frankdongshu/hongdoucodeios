//
//  UITableViewCell+HYLHelp.m
//  HYLSurveillant
//
//  Created by Jy on 2017/7/28.
//  Copyright © 2017年 jy. All rights reserved.
//

#import "UITableViewCell+HYLHelp.h"

@implementation UITableViewCell (HYLHelp)

- (void)addLineNoBreak {
    
    
    //    self.separatorInset = UIEdgeInsetsMake(0, kRectScreenWidth, 0, 0);
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@0.3);
    }];
    
}

- (void)addLineWithBreak {
    //    self.separatorInset = UIEdgeInsetsMake(0, kRectScreenWidth, 0, 0);
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.right.equalTo(@(-10));
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@0.3);
    }];
}

- (void)addLinleftBreak{
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    [self.contentView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.right.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(0.3));
    }];
}



@end
