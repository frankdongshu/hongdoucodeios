//
//  HLDreamLoverDesView.m
//  hongdou
//
//  Created by 李龙 on 2020/7/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLDreamLoverDesView.h"
#import <WebKit/WebKit.h>

@implementation HLDreamLoverDesView

- (instancetype)initWithFrame:(CGRect)frame andMessage:(NSString *)message {
    if ([super initWithFrame:frame]) {
        
        
        YYLabel *loginProtocol = [[YYLabel alloc] init];
        loginProtocol.backgroundColor = [UIColor whiteColor];
        loginProtocol.layer.masksToBounds = YES;
        loginProtocol.layer.cornerRadius = 5;
        
        loginProtocol.textVerticalAlignment = 0;
        loginProtocol.numberOfLines = 0;
        loginProtocol.preferredMaxLayoutWidth = kScreenWidth-100;
        
        loginProtocol.textContainerInset = UIEdgeInsetsMake(40, 15, 30, 15);
        
        NSMutableAttributedString *attString = [self attributeStringByHtmlString:message];
        
        attString.font = [UIFont systemFontOfSize:14];
        attString.lineSpacing = 8;
        attString.color = [UIColor darkGrayColor];
        
        // 点击
        [attString setTextHighlightRange:[attString.string rangeOfString:@"现在开通"] color:[UIColor systemTealColor] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            self.SelectBlock();
            
            [self removeFromSuperview];
            
        }];
        
        loginProtocol.attributedText = attString;
        
        [self addSubview:loginProtocol];
        
        
        [loginProtocol mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.left.mas_equalTo(50);
            make.right.mas_equalTo(-50);
        }];
        
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"home_cha"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];

        [loginProtocol addSubview:closeBtn];
        
        
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(loginProtocol.mas_top);
            make.right.equalTo(loginProtocol.mas_right);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        
    }
    return self;
}

/** 超文本HTML格式转换为富文本AtrributeString格式*/
- (NSMutableAttributedString *)attributeStringByHtmlString:(NSString *)htmlString {
    NSMutableAttributedString *attributeString;
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]
                                   };
    NSError *error = nil;
    attributeString = [[NSMutableAttributedString alloc] initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    return attributeString;
}

- (void)showSelf {
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

- (void)removeSelf {
    
    self.CloseBlock();
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
