//
//  HLVisitorCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLVisitorCell.h"

@implementation HLVisitorCell

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    if (kISNullObject(dic)) {
        return;
    }
    
    NSString *dataStr = [NSString stringWithFormat:@"%@",dic[@"seen_you_count"]];
    
    NSString *formatString = @"位异性最近来访";
    
    NSString *string = [NSString stringWithFormat:@"%@%@",dataStr,formatString];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    
    [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 121, 1) range:[string rangeOfString:dataStr]];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:[string rangeOfString:dataStr]];
    
    [text addAttribute:NSForegroundColorAttributeName value:kRGBA(63, 70, 88, 1) range:[string rangeOfString:formatString]];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:[string rangeOfString:formatString]];
    
    UILabel *lab = [[UILabel alloc] init];
    
    lab.attributedText = text;
    
    [self.containerView addSubview:lab];
    
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView.mas_top).offset(14);
        make.bottom.equalTo(self.containerView.mas_bottom).offset(-14);
        make.left.mas_equalTo(15);
    }];
    
    NSArray *arr = dic[@"seen_you"];
    
//    NSLog(@"~~~: %@",arr);
    
    for (int i=0; i<arr.count; i++) {
        
        if (i>4) {
            return;
        }
        
        UIImageView *imgV = [[UIImageView alloc] init];
        
        if (i==4) {
            imgV.image = [UIImage imageNamed:@"home_more"];
        } else {
            [imgV sd_setImageWithURL:[NSURL URLWithString:arr[i][@"head"]]];
        }
        
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.layer.masksToBounds = YES;
        imgV.layer.cornerRadius = 18;
        
        imgV.layer.borderWidth = 2;
        imgV.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        [self.containerView addSubview:imgV];
        
        
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.containerView.mas_top).offset(14);
            make.bottom.equalTo(self.containerView.mas_bottom).offset(-14);
            
//            make.left.equalTo(lab.mas_right).offset(30*i+70);
            
            int cou = arr.count>4?4:arr.count-1;
            make.right.equalTo(self.containerView.mas_right).offset(-30*(cou-i)-15);
            
            make.size.mas_equalTo(CGSizeMake(36, 36));
            
        }];

    }
    
    
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
