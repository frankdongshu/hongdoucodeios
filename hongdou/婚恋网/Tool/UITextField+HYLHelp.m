//
//  UITextField+HYLHelp.m
//  HYLSurveillant
//
//  Created by Jy on 2017/6/29.
//  Copyright © 2017年 jy. All rights reserved.
//

#import "UITextField+HYLHelp.h"


static CGFloat const ktextHeigh =  44;

@implementation UITextField (HYLHelp)

- (void)textfileLayercornerRadius:(CGFloat)radius borderColor:(UIColor *)color titil:(NSString *)title{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
    self.leftView = [self definViewTextTile:title];
    self.leftViewMode = UITextFieldViewModeAlways;
    
}
- (void)textFileTitle:(NSString *)title leftWidth:(CGFloat)width heigth:(CGFloat)heigth{
    self.layer.borderWidth = 0;
    self.leftView = [self definImageViewTextTile:title width:width heigth:heigth];
    self.leftViewMode = UITextFieldViewModeAlways;
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xD3D3D3];
    [self addSubview:lineView];
    __weak typeof(self) weakSelf = self;
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(0);
        make.height.mas_equalTo(0.4);
    }];
}
- (void)chgangePlaceholderColor:(NSString *)placeHolder;{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary]; // 创建属性字典
    attrs[NSForegroundColorAttributeName] = [UIColor grayColor]; // 设置颜色
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:placeHolder attributes:attrs];
    self.attributedPlaceholder = attStr;
}
// 图片标识
- (UIView *)definImageViewTextTile:(NSString *)title width:(CGFloat)width heigth:(CGFloat)heigth{
    
    UIView *leftView = [[UIView alloc] init];
    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:title]];
    [leftView addSubview:leftImage];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, heigth));
    }];
    
    [leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(leftView.mas_centerX);
        make.centerY.mas_equalTo(leftView.centerY);
    }];
    
    return  leftView;
}


// 文字标识
- (UIView *)definViewTextTile:(NSString *)title width:(CGFloat)width{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    UILabel *placeholderLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,width, 44)];
    placeholderLable.textColor = [UIColor blackColor];
    [placeholderLable setTextAlignment:NSTextAlignmentLeft];
    placeholderLable.text = title;
    placeholderLable.font = [UIFont systemFontOfSize:11];
    [leftView addSubview:placeholderLable];
    
    return  leftView;
}
- (UIView *)definViewTextTile:(NSString *)title{
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ktextHeigh, ktextHeigh)];
    UILabel *placeholderLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ktextHeigh, ktextHeigh)];
    placeholderLable.textColor =[UIColor whiteColor];
    [placeholderLable setTextAlignment:NSTextAlignmentLeft];
    placeholderLable.text = title;
    placeholderLable.font = [UIFont systemFontOfSize:12];
    [leftView addSubview:placeholderLable];
    
    return  leftView;
}
- (UIView *)definRigthView{
    UIView *rigthView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth - 100.f, 9, 32, 32)];
    
    UIButton *secureTextBtn = [[UIButton alloc]  initWithFrame:CGRectMake(kScreenWidth - 100.f, 9, 32, 32)];
    [secureTextBtn setImage:[UIImage imageNamed:@"browse"] forState:UIControlStateNormal];
    secureTextBtn.selected = NO;
    [secureTextBtn addTarget:self action:@selector(changeSecrect:) forControlEvents:UIControlEventTouchUpInside];
    [rigthView addSubview:secureTextBtn];
    self.rightViewMode = UITextFieldViewModeAlways;
    return rigthView;
}
- (void)changeSecrect:(UIButton *)sender{
    
}
@end
