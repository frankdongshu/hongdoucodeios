//
//  HLShoppingInfoView.m
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLShoppingInfoView.h"

@interface HLShoppingInfoView ()<UITextFieldDelegate>

/**
 背景
 */
@property (nonatomic, strong) UIView *backgroundView;
/**
 容器
 */
@property (strong, nonatomic) UIView *contentView;
/**
 标题
 */
@property (nonatomic, strong) UILabel *titleLabel;
/**
 输入框
 */
@property (nonatomic, strong) UITextField *nameTF, *phoneTF, *addTF;
/**
 取消按钮
 */
@property (nonatomic, strong) UIButton *cancelBtn;
/**
 确认按钮
 */
@property (nonatomic, strong) UIButton *sureBtn;

@end

@implementation HLShoppingInfoView

- (instancetype)initWithParamDic:(void (^)(NSDictionary * _Nonnull))dic {

    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        
        self.textFieldTextBlock = dic;
        
        [self setUI];
    }
    return self;
}

- (void)setUI{
    
    self.backgroundColor = kRGBA(49, 49, 50, 0.5);
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(34, kScreenHeight/2-150, kScreenWidth-68, 300)];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.cornerRadius = 6;
    [self addSubview:self.backgroundView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.backgroundView.frame.size.width-20, 20)];
    lab.text = @"请填写您的收货信息";
    lab.font = kScaleFont(16);
    lab.textColor = kRGBA(63, 70, 87, 1);
    [self.backgroundView addSubview:lab];
    
    self.nameTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lab.frame)+30, self.backgroundView.frame.size.width-20, 45)];
    self.nameTF.delegate = self;
//    self.nameTF.tag = 200;
//    nameTF.backgroundColor = [UIColor greenColor];
    self.nameTF.attributedPlaceholder = [self createPlaceholderWithString:@"请输入收货人姓名"];
    self.nameTF.leftView = [self createLeftViewWithTitle:@"收  货  人"];
    self.nameTF.leftViewMode = UITextFieldViewModeAlways;
    self.nameTF.font = kScaleFont(13);
    self.nameTF.textColor = [UIColor darkGrayColor];
    [self.backgroundView addSubview:self.nameTF];
    
    [self.backgroundView addSubview:[self createLineWithFrame:CGRectMake(10, CGRectGetMaxY(self.nameTF.frame), self.backgroundView.frame.size.width-20, 0.3)]];
    
    
    self.phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.nameTF.frame)+0.3, self.backgroundView.frame.size.width-20, 45)];
    self.phoneTF.delegate = self;
    self.phoneTF.tag = 201;
    self.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTF.attributedPlaceholder = [self createPlaceholderWithString:@"请输入收货人电话号码"];
//    phoneTF.backgroundColor = [UIColor orangeColor];
    self.phoneTF.leftView = [self createLeftViewWithTitle:@"电话号码"];
    self.phoneTF.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTF.font = kScaleFont(13);
    self.phoneTF.textColor = [UIColor darkGrayColor];
    [self.backgroundView addSubview:self.phoneTF];
    
    [self.backgroundView addSubview:[self createLineWithFrame:CGRectMake(10, CGRectGetMaxY(self.phoneTF.frame)+0.3, self.backgroundView.frame.size.width-20, 0.3)]];
    
    
    
    self.addTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.phoneTF.frame)+0.3, self.backgroundView.frame.size.width-20, 45)];
    self.addTF.delegate = self;
//    self.addTF.tag = 202;
//    addTF.backgroundColor = [UIColor redColor];
    self.addTF.attributedPlaceholder = [self createPlaceholderWithString:@"请输入街道门牌等信息"];
    self.addTF.leftView = [self createLeftViewWithTitle:@"详细地址"];
    self.addTF.leftViewMode = UITextFieldViewModeAlways;
    self.addTF.font = kScaleFont(13);
    self.addTF.textColor = [UIColor darkGrayColor];
    [self.backgroundView addSubview:self.addTF];
    
    [self.backgroundView addSubview:[self createLineWithFrame:CGRectMake(10, CGRectGetMaxY(self.addTF.frame), self.backgroundView.frame.size.width-20, 0.3)]];
    
    UILabel *messageLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.addTF.frame)+0.3, self.backgroundView.frame.size.width-20, 20)];
    messageLab.text = @"配送地区不包括偏远地区(新疆、西藏等), 请慎重填写";
    messageLab.font = kScaleFont(10);
    messageLab.textColor = [UIColor redColor];
    
    [self.backgroundView addSubview:messageLab];
    
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.backgroundColor = kRGBA(230, 230, 230, 1);
    self.cancelBtn.frame = CGRectMake(10, self.backgroundView.frame.size.height-52, (self.backgroundView.frame.size.width-20)/2, 40);
    [self.cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backgroundView addSubview:self.cancelBtn];
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.sureBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995FF8],[UIColor colorWithHex:0x5D57ED]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    self.sureBtn.backgroundColor = kRGBA(230, 230, 230, 1);
    self.sureBtn.frame = CGRectMake(CGRectGetMaxX(self.cancelBtn.frame), self.backgroundView.frame.size.height-52, (self.backgroundView.frame.size.width-20)/2, 40);
    [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(onClickSureBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backgroundView addSubview:self.sureBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark 点击确定按钮
-(void)onClickSureBtn:(UIButton *)sender{
    
    if (kISNullString(self.nameTF.text) && kISNullString(self.phoneTF.text) && kISNullString(self.addTF.text)) {
        [self showTostWithMessage:@"请填写您的收货信息!"];
    }
    else if (![self.phoneTF.text isMobileNumber]) {
        [self showTostWithMessage:@"请填写正确手机号!"];
    }
    else {
        NSDictionary *dic = @{
            @"name":self.nameTF.text,
            @"phone":self.phoneTF.text,
            @"add":self.addTF.text
        };
        
        self.textFieldTextBlock(dic);
        
        [self hide];
    }
    
    
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
//    NSDictionary *userInfo = [notification userInfo];
//    NSValue *value = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGRect keyboardRect = [value CGRectValue];
//    int height = keyboardRect.size.height;
//
//    NSLog(@"键盘高度: %d",height);
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.frame = CGRectMake(34, kScreenHeight/2-250, kScreenWidth-68, 300);
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.frame = CGRectMake(34, kScreenHeight/2-150, kScreenWidth-68, 300);
    }];
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 201) { // 限制手机输入字数
        return current.length <= 11;
    }
    
    return YES;
    
}


- (NSMutableAttributedString *)createPlaceholderWithString:(NSString *)holderText {
    
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
//    [placeholder addAttribute:NSForegroundColorAttributeName
//                            value:[UIColor greenColor]
//                            range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                            value:kScaleFont(13)
                            range:NSMakeRange(0, holderText.length)];
     
    return placeholder;
}

- (UIView *)createLineWithFrame:(CGRect)frame {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = kRGBA(230, 230, 230, 1);
    
    return view;
}


- (UILabel*)createLeftViewWithTitle:(NSString *)title {
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    
    lab.text = [NSString stringWithFormat:@"%@    ",title];
    lab.font = kScaleFont(13);
    lab.textColor = [UIColor darkGrayColor];
    
    return lab;
    
}

-(void)hideKeyboard{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.frame = CGRectMake(34, kScreenHeight/2-150, kScreenWidth-68, 300);
    }];
    
    [self.nameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.addTF resignFirstResponder];
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [window addSubview:self];
    
}

- (void)hide {
    
    [self.nameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.addTF resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
