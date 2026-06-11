//
//  HLPunchCardController.m
//  hongdou
//
//  Created by 维康1 on 2021/2/25.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLPunchCardController.h"

@interface HLPunchCardController ()

// 签到天数
@property (weak, nonatomic) IBOutlet UILabel *messageLab;
@property (weak, nonatomic) IBOutlet UIImageView *hongbaoImgV;

@end

@implementation HLPunchCardController

// 点击签到
- (IBAction)qianBtnClick:(id)sender {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/sign/sign_in" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            // 签到信息
            [self qiandaoxinxi];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sc_navigationBar.title = @"签到";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    // 签到信息
    [self qiandaoxinxi];
    
    
    self.hongbaoImgV.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction)];
    [self.hongbaoImgV addGestureRecognizer:tap];
    
    
}

// 领取红包
- (void)buttonAction {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/sign/reward" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 签到信息
- (void)qiandaoxinxi {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/sign/get_sign" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"您已连续签到%@天",dictionary[@"data"][@"days"]]];
            
            NSRange redRange = NSMakeRange(6,1);
            
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:redRange];
            [noteStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:redRange];
            
            self.messageLab.attributedText = noteStr;
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
