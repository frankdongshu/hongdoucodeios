//
//  LLBuyVipHeaderView.m
//  hongdou
//
//  Created by 李龙 on 2020/3/17.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLBuyVipHeaderView.h"

@implementation LLBuyVipHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self addSubview:self.typeLabel];
        [self addSubview:self.moneyLabel];
        
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(15);
        }];
        
        [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.equalTo(self.typeLabel.mas_bottom).mas_offset(15);
        }];
        
    }
    return self;
}

-(UILabel *)typeLabel{
    if (_typeLabel == nil) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.textColor = REDColor;
        _typeLabel.font = [UIFont systemFontOfSize:17];
    }
    return _typeLabel;
}

-(UILabel *)moneyLabel{
    if (_moneyLabel == nil) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = HEXColor(@"999999");
        _moneyLabel.text = @"选择续费时长";
        _moneyLabel.font = [UIFont systemFontOfSize:17];

    }
    return _moneyLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
