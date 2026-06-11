//
//  HLSwitchTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/9/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSwitchTableViewCell.h"

@implementation HLSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.swicthOn.onTintColor = [UIColor colorWithHex:0x8C49FF];
    [self.swicthOn addTarget:self action:@selector(changeSwitchStatu:) forControlEvents:UIControlEventValueChanged];
}

- (void)setStatu:(BOOL)statu{
    _statu = statu;
}

- (void)setIndex:(NSInteger)index{
    _index = index;
}

- (void)changeSwitchStatu:(UISwitch *)swicth{
    [self.swicthOn setOn:_statu];
    switch (self.index) {
//        case 0:
//            {
//                [self uploadRefeshType:@"voice"];
//            }
//            break;
//        case 1:
//        {
//            [self uploadRefeshType:@"shock"];
//
//        }
//            break;
        case 0:
        {
            [self uploadRefeshType:@"letter"];

        }
            break;
        case 1:
        {
            [self uploadRefeshType:@"follow"];

        }
            break;
        case 2:
        {
            [self uploadRefeshType:@"likes"];

        }
            break;
        case 3:
        {
            [self uploadRefeshType:@"see"];

        }
            break;
            
        default:
            break;
    }
}

- (void)uploadRefeshType:(NSString *)type{
    [HLHTTPSessionManager postDataWithNSString:HLNitifiction_Set withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"type":type,@"val":[NSString stringWithFormat:@"%d",!self.statu]} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];

        if ([code isEqualToString:@"200"] ) {
            [self.swicthOn setOn:!self.statu];
            if (self.delegate &&  [self.delegate respondsToSelector:@selector(refreshTableView)]) {
                [self.delegate refreshTableView];
            }

        }else {
            [[UIApplication sharedApplication].keyWindow showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow showTostWithMessage:@"修改失败，请重试"];

    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
