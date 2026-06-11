//
//  HLLoginView.m
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLLoginView.h"
#import <AuthenticationServices/AuthenticationServices.h>

static CGFloat const kleftBlank = 35.f;




@interface HLLoginView ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) YYLabel *registOrAlterSecret;
@property (nonatomic, strong) YYLabel *lineLab, *lineLab1, *lineLab2;
@property (nonatomic, strong) YYLabel *fogetAlterSecret, *oneKeySecret;
@property (nonatomic, strong) YYLabel *xinLiZiXunSecret;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *wechatLoginImge;
@property (nonatomic, strong) UIImageView *verityLoginBt;
@property (nonatomic, strong) UILabel *wechatLable, *appleLabel;
@property (nonatomic, strong) UILabel *qqLable;
@property (nonatomic, strong) UIButton *secureTextBtn;

@property (nonatomic, strong) UIView * leftLine;
@property (nonatomic, strong) UIView * rigthLine;

@property (nonatomic, strong) YYLabel *loginProtocol;


@end

@implementation HLLoginView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HLLoginViewDeleagte,UITextFieldDelegate>)delegate{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.delegate = delegate;
        self.backgroundColor  =  [UIColor clearColor];
        [self drawUIInit];
    }
    return self;
}

- (void)drawUIInit{
    __weak typeof(self) weakSelf = self;
    // 头部视图
//    _headerView = ({
//        _headerView  = [[UIView alloc] init];
//        //        _headerView.backgroundColor = [UIColor lightGrayColor];
//        [self addSubview:_headerView];
//        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(weakSelf.mas_top).offset(8);
//            make.left.equalTo(@(100));
//            make.right.equalTo(@(-100));
//        }];
//        _headerView;
//    });
    _iconView = ({
        _iconView = [[UIImageView alloc]  init];
        _iconView.image = [UIImage imageNamed:@"image_touxiang"];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.mas_top).offset(10);
            make.left.equalTo(weakSelf.mas_left).offset(150);
            make.right.equalTo(weakSelf.mas_right).offset(-150);
            make.height.equalTo(weakSelf.iconView.mas_width);
        }];
        _iconView;
    });
    _titleLabel = ({
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"红豆";
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHex:0x815CF4];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.iconView.mas_bottom).offset(5);
            make.centerX.equalTo(weakSelf.iconView.mas_centerX);
            make.height.mas_equalTo(20);
        }];
        _titleLabel;
    });
    
    // 中间登录视图
    _phoneTextField = ({
        _phoneTextField  =[[UITextField alloc] init];
        [_phoneTextField chgangePlaceholderColor:@"+86 请输入正确的手机号"];
        _phoneTextField.textColor = kTextLableColor;
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_phoneTextField addTarget:self action:@selector(phoneTextFiledChange:) forControlEvents:UIControlEventEditingChanged];;
        [_phoneTextField textFileTitle:@"phone" leftWidth:14 heigth:50];
        _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
        _phoneTextField.delegate = _delegate;
        [self addSubview:_phoneTextField];
        [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
            make.left.equalTo(weakSelf.mas_left).offset(kleftBlank);
            make.centerX.equalTo(weakSelf.mas_centerX);
            make.height.equalTo(@(50));
        }];
        _phoneTextField;
    });
    _secretTextField = ({
        _secretTextField  =[[UITextField alloc] init];
        [_secretTextField chgangePlaceholderColor:@"输入密码"];
        _secretTextField.secureTextEntry = YES;
        _secretTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _secretTextField.textColor = kTextLableColor;
        [_secretTextField textFileTitle:@"mima" leftWidth:17 heigth:50];
//        _secretTextField.clearButtonMode = UITextFieldViewModeAlways;
        [_secretTextField addTarget:self action:@selector(verifyTextFiledChange:) forControlEvents:UIControlEventEditingChanged];
        _secretTextField.delegate = _delegate;
        [self addSubview:_secretTextField];
        [_secretTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.mas_left).offset(kleftBlank);
            make.centerX.equalTo(weakSelf.mas_centerX);
            make.top.equalTo(weakSelf.phoneTextField.mas_bottom);
            make.height.equalTo(@(50));
            
        }];
        _secretTextField;
    });
    
    _secureTextBtn = ({
        _secureTextBtn =[[UIButton alloc]  init];
        [_secureTextBtn setImage:[UIImage imageNamed:@"icon_eyes_close"] forState:UIControlStateNormal];
        [_secureTextBtn setImage:[UIImage imageNamed:@"icon_eyes_open"] forState:UIControlStateSelected];
        [_secureTextBtn addTarget:self action:@selector(changeSecrect:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_secureTextBtn];
        [_secureTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakSelf.secretTextField.mas_centerY);
            make.right.equalTo(weakSelf.secretTextField.mas_right);
            make.size.mas_equalTo(CGSizeMake(22,20));
        }];
        _secureTextBtn;
    });
    _phoneNumLoginBt = ({
        _phoneNumLoginBt = [[UIButton alloc] init];
        [_phoneNumLoginBt setTitle:@"登录" forState:UIControlStateNormal];
        _phoneNumLoginBt.backgroundColor = [UIColor colorWithHex:0x815CF4];
        [self addSubview:_phoneNumLoginBt];
        [_phoneNumLoginBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.secretTextField.mas_left);
            make.right.equalTo(weakSelf.secretTextField.mas_right);
            make.centerX.equalTo(weakSelf.mas_centerX);
            make.top.equalTo(weakSelf.secretTextField.mas_bottom).offset(20.f);
            make.height.equalTo(@(40));
            
        }];
        [_phoneNumLoginBt az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        _phoneNumLoginBt.layer.cornerRadius = 20.f;
        _phoneNumLoginBt.layer.masksToBounds = YES;
        [_phoneNumLoginBt addTarget:self action:@selector(phoneLoginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _phoneNumLoginBt;
    });
    
    _registOrAlterSecret = ({
        _registOrAlterSecret = [[YYLabel alloc] init];
        NSMutableAttributedString *lawAlter = [[NSMutableAttributedString alloc] initWithString:@"注册帐号"];
        lawAlter.font = [UIFont systemFontOfSize:14];
        [lawAlter setTextHighlightRange:lawAlter.rangeOfAll color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [self registClick];
        }];
        _registOrAlterSecret.attributedText = lawAlter;
        [_registOrAlterSecret setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_registOrAlterSecret];
        [_registOrAlterSecret mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.mas_left).offset(kleftBlank);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(17.f);
            make.size.mas_equalTo(CGSizeMake(70.f, 18.f));
        }];
        _registOrAlterSecret;
    });
    
    _lineLab = ({ // 分隔线
        _lineLab = [[YYLabel alloc] init];
        _lineLab.backgroundColor = [UIColor colorWithHex:0x965FF8];
        [self addSubview:_lineLab];
        [_lineLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.registOrAlterSecret.mas_right);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(19.f);
            make.size.mas_equalTo(CGSizeMake(1.f, 14.f));
        }];
        _lineLab;
    });
    
    _fogetAlterSecret = ({
        _fogetAlterSecret = [[YYLabel alloc]  init];
        NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:@"忘记密码"];
        lawTitle.font = [UIFont systemFontOfSize:14];
        [lawTitle setTextHighlightRange:lawTitle.rangeOfAll color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [self modifyScerctClick];
        }];
        _fogetAlterSecret.attributedText = lawTitle;
        [_fogetAlterSecret setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_fogetAlterSecret];
        [_fogetAlterSecret mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.lineLab.mas_right);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(17.f);
            make.size.mas_equalTo(CGSizeMake(70.f, 18.f));
        }];
        _fogetAlterSecret;
    });
    
    _lineLab1 = ({ // 分隔线
        _lineLab1 = [[YYLabel alloc] init];
        _lineLab1.backgroundColor = [UIColor colorWithHex:0x965FF8];
        [self addSubview:_lineLab1];
        [_lineLab1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.fogetAlterSecret.mas_right);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(19.f);
            make.size.mas_equalTo(CGSizeMake(1.f, 14.f));
        }];
        _lineLab1;
    });
    // 一键登录
    _oneKeySecret = ({
        _oneKeySecret = [[YYLabel alloc]  init];
        NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:@"一键登录"];
        lawTitle.font = [UIFont systemFontOfSize:14];
        [lawTitle setTextHighlightRange:lawTitle.rangeOfAll color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            if ([self.delegate respondsToSelector:@selector(oneKeyLoginScerctClick)]) {
                [self.delegate oneKeyLoginScerctClick];
            }
            
        }];
        _oneKeySecret.attributedText = lawTitle;
        [_oneKeySecret setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_oneKeySecret];
        [_oneKeySecret mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.lineLab1.mas_right);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(17.f);
            make.size.mas_equalTo(CGSizeMake(70.f, 18.f));
        }];
        _oneKeySecret;
    });
    
    _lineLab2 = ({ // 分隔线
        _lineLab2 = [[YYLabel alloc] init];
        _lineLab2.backgroundColor = [UIColor colorWithHex:0x965FF8];
        [self addSubview:_lineLab2];
        [_lineLab2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.oneKeySecret.mas_right);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(19.f);
            make.size.mas_equalTo(CGSizeMake(1.f, 14.f));
        }];
        _lineLab2;
    });
    
    _xinLiZiXunSecret = ({ // 心理咨询
        _xinLiZiXunSecret = [[YYLabel alloc]  init];
//        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
//        NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc]initWithString:@"情感咨询师入口" attributes:attribtDic];
        
        NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:@"情感咨询师入口"];
        
        lawTitle.font = [UIFont systemFontOfSize:14];
        
        [lawTitle setTextHighlightRange:lawTitle.rangeOfAll color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [self xinLiZiXunClick];
        }];
        _xinLiZiXunSecret.attributedText = lawTitle;
//        [_xinLiZiXunSecret setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_xinLiZiXunSecret];
        [_xinLiZiXunSecret mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.mas_right).offset(-15);
            make.left.equalTo(weakSelf.lineLab2.mas_right).offset(7);
            make.top.equalTo(weakSelf.phoneNumLoginBt.mas_bottom).offset(17.f);
//            make.size.mas_equalTo(CGSizeMake(110.f, 18.f));
            make.height.mas_equalTo(18.f);
            
        }];
        _xinLiZiXunSecret;
    });
    
    
    
    // 下方视图
    _leftLine = ({
        _leftLine = [[UIView alloc] init];
        _leftLine.backgroundColor = [UIColor colorWithHex:0xcecece];
        [self addSubview:_leftLine];
        _leftLine;
    });
    _rigthLine = ({
        _rigthLine = [[UIView alloc] init];
        _rigthLine.backgroundColor = [UIColor colorWithHex:0xcecece];
        [self addSubview:_rigthLine];
        _rigthLine;
    });
    _messageLabel = ({
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = @"快捷登录";
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = kTextLableColor;
        [_messageLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_messageLabel];
        _messageLabel;
    });
    _verityLoginBt = ({
        _verityLoginBt = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qq"]];
        _verityLoginBt.contentMode = UIViewContentModeScaleAspectFit;
        _verityLoginBt.userInteractionEnabled = YES;
        [_verityLoginBt addGestureRecognizer:[[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(verityLoginButtonClick)]];
        [self addSubview:_verityLoginBt];
        _verityLoginBt;
    });
    _qqLable =({
        _qqLable = [[UILabel alloc] init];
        _qqLable.textAlignment = NSTextAlignmentCenter;
        _qqLable.textColor = [UIColor colorWithHex:0x3F4658];
        _qqLable.font = [UIFont systemFontOfSize:12];
        _qqLable.text = @"QQ登录";
//        _qqLable.hidden = YES;
        [self addSubview:_qqLable];
        _qqLable;
    });
    _wechatLoginImge = ({
        _wechatLoginImge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wechat"]];
        _wechatLoginImge.contentMode = UIViewContentModeScaleAspectFit;
        _wechatLoginImge.userInteractionEnabled = YES;
        [_wechatLoginImge addGestureRecognizer:[[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(wechatLoginButtonClick)]];
        [self addSubview:_wechatLoginImge];
        
        _wechatLoginImge;
    });
    _wechatLable =({
        _wechatLable = [[UILabel alloc] init];
        _wechatLable.textAlignment = NSTextAlignmentCenter;
        _wechatLable.textColor = [UIColor colorWithHex:0x3F4658];
        _wechatLable.font = [UIFont systemFontOfSize:12];
        _wechatLable.text = @"微信登录";
//        _wechatLable.hidden = YES;
        [self addSubview:_wechatLable];
        _wechatLable;
    });
    
    if (@available(iOS 13.0, *)) {

        ASAuthorizationAppleIDButton *signInButton = [ASAuthorizationAppleIDButton buttonWithType:ASAuthorizationAppleIDButtonTypeSignIn style:ASAuthorizationAppleIDButtonStyleWhiteOutline];
        [signInButton addTarget:self action:@selector(signInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signInButton];
        
        [signInButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.equalTo(weakSelf.wechatLable.mas_bottom).offset(20);
            make.height.mas_equalTo(38);
            make.width.mas_equalTo(200);
        }];
        
        _appleLabel = [[UILabel alloc] init];
        _appleLabel.textAlignment = NSTextAlignmentCenter;
        _appleLabel.textColor = [UIColor darkGrayColor];
        _appleLabel.font = [UIFont systemFontOfSize:12];
        _appleLabel.text = @"苹果登录";
        _appleLabel.hidden = YES;
        [self addSubview:_appleLabel];
        
        [self.appleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.wechatLoginImge.mas_bottom).offset(12);
            make.centerX.equalTo(signInButton.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth/3, 12.f));
        }];
        
    }
    
    _loginProtocol = ({
        _loginProtocol = [[YYLabel alloc]  init];
        
        NSString *mianZe = @"免责声明";
        NSString *yinSi = @"隐私政策";
        
        NSString *context = [NSString stringWithFormat:@"登录即同意红豆佳缘 %@ 和 %@",yinSi,mianZe];
        
        NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:context];
        lawTitle.font = [UIFont systemFontOfSize:14];
        
        [lawTitle setTextHighlightRange:[context rangeOfString:mianZe] color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            if ([weakSelf.delegate respondsToSelector:@selector(statementClickWithTag:)]) {
                [weakSelf.delegate statementClickWithTag:mianZe];
            }
            
        }];
        
        [lawTitle setTextHighlightRange:[context rangeOfString:yinSi] color:[UIColor colorWithHex:0x965FF8] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            if ([weakSelf.delegate respondsToSelector:@selector(statementClickWithTag:)]) {
                [weakSelf.delegate statementClickWithTag:yinSi];
            }
            
        }];
        
        
        _loginProtocol.attributedText = lawTitle;
        [_loginProtocol setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_loginProtocol];
        [_loginProtocol mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.mas_left);
            make.right.equalTo(weakSelf.mas_right);
            make.bottom.equalTo(weakSelf.mas_bottom).offset(-20);
            make.height.mas_equalTo(@(18.f));
            make.width.mas_offset(weakSelf.width);
        }];
        _loginProtocol;
    });
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    __weak typeof(self) weakSelf = self;
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.bottom.equalTo(weakSelf.fogetAlterSecret.mas_bottom).offset(50);
        make.size.mas_equalTo(CGSizeMake(80, 16.f));
    }];
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.messageLabel.mas_centerY);
        make.right.equalTo(weakSelf.messageLabel.mas_left).offset(0);
        make.left.equalTo(weakSelf.mas_left).offset(kleftBlank);
        make.height.mas_equalTo(0.8);
        
    }];
    [self.rigthLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.messageLabel.mas_centerY);
        make.left.equalTo(weakSelf.messageLabel.mas_right).offset(0);
        make.right.equalTo(weakSelf.mas_right).offset(-kleftBlank);
        make.height.mas_equalTo(0.8);
        
    }];
    [self.verityLoginBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.messageLabel.mas_bottom).offset(20);
        make.right.equalTo(weakSelf.mas_centerX).offset(-kScreenWidth/8 + 20.5);
        make.size.mas_equalTo(CGSizeMake(38.f, 38.f));
    }];
    [self.qqLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.verityLoginBt.mas_bottom).offset(12);
        make.centerX.equalTo(weakSelf.verityLoginBt.mas_centerX);
        make.height.mas_equalTo(12);
    }];
    [self.wechatLoginImge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.verityLoginBt.mas_centerY);
        make.right.equalTo(weakSelf.mas_centerX).offset(kScreenWidth/8 + 20.5);
        make.size.mas_equalTo(CGSizeMake(38.f,38.f));
    }];
    [self.wechatLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.wechatLoginImge.mas_bottom).offset(12);
        make.centerX.equalTo(weakSelf.wechatLoginImge.mas_centerX);
        make.height.mas_equalTo(12);
    }];
    
}

#pragma mark delegate clickAction
- (void)phoneLoginButtonClick:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(phoneLoginButtonClick:)]) {
        [_delegate phoneLoginButtonClick:sender];
    }
}
- (void)verityLoginButtonClick{
    if ([_delegate respondsToSelector:@selector(verityLoginButtonClick)]) {
        [_delegate verityLoginButtonClick];
    }
}
- (void)wechatLoginButtonClick{
    if ([_delegate respondsToSelector:@selector(wechatLoginButtonClick)]) {
        [_delegate wechatLoginButtonClick];
    }
}
- (void)registClick{
    if ([_delegate respondsToSelector:@selector(registClick)]) {
        [_delegate registClick];
    }
}
- (void)modifyScerctClick{
    if ([_delegate respondsToSelector:@selector(modifyScerctClick)]) {
        [_delegate modifyScerctClick];
    }
}

- (void)xinLiZiXunClick {
    if ([_delegate respondsToSelector:@selector(xinLiZiXunClick)]) {
        [_delegate xinLiZiXunClick];
    }
}

- (void)phoneTextFiledChange:(UITextField *)textfield{
    if ([_delegate respondsToSelector:@selector(phoneTextFiledChange:)]) {
        [_delegate phoneTextFiledChange:textfield];
    }
}
- (void)verifyTextFiledChange:(UITextField *)textfield{
    if ([_delegate respondsToSelector:@selector(verifyTextFiledChange:)]) {
        [_delegate verifyTextFiledChange:textfield];
    }
}
- (void)changeSecrect:(UIButton *)sender{
    [_secretTextField becomeFirstResponder];
    sender.selected = !sender.selected;
    NSString *text = _secretTextField.text;
    _secretTextField.text = nil;
    _secretTextField.secureTextEntry = !_secretTextField.secureTextEntry;
    _secretTextField.text = text;
    if (_secretTextField.secureTextEntry) {
        _secretTextField.text = text;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_phoneTextField.isFirstResponder || _secretTextField.isFirstResponder) {
        [_phoneTextField resignFirstResponder];
        [_secretTextField resignFirstResponder];
    }
}

// 苹果账号登录触发方法
- (void)signInButtonClicked:(ASAuthorizationAppleIDButton *)signInButton  API_AVAILABLE(ios(13.0)) {
    
    //基于用户的Apple ID授权用户，生成用户授权请求的一种机制
    ASAuthorizationAppleIDProvider *provide = [[ASAuthorizationAppleIDProvider alloc] init];
    //创建新的AppleID 授权请求
    ASAuthorizationAppleIDRequest *request = provide.createRequest;
    //在用户授权期间请求的联系信息
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    //由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
    ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    //设置授权控制器通知授权请求的成功与失败的代理
    controller.delegate = self;
    //设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
    controller.presentationContextProvider = self;
    //在控制器初始化期间启动授权流
    [controller performRequests];
}

#pragma mark - ASAuthorizationControllerDelegate
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0))
{
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
    }
    NSLog(@"%@", errorMsg);
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0))
{
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        ASAuthorizationAppleIDCredential *credential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        
        NSString *state = credential.state;
        NSString *userID = credential.user;
        NSPersonNameComponents *fullName = credential.fullName;
        NSString *email = credential.email;
        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding]; // refresh token
        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding]; // access token
        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
        
//        NSLog(@"->state: %@", state);
//        NSLog(@"->userID: %@", userID);
//        NSLog(@"->fullName: %@", fullName);
//        NSLog(@"->email: %@", email);
//        NSLog(@"->authorizationCode: %@", authorizationCode);
//        NSLog(@"->identityToken: %@", identityToken);
//        NSLog(@"->realUserStatus: %@", @(realUserStatus));
        
        if ([_delegate respondsToSelector:@selector(appleDidLoginWithIdentityToken:UserId:)]) {
            [_delegate appleDidLoginWithIdentityToken:identityToken UserId:userID];
        }
    }
}

#pragma mark - ASAuthorizationControllerPresentationContextProviding
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    // 返回一个 window，present 登录界面需要用到
    return [UIApplication sharedApplication].delegate.window;
}

#pragma mark AppleIDLogin end

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
