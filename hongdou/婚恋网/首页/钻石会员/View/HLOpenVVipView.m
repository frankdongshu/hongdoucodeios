//
//  HLOpenVVipView.m
//  hongdou
//
//  Created by 维康1 on 2020/8/20.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLOpenVVipView.h"
#import "HLDreamLoverDesView.h"

@interface HLOpenVVipView ()

@property (weak, nonatomic) IBOutlet UIButton *phoneAuthBtn;
@property (weak, nonatomic) IBOutlet UIButton *headAuthBtn;
@property (weak, nonatomic) IBOutlet UIButton *cardAuthBtn;
@property (weak, nonatomic) IBOutlet UIButton *xueLiAuthBtn;
@property (weak, nonatomic) IBOutlet UIButton *shenHeBtn;

@end

@implementation HLOpenVVipView

// 认证状态数据
- (void)setAuthDic:(NSDictionary *)authDic {
    _authDic = authDic;
    
    // 手机实名认证
    if ([[authDic[@"sjsmrz"] stringValue] isEqualToString:@"1"]) {
        [self.phoneAuthBtn setTitle:@"已认证" forState:UIControlStateNormal];
        [self.phoneAuthBtn setTitleColor:kRGBA(187, 143, 73, 1) forState:UIControlStateNormal];
        self.phoneAuthBtn.backgroundColor = kRGBA(241, 224, 196, 1);
        self.phoneAuthBtn.userInteractionEnabled = NO;
    } else {
        [self.phoneAuthBtn setTitle:@"未认证" forState:UIControlStateNormal];
        
        [self.phoneAuthBtn az_setGradientBackgroundWithColors:@[kRGBA(232, 214, 172, 1),kRGBA(236, 192, 111, 1)] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        [self.phoneAuthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.phoneAuthBtn.userInteractionEnabled = YES;
    }
    
    // 头像活体认证
    if ([[authDic[@"txhtrz"] stringValue] isEqualToString:@"1"]) {
        [self.headAuthBtn setTitle:@"已认证" forState:UIControlStateNormal];
        [self.headAuthBtn setTitleColor:kRGBA(187, 143, 73, 1) forState:UIControlStateNormal];
        self.headAuthBtn.backgroundColor = kRGBA(241, 224, 196, 1);
        self.headAuthBtn.userInteractionEnabled = NO;
        
    } else {
        
        [self.headAuthBtn setTitle:@"未认证" forState:UIControlStateNormal];
        [self.headAuthBtn az_setGradientBackgroundWithColors:@[kRGBA(232, 214, 172, 1),kRGBA(236, 192, 111, 1)] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        [self.headAuthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.headAuthBtn.userInteractionEnabled = YES;
    }
    
    // 身份证认证
    if ([[authDic[@"sfzrz"] stringValue] isEqualToString:@"1"]) {
        [self.cardAuthBtn setTitle:@"已认证" forState:UIControlStateNormal];
        [self.cardAuthBtn setTitleColor:kRGBA(187, 143, 73, 1) forState:UIControlStateNormal];
        self.cardAuthBtn.backgroundColor = kRGBA(241, 224, 196, 1);
        self.cardAuthBtn.userInteractionEnabled = NO;
        
    } else {
        
        [self.cardAuthBtn setTitle:@"未认证" forState:UIControlStateNormal];
        [self.cardAuthBtn az_setGradientBackgroundWithColors:@[kRGBA(232, 214, 172, 1),kRGBA(236, 192, 111, 1)] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        [self.cardAuthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.cardAuthBtn.userInteractionEnabled = YES;
    }
    
    // 学历认证
    if ([[authDic[@"xlrz"] stringValue] isEqualToString:@"1"]) {
        [self.xueLiAuthBtn setTitle:@"已认证" forState:UIControlStateNormal];
        [self.xueLiAuthBtn setTitleColor:kRGBA(187, 143, 73, 1) forState:UIControlStateNormal];
        self.xueLiAuthBtn.backgroundColor = kRGBA(241, 224, 196, 1);
        self.xueLiAuthBtn.userInteractionEnabled = NO;
        
    } else if ([[authDic[@"xlrz"] stringValue] isEqualToString:@"-1"]) {
        
        [self.xueLiAuthBtn setTitle:@"未认证" forState:UIControlStateNormal];
        [self.xueLiAuthBtn az_setGradientBackgroundWithColors:@[kRGBA(232, 214, 172, 1),kRGBA(236, 192, 111, 1)] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        [self.xueLiAuthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.xueLiAuthBtn.userInteractionEnabled = YES;
        
    } else {
        
        [self.xueLiAuthBtn setTitle:@"后台审核" forState:UIControlStateNormal];
        [self.xueLiAuthBtn az_setGradientBackgroundWithColors:@[kRGBA(232, 214, 172, 1),kRGBA(236, 192, 111, 1)] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        [self.xueLiAuthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.xueLiAuthBtn.userInteractionEnabled = NO;
    }
    
    // 平台审核认证
    if ([[authDic[@"ptshrz"] stringValue] isEqualToString:@"1"]) {
        [self.shenHeBtn setTitle:@"已审核" forState:UIControlStateNormal];
        [self.shenHeBtn setTitleColor:kRGBA(187, 143, 73, 1) forState:UIControlStateNormal];
        self.shenHeBtn.backgroundColor = kRGBA(241, 224, 196, 1);
        self.shenHeBtn.userInteractionEnabled = NO;
        
    } else {
        
        [self.shenHeBtn setTitle:@"后台审核" forState:UIControlStateNormal];
        [self.shenHeBtn az_setGradientBackgroundWithColors:@[kRGBA(232, 214, 172, 1),kRGBA(236, 192, 111, 1)] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        
        [self.shenHeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.shenHeBtn.userInteractionEnabled = NO;
    }
    
}

+ (instancetype)initWithXib:(CGRect)frame delegate:(id<HLVVipViewDelegate>)delegate {
    HLOpenVVipView *view = [[UINib nibWithNibName:NSStringFromClass([HLOpenVVipView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    view.delegate = delegate;
    [view awakeFromNib];
    return view;
}

// 问号
- (IBAction)wenHaoClick:(id)sender {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"sign":@"svip",
        @"pure":@"1"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [MBProgressHUD hideLoading];
            
            HLDreamLoverDesView *dView = [[HLDreamLoverDesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:dictionary[@"data"][@"val"]];
            
            dView.SelectBlock = ^{
                
            };
            
            dView.CloseBlock = ^{
                
            };
            
            [dView showSelf];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
    
}

// 下一步
- (IBAction)nextBtnClick:(UIButton *)sender {
    [self.delegate nextPushClick];
}

// 手机认证
- (IBAction)phoneClick:(id)sender {
    [self.delegate shoujirenzheng];
}

// 本人头像认证
- (IBAction)headClick:(id)sender {
    [self.delegate benrentouxiang];
}

// 身份认证
- (IBAction)cardClick:(id)sender {
    [self.delegate shenfenzheng];
}

// 学历认证
- (IBAction)xueLiClick:(id)sender {
    [self.delegate xulirenzheng];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
