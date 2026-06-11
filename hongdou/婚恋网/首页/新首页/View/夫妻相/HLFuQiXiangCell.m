//
//  HLFuQiXiangCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLFuQiXiangCell.h"

@interface HLFuQiXiangCell (){
    UIVisualEffectView *_blurEffectView;
}

@end

@implementation HLFuQiXiangCell

- (IBAction)searchClick:(UIButton *)sender {
    
    [_blurEffectView removeFromSuperview];
    
}

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    [self.benRenImgV sd_setImageWithURL:[NSURL URLWithString:dic[@"head"]]];
    
    if (!kISNullObject(dic[@"qjd"][@"head"])) {
        [self.taImgView sd_setImageWithURL:[NSURL URLWithString:dic[@"qjd"][@"head"]]];
    } else {
        self.taImgView.image = [UIImage imageNamed:@"cer_person_no"];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
        
    //添加边框
    _benRenImgV.layer.borderColor = [kRGBA(151, 152, 245, 1) CGColor];
    _benRenImgV.layer.borderWidth = 2.0f;
    
    _taImgView.layer.borderColor = [kRGBA(249, 152, 181, 1) CGColor];
    _taImgView.layer.borderWidth = 2.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuQiClick)];
    [_taImgView addGestureRecognizer:tap];
    
    
    // Blur effect 模糊效果
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _blurEffectView.frame = _taImgView.bounds;
    [_taImgView addSubview:_blurEffectView];
    
}

- (void)fuQiClick {
    
    if (_taImgView.subviews.count==0) {
        [self.delegate pushFuQiXiangDetail];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
