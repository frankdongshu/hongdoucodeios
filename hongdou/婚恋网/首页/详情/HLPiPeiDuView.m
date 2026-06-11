//
//  HLPiPeiDuView.m
//  hongdou
//
//  Created by 李龙 on 2020/6/23.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLPiPeiDuView.h"
#import "LLCustomButton.h"

@interface HLPiPeiDuView () {
    NSString *_aid;
}

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *todayLab;

@property (nonatomic, strong) LLCustomButton *btn;
@property (nonatomic, strong) LLCustomButton *btn1;

@property (nonatomic, strong) UIButton *huanBtn;
@property (nonatomic, strong) UIButton *noBtn;

@end

@implementation HLPiPeiDuView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(25, kScreenHeight/2-130, kScreenWidth-50, 230)];
        view.backgroundColor = [UIColor whiteColor];
        
        view.layer.cornerRadius = 8;
        view.layer.masksToBounds= YES;
        
        [self addSubview:view];
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"da_bg"]];
        
        imgView.frame = CGRectMake(0, -2, view.frame.size.width, 46);
        
        [view addSubview:imgView];
        
        self.todayLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width-20, 46)];
        self.todayLab.font = [UIFont systemFontOfSize:14];
        self.todayLab.textAlignment = NSTextAlignmentCenter;
        self.todayLab.textColor = [UIColor darkTextColor];
        
        [imgView addSubview:self.todayLab];
        
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(imgView.frame)+10, view.frame.size.width-16, 60)];
        
        self.titleLab.text = @"加载题目中...";
        self.titleLab.font = [UIFont systemFontOfSize:15];
        self.titleLab.numberOfLines = 0;
        
        [view addSubview:self.titleLab];
        
        self.btn = [LLCustomButton buttonWithType:UIButtonTypeCustom];
        
        [self.btn setTitle:@"是" forState:UIControlStateNormal];
        [self.btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btn setImage:[UIImage imageNamed:@"zhengque"] forState:UIControlStateSelected];
        self.btn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.btn.frame = CGRectMake(15, CGRectGetMaxY(self.titleLab.frame)+10, 70, 30);
        
        self.btn.imgViewPointX = 5;
        self.btn.titlePointX = 0;
        
        [self.btn addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:self.btn];
        
        
        self.btn1 = [LLCustomButton buttonWithType:UIButtonTypeCustom];
        
        [self.btn1 setTitle:@"否" forState:UIControlStateNormal];
        [self.btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btn1 setImage:[UIImage imageNamed:@"zhengque"] forState:UIControlStateSelected];
        self.btn1.titleLabel.font = [UIFont systemFontOfSize:15];
        self.btn1.frame = CGRectMake(CGRectGetMaxX(self.btn.frame)+15, CGRectGetMaxY(self.titleLab.frame)+10, 70, 30);
        
        self.btn1.imgViewPointX = 5;
        self.btn1.titlePointX = 0;
        
        [self.btn1 addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:self.btn1];
        
        
        
        self.huanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.huanBtn setTitle:@"换一题" forState:UIControlStateNormal];
        [self.huanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.huanBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.huanBtn.frame = CGRectMake(CGRectGetMaxX(self.btn1.frame)+15, CGRectGetMaxY(self.titleLab.frame)+10, 70, 30);
        [self.huanBtn addTarget:self action:@selector(huanClick) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:self.huanBtn];
        
        
        self.noBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.noBtn setTitle:@"今天不答了" forState:UIControlStateNormal];
        [self.noBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.noBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        self.noBtn.frame = CGRectMake(view.frame.size.width-120, view.frame.size.height-50, 100, 30);
        [self.noBtn addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:self.noBtn];
        
        
        [self requestQuestion];
        
        [self getCount];
    }
    return self;
}

- (void)likeClick:(UIButton *)sender {
    
    if ([self.titleLab.text isEqualToString:@"加载题目中..."]) {
        return;
    }
    
    sender.selected = !sender.selected;
    
    [self selectQuestionWithSid:[NSString stringWithFormat:@"%ld",sender.tag] andAid:_aid];
    
}

// 换一题
- (void)huanClick {
    [self requestQuestion];
}

// 不答了
- (void)buClick {
    
    [self getCount];
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

// 获取问题
- (void)requestQuestion {
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/subject/get_subject" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            self->_aid = dictionary[@"data"][@"id"];
            
            self.titleLab.text = dictionary[@"data"][@"subject"];
            [self.btn setTitle:dictionary[@"data"][@"answer"][0][@"answer"] forState:UIControlStateNormal];
            [self.btn1 setTitle:dictionary[@"data"][@"answer"][1][@"answer"] forState:UIControlStateNormal];
            
            self.btn.tag = [dictionary[@"data"][@"answer"][0][@"id"] integerValue];
            self.btn1.tag = [dictionary[@"data"][@"answer"][1][@"id"] integerValue];
            
        } else if ([code isEqualToString:@"202"]) {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            
            // 没题直接退出
            [self removeSelf];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 答题
- (void)selectQuestionWithSid:(NSString *)sid andAid:(NSString *)aid {
    
    
    
    
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":sid,
        @"aid":aid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/subject/answer" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [MBProgressHUD hideLoading];
            
            [self.btn setSelected:NO];
            [self.btn1 setSelected:NO];
            
            [self getCount];
            [self requestQuestion];
            
        } else {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            
            [self.btn setSelected:NO];
            [self.btn1 setSelected:NO];
            
            [self requestQuestion];
            
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 答题统计
- (void)getCount {
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/subject/get_count" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.todayLab.text = [NSString stringWithFormat:@"今天已答%@道",dictionary[@"data"][@"today"]];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 今天不答了
- (void)buDaLeToday {
    
    if ([[self.todayLab.text substringWithRange:NSMakeRange(4, self.todayLab.text.length-5)] intValue] >= 3) {
        [self removeSelf];
    } else {

        if (![LoginManager defaultManager].isVip) {
            [MBProgressHUD showMessage:@"您不是Vip, 至少答3题!" view:self];
        } else {
            [self removeSelf];
        }
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
