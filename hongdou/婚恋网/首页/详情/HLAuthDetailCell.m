//
//  HLAuthDetailCell.m
//  hongdou
//
//  Created by 维康1 on 2020/6/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLAuthDetailCell.h"

@implementation HLAuthDetailCell

- (void)setAuthArray:(NSArray *)authArray {
    _authArray = authArray;
    
    
//    NSArray *arr = @[@{@"type":@"手机号"},@{@"type":@"头像"},@{@"type":@"身份证"},@{@"type":@"学历"},@{@"type":@"车辆"},@{@"type":@"职业"},@{@"type":@"房产"}];
    
    
    CGFloat w = (kScreenWidth-30)/4;
    
    for (int i=0; i<authArray.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        if (i>=4) {
            btn.frame = CGRectMake(15+((i-4)*w), 60, w, 40);
        } else {
            btn.frame = CGRectMake(15+(i*(kScreenWidth-30)/4), 10, (kScreenWidth-30)/4, 40);
        }
        
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if ([authArray[i][@"type"] isEqualToString:@"手机号"]) {
            [btn setTitle:@"手机认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"cer_phone_yes"] forState:UIControlStateNormal];
        }
        if ([authArray[i][@"type"] isEqualToString:@"头像"]) {
            [btn setTitle:@"人脸认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"cer_person_yes"] forState:UIControlStateNormal];
        }
        if ([authArray[i][@"type"] isEqualToString:@"身份证"]) {
            [btn setTitle:@"身份认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"shenfenzheng_per_ico"] forState:UIControlStateNormal];
        }
        if ([authArray[i][@"type"] isEqualToString:@"学历"]) {
            [btn setTitle:@"学历认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"xuelii_per_ico"] forState:UIControlStateNormal];
        }
        if ([authArray[i][@"type"] isEqualToString:@"车辆"]) {
            [btn setTitle:@"车辆认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"che_per_ico"] forState:UIControlStateNormal];
        }
        if ([authArray[i][@"type"] isEqualToString:@"职业"]) {
            [btn setTitle:@"职业认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"zhiye_pre_ico"] forState:UIControlStateNormal];
        }
        if ([authArray[i][@"type"] isEqualToString:@"房产"]) {
            [btn setTitle:@"房产认证" forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"fangzi_per_ico"] forState:UIControlStateNormal];
        }
        
        [self.contentView addSubview:btn];
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
