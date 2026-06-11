//
//  HLShowComplaintPopView.m
//  hongdou
//
//  Created by user on 2022/8/9.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLShowComplaintPopView.h"

@interface HLShowComplaintPopView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UITextView *textView;

@end

@implementation HLShowComplaintPopView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self addSubview:self.headerView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.headerView.frame = CGRectMake(0, kScreenHeight-373, kScreenWidth, 373);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
    }
    return self;
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    
    NSDictionary *dic = [notification userInfo];
    
    NSValue *value = [dic objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    
    CGRect rect = [value CGRectValue];
    
    CGFloat keyBHeight = rect.size.height;
    
    self.headerView.top = self.headerView.top-keyBHeight;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.headerView]) {
        return NO;
    }
    return YES;
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight+373, kScreenWidth, 373)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        _headerView.layer.cornerRadius = 5;
        _headerView.layer.masksToBounds = YES;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-60, 15, 120, 40)];
        lab.text = @"投诉";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:19];
        lab.textColor = kRGBA(63, 70, 88, 1);
        [_headerView addSubview:lab];
        
        [_headerView addSubview:self.textView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.textView.frame)+20, kScreenWidth, 1)];
        lineView.backgroundColor = kRGBA(242, 242, 242, 1);
        [_headerView addSubview:lineView];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(15, CGRectGetMaxY(lineView.frame)+12, 168, 48);
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 24;
        btn.layer.masksToBounds = YES;
        
        btn.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        btn.layer.borderWidth = 1;
        [_headerView addSubview:btn];
        
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.backgroundColor = kRGBA(255, 89, 130, 1);
        [btn1 setTitle:@"确定" forState:UIControlStateNormal];
        btn1.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame)+8, CGRectGetMaxY(lineView.frame)+12, 168, 48);
        [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
        btn1.layer.cornerRadius = 24;
        btn1.layer.masksToBounds = YES;
        
        btn1.right = _headerView.right-15;
        
        btn1.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        btn1.layer.borderWidth = 1;
        [_headerView addSubview:btn1];
        
    }
    return _headerView;
}

// 取消
- (void)btnClick {
    [self removeSelf];
}

- (void)btn1Click {
    
    if (self.textView.text.length<1) {
        [kAppDelegate.window showTostWithMessage:@"请写明投诉理由!"];
        return;
    }
    
    [kAppDelegate.window showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.aid,
        @"txt":self.textView.text
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/activitycomplaint" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"--->: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window showTostWithMessage:@"提交成功"];
            [self removeSelf];
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
    
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 70, kScreenWidth-40, 200)];
        _textView.backgroundColor = kRGBA(247, 247, 247, 1);
        
        _textView.textColor = kRGBA(34, 34, 34, 1);
        _textView.font = kFontSize(14);
        
        _textView.layer.cornerRadius = 8;
        _textView.layer.masksToBounds = YES;
        
        _textView.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        _textView.layer.borderWidth = 1;
        
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = @"请写明投诉理由";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = kRGBA(153, 153, 153, 1);
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        placeHolderLabel.font = kFontSize(14);
        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        
    }
    return _textView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
