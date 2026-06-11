//
//  HLVSettingCell.m
//  hongdou
//
//  Created by 维康1 on 2020/8/21.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLVSettingCell.h"

@implementation HLVSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.swicthOn.onTintColor = kRGBA(121, 215, 110, 1);
    [self.swicthOn addTarget:self action:@selector(changeSwitchStatu:) forControlEvents:UIControlEventValueChanged];
}

- (void)setStatu:(BOOL)statu{
    _statu = statu;
}

- (void)setIndex:(NSInteger)index{
    _index = index;
}

- (void)changeSwitchStatu:(UISwitch *)swicth{
    
    switch (self.index) {
        case 0:
        {
            [self uploadRefeshType:@"in_svip"];

        }
            break;
        case 1:
        {
            [self uploadRefeshType:@"in_com"];

        }
            break;
            
        default:
            break;
    }
}

- (void)uploadRefeshType:(NSString *)type{
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"set":type,
        @"var":[NSString stringWithFormat:@"%d",!self.statu]
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/Svip/cha_set" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];

        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.statu = self.swicthOn.isOn;
            
            if (self.delegate &&  [self.delegate respondsToSelector:@selector(refreshTableView)]) {
                [self.delegate refreshTableView];
            }
            
        } else {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
