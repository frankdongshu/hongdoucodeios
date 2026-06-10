//
//  HLLoginView.h
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLLoginViewDeleagte <NSObject>

- (void)phoneLoginButtonClick:(UIButton *)sender; //登录按钮事件
- (void)verityLoginButtonClick; // QQ验证码
- (void)wechatLoginButtonClick; // 微信登录
- (void)registClick;  // 注册
- (void)modifyScerctClick;  // 重置密码
- (void)xinLiZiXunClick;  // 心理咨询
- (void)statementClickWithTag:(NSString *)tagString;  // 协议
- (void)appleDidLoginWithIdentityToken:(NSString *)identityToken UserId:(NSString *)userid; // Apple账号登录



- (void)phoneTextFiledChange:(UITextField *)textfield;
- (void)verifyTextFiledChange:(UITextField *)textfield;



@end

NS_ASSUME_NONNULL_BEGIN

@interface HLLoginView : UIView

@property (nonatomic,assign) id <HLLoginViewDeleagte,UITextFieldDelegate>delegate;

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *secretTextField;
@property (nonatomic, strong) UIButton *phoneNumLoginBt;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <HLLoginViewDeleagte,UITextFieldDelegate> )delegate;

@end

NS_ASSUME_NONNULL_END
