//
//  HLYiQiWanCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLYiQiWanCell.h"

@implementation HLYiQiWanCell

- (IBAction)huanClick:(UIButton *)sender {
    
    if (![LoginManager defaultManager].isVip) {
        [self.delegate pushYiQiWanVipClick];
        return;
    }
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/rh_find" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            [self.delegate reloadYiQiPlayWithDataDic:dictionary[@"data"]];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
