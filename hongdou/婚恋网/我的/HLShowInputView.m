//
//  HLShowInputView.m
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLShowInputView.h"

// 限制输入字母和数字
#define NUM @"0123456789"
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface HLShowInputView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *backGroudView;

@property (nonatomic, strong) UITextField *codeTextField;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation HLShowInputView

//快速创建
+ (instancetype)popInputView{
    return [[self alloc] init];
}
-(instancetype)initWithFrame:(CGRect)frame
{
    // YLSRect(0, 0, 1, 917/667)
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self initWithView];
    }
    return self;
}
- (void)initWithView{
    _backGroudView  = ({
        _backGroudView= [[UIView alloc] init];
        
        _backGroudView.backgroundColor = [UIColor whiteColor];
        
        _backGroudView.layer.cornerRadius = 7.f;
        _backGroudView.layer.masksToBounds = YES;
        [self addSubview:_backGroudView];
        [_backGroudView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(35);
            make.center.equalTo(self);
            make.height.mas_equalTo(200);
        }];
        _backGroudView;

    });
    
    
    _codeTextField = ({
        _codeTextField  =[[UITextField alloc] init];
        _codeTextField.delegate = self;
        _codeTextField.textColor = kTextLableColor;
        _codeTextField.placeholder = @" 请输入对方的ID";
        _codeTextField.backgroundColor = [UIColor colorWithHex:0xDDDFE4];
        _codeTextField.keyboardType = UIKeyboardTypeASCIICapable; // 限制输入字母和数字
        _codeTextField.layer.cornerRadius = 7.f;
        _codeTextField.layer.masksToBounds = YES;
         [self.backGroudView addSubview:_codeTextField];
        [_codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.backGroudView.mas_top).offset(33);
            make.left.equalTo(self.backGroudView.mas_left).offset(35);
            make.centerX.equalTo(self.backGroudView.mas_centerX);
            make.height.mas_equalTo(40);
        }];
        _codeTextField;
    });
    
    _messageLabel = ({
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = @"提交后不能更改";
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor colorWithHex:0x5B76FF];
        _messageLabel.font = [UIFont systemFontOfSize:14.f];
        [self.backGroudView addSubview:_messageLabel];
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.codeTextField.mas_bottom).offset(20);
            make.left.equalTo(self.backGroudView.mas_left).offset(35);
            make.centerX.equalTo(self.backGroudView.mas_centerX);
            make.height.mas_equalTo(20);
        }];
        _messageLabel;
    });
    _submitBtn = ({
        _submitBtn = [[UIButton alloc] init];
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        _submitBtn.tintColor = [UIColor whiteColor];
        [_submitBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [_submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.layer.cornerRadius = 20.f;
        _submitBtn.layer.masksToBounds = YES;
        [self.backGroudView addSubview:_submitBtn];
        [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageLabel.mas_bottom).offset(30);
            make.left.equalTo(self.backGroudView.mas_left).offset(45);
            make.centerX.equalTo(self.backGroudView.mas_centerX);
            make.height.mas_equalTo(40);
        }];
        _submitBtn;
    });
}

// 限制输入字母和数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
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

- (void)submitClick{
    if (self.submissBlock) {
        if (self.codeTextField.text.length>0) {
            [self cancleClick];
            self.submissBlock(self.codeTextField.text);
        }else{
            [[UIApplication sharedApplication].keyWindow showTostWithMessage:@"请输入对方ID"];
        }
        
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_codeTextField.isFirstResponder) {
        [_codeTextField resignFirstResponder];
    }
    // 点击的位置

    CGPoint point = [[touches anyObject] locationInView:self];
   
    
    CGRect rect = [self convertRect:self.backGroudView.frame fromView:self];
    // 判断点击点是否在backGroudView内
    if (!CGRectContainsPoint(rect, point)) {
        [self cancleClick];
    }
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
