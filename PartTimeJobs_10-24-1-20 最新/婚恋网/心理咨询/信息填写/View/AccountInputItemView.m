//
//  AccountInputItemView.m
//  ShuShangShuo
//
//  Created by LCC on 2018/10/16.
//  Copyright © 2018年 lanmao. All rights reserved.
//

#import "AccountInputItemView.h"

#define itemViewHeight 40
@implementation AccountInputItemView

- (instancetype)init{
    if (self= [super init]) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kFontSize(14);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor blackColor];
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.top.equalTo(self.mas_top).mas_offset(20);
        make.height.offset(15);
        make.width.offset(100);
    }];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.placeholder = [NSString stringWithFormat:@"请输入%@",titleLabel.text];
    textField.font = kFontSize(15);
    self.textField = textField;
    [self addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.height.offset(20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(14);
        make.width.offset(kScreenWidth-30);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = HEXColor(@"e5e5e5");
    self.lineView = line;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.height.offset(1);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.offset(kScreenWidth-30);
    }];
}

@end
