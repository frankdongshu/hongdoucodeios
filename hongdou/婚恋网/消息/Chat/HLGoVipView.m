//
//  HLGoVipView.m
//  hongdou
//
//  Created by user on 2022/4/15.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLGoVipView.h"

@interface HLGoVipView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) NSString *url;

@end

@implementation HLGoVipView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self addSubview:self.headerView];
        
        [UIView animateWithDuration:0.3 animations:^{

            self.headerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        }];
        
        [self requestData];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
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
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight-280)];
        [_headerView addSubview:self.imgView];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth/2-60, CGRectGetMaxY(self.imgView.frame)+20, 120, 40);
        btn.backgroundColor = [UIColor systemBlueColor];
        
        [btn setTitle:@"点击购买" forState:UIControlStateNormal];
        
        btn.layer.cornerRadius = 20;
        btn.layer.masksToBounds = YES;
        
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];

        [_headerView addSubview:btn];
        
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(kScreenWidth/2-60, CGRectGetMaxY(btn.frame)+15, 120, 40);
        
        [btn1 setTitle:@"以后再说" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        btn1.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [btn1 addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];

        [_headerView addSubview:btn1];

        
        
    }
    return _headerView;
}

- (void)btnClick {
    
    [self removeSelf];
    
    self.SelectBlock();
}

- (void)extracted:(NSDictionary * _Nonnull)dictionary {
    [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
}

- (void)requestData {
    
    NSDictionary *dic = @{
        @"sign":@"iosnovipIMto"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"index/greet_list: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"val"]]];
                
        } else {
            [self extracted:dictionary];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
