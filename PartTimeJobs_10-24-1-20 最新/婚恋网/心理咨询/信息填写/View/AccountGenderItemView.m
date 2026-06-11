//
//  AccountGenderItemView.m
//  ShuShangShuo
//
//  Created by LCC on 2018/11/17.
//  Copyright © 2018年 lanmao. All rights reserved.
//

#import "AccountGenderItemView.h"

@implementation AccountGenderItemView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)setType:(AccountGenderItemType)type{
    _type = type;
    [self createUI];
}

- (void)setGender:(NSString *)gender{
    if (_gender != gender) {
        _gender = gender;
        if(gender.integerValue != 0 && gender.integerValue != 1){
            self.womenButton.selected = NO;
            self.manButton.selected = NO;
        }else if (gender.integerValue == 0) {//男
            self.womenButton.selected = NO;
            self.manButton.selected = YES;
        }else{//女
            self.womenButton.selected = YES;
            self.manButton.selected = NO;
        }
    }
}

- (void)createUI{
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.text = @"性别";
    titleLable.font = kFontSize(14);
    titleLable.textAlignment = NSTextAlignmentLeft;
    self.titleLabel = titleLable;
    [self addSubview:titleLable];
    
    UIButton *manButton = [UIButton buttonWithType:UIButtonTypeCustom];
    manButton.backgroundColor = [UIColor clearColor];
    [manButton setTitle:@"男" forState:UIControlStateNormal];
    manButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [manButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [manButton setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    [manButton setImage:[UIImage imageNamed:@"checkbox_selected"] forState:UIControlStateSelected];
    manButton.titleLabel.font = kFontSize(13);
    manButton.tag = 100;
    self.manButton = manButton;
    [self addSubview:manButton];



    UIButton *womenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    womenButton.backgroundColor = [UIColor clearColor];
    [womenButton setTitle:@"女" forState:UIControlStateNormal];
    womenButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [womenButton setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
    [womenButton setImage:[UIImage imageNamed:@"checkbox_selected"] forState:UIControlStateSelected];
    [womenButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    womenButton.titleLabel.font = kFontSize(13);
    womenButton.tag = 101;
    self.womenButton = womenButton;
    [self addSubview:womenButton];
    
    if (_type == LeftRightType) {
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.height.offset(15);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.width.offset(100);
        }];

        [womenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).mas_offset(-15);
            make.height.offset(20);
            make.width.offset(60);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
        
        [manButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(womenButton.mas_left).offset(-10);
            make.height.offset(20);
            make.width.offset(60);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }else if(_type == TopBottomType){
        
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.height.offset(15);
            make.top.mas_equalTo(20);
            make.width.offset(100);
        }];

        [manButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(15);
            make.height.offset(20);
            make.width.offset(60);
            make.top.mas_equalTo(titleLable.mas_bottom).mas_offset(14);
        }];
        
        [womenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(manButton.mas_right).mas_offset(30);
            make.height.offset(20);
            make.width.offset(60);
            make.top.mas_equalTo(titleLable.mas_bottom).mas_offset(14);
        }];
        
    }else{
        
        
        UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdButton.backgroundColor = [UIColor clearColor];
        [thirdButton setTitle:@"女" forState:UIControlStateNormal];
        thirdButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [thirdButton setImage:[UIImage imageNamed:@"checkbox_normal"] forState:UIControlStateNormal];
        [thirdButton setImage:[UIImage imageNamed:@"checkbox_selected"] forState:UIControlStateSelected];
        [thirdButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        thirdButton.titleLabel.font = kFontSize(13);
        thirdButton.tag = 102;
        self.thirdButton = thirdButton;
        [self addSubview:thirdButton];

        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.height.offset(15);
            make.top.mas_equalTo(20);
            make.width.offset(100);
        }];
        
        [manButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(15);
            make.height.offset(20);
            make.width.offset(60);
            make.top.mas_equalTo(titleLable.mas_bottom).mas_offset(14);
        }];
        
        [womenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(manButton.mas_right).mas_offset(30);
            make.height.offset(20);
            make.width.offset(60);
            make.top.mas_equalTo(titleLable.mas_bottom).mas_offset(14);
        }];
        
        [thirdButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(womenButton.mas_right).mas_offset(30);
            make.height.offset(20);
            make.width.offset(60);
            make.top.mas_equalTo(titleLable.mas_bottom).mas_offset(14);
        }];


    }
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = HEXColor(@"e5e5e5");
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(-15);
        make.bottom.equalTo(self.mas_bottom);
        make.height.offset(1);
    }];

}
@end
