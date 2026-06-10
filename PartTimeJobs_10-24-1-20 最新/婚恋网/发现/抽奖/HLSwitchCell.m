//
//  HLSwitchCell.m
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSwitchCell.h"

@implementation HLSwitchCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-15, 63)];
//        lab.backgroundColor = [UIColor redColor];
        
        lab.text = @"打开后参加拉新竞赛\n关闭后参加拉新挣钱";
        lab.font = kFontSize(14);
        lab.textColor = kRGBA(53, 56, 72, 1);
        lab.numberOfLines = 0;
        
        [self addSubview:lab];
        
        
        self.theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth-70, 17.5, 55, 28)];
        self.theSwitch.onTintColor = kRGBA(255, 92, 120, 1);
        [self.theSwitch addTarget:self action:@selector(changeSwitchStatu:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.theSwitch];
        
    }
    return self;
}

- (void)setStatu:(BOOL)statu{
    _statu = statu;
}

- (void)changeSwitchStatu:(UISwitch *)swicth{
    
    [self.theSwitch setOn:_statu];
    
    [self uploadRefesh];
       
}


- (void)uploadRefesh {
    [HLHTTPSessionManager postDataWithNSString:HLSwitch withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];

        if ([code isEqualToString:@"200"] ) {
            [self.theSwitch setOn:!self.statu];
            
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



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
