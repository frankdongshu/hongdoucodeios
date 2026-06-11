//
//  HXWelcomeView.m
//  hongdou
//
//  Created by 维康1 on 2021/6/16.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HXWelcomeView.h"

@interface HXWelcomeView ()<UIGestureRecognizerDelegate> {
    UIView *_view;
    UIImageView *_imgView;
}

@property (nonatomic, strong) NSString *signString; // 跳转标识

@end

@implementation HXWelcomeView

- (NSString *)signString {
    if (!_signString) {
        _signString = [[NSString alloc] init];
    }
    return _signString;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self->_view = [[UIView alloc] init];
        self->_view.frame = CGRectMake(kScreenWidth/2, kScreenHeight/2-30, 0, 0);
        self->_view.backgroundColor = [UIColor clearColor];
        self->_view.layer.masksToBounds = YES;
        self->_view.layer.cornerRadius = 8;
        
        [self addSubview:self->_view];
        
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isDescendantOfView:self->_view]) {
        
        // 跳转页面
        [self requestDidImgUrl];
        
        return NO;
    }
    
    return YES;
}

- (void)showSelf {
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    
    [UIView animateWithDuration:.2 animations:^{
        self->_view.frame = CGRectMake(50, kScreenHeight/2-180, kScreenWidth-100, 310);
    } completion:^(BOOL finished) {
        
        self->_imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self->_view.frame.size.width, 310)];
        
        [self->_view addSubview:self->_imgView];
        
        [self requestImgUrl];
        
    }];
    
    [windew addSubview:self];
}

// 获取图片
- (void)requestImgUrl {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/get_huodong" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"get_huodong: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            
            
            if (kISNullObject(dictionary[@"data"][@"pic"])) {
                [self removeSelf];
            } else {
                
                [self->_imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"pic"]]];
                
                self.signString = dictionary[@"data"][@"sign"];
            }
            
        } else {
            [self showError:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [self removeSelf];
        
        [self showError:error.localizedDescription];
    }];
    
}

// 点击了图片
- (void)requestDidImgUrl {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self showLoadMessageAtCenter];
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/see_huodong" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/see_huodong: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self hide];
            
            self.SelectBlock(self.signString);
            
            [self removeSelf];
            
            
        } else {
            [self showError:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self showError:error.localizedDescription];
    }];
    
}

- (void)removeSelf {
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
