//
//  HLCenterView.m
//  婚恋网
//
//  Created by iMac on 2019/3/24.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLCenterView.h"

@implementation HLCenterView

- (void)awakeFromNib{
    [super awakeFromNib];
    [_phoneNumberTF textFileTitle:@"phone" leftWidth:14 heigth:21];
    [_verityTF textFileTitle:@"mima" leftWidth:14 heigth:21];
    [_passwordTF textFileTitle:@"mima" leftWidth:14 heigth:21];
    self.verityBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [_sureButton az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:153/255.0 green:95/255.0 blue:248/255.0 alpha:1.0],[UIColor colorWithRed:93/255.0 green:87/255.0 blue:237/255.0 alpha:1.0]] locations:@[@(0.0),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
}

+(instancetype)initWithXib:(CGRect)frame  delegate:(id<HLCenterViewDeleagte,UITextFieldDelegate>)delegate{
    HLCenterView *view = [[UINib nibWithNibName:NSStringFromClass([HLCenterView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    view.delegate = delegate;
    view.phoneNumberTF.delegate = delegate;
    view.passwordTF.delegate = delegate;
    [view awakeFromNib];
    return view;
}

- (IBAction)verityButtonClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(verityButtonClick)]) {
        [_delegate verityButtonClick];
    }
}

- (IBAction)sureButtonClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(sureButtonClick)]) {
        [_delegate sureButtonClick];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_passwordTF.isFirstResponder || _verityTF.isFirstResponder || _phoneNumberTF.isFirstResponder) {
        [_passwordTF resignFirstResponder];
        [_verityTF resignFirstResponder];
        [_phoneNumberTF resignFirstResponder];
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
