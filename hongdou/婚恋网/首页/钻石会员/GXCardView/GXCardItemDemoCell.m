//
//  GXCardItemDemoCell.m
//  GXCardViewDemo
//
//  Created by Gin on 2018/8/3.
//  Copyright © 2018年 gin. All rights reserved.
//

#import "GXCardItemDemoCell.h"

@implementation GXCardItemDemoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0;
    //    self.layer.shadowOffset = CGSizeMake(1.0, 3.0);
    //    self.layer.shadowRadius = 4.0;
    //    self.layer.shadowOpacity = 0.4;
    //    self.layer.shadowColor = [UIColor grayColor].CGColor;
    
    
    [self.shareBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [self.chatBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    
    self.imgView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction)];
    [self.imgView addGestureRecognizer:tap];
}

- (void)setU:(HLUser *)u {
    _u = u;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:u.head]];
    
    [self.addBtn setTitle:u.habitation forState:UIControlStateNormal];
    
    self.nameLab.text = u.nickname;
    
    self.ageLab.text = [NSString stringWithFormat:@" %@岁·%@   ",u.age,u.height];
    self.ageLab.layer.borderWidth = .5;
    self.ageLab.layer.borderColor = [kRGBA(197, 158, 108, 1) CGColor];
    
    self.xingZuoLab.text = [NSString stringWithFormat:@" %@   ",u.constellation];
    self.xingZuoLab.layer.borderWidth = .5;
    self.xingZuoLab.layer.borderColor = [kRGBA(197, 158, 108, 1) CGColor];
    
    self.xueLiLab.text = [NSString stringWithFormat:@" %@   ",u.education];
    self.xueLiLab.layer.borderWidth = .5;
    self.xueLiLab.layer.borderColor = [kRGBA(197, 158, 108, 1) CGColor];
    
    self.followBtn.selected = u.in_follow;
    [self.followBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    
    self.listenLab.text = u.listen;
    
    
}

// 跳转详情
- (void)buttonAction {
    [self.delegate detailVipClickWithUser:self.u];
}

- (IBAction)shareBtnClick:(id)sender {
    [self.delegate shareVipClickWithUid:self.u.userid];
}

- (IBAction)chatBtnClick:(id)sender {
    [self.delegate chatVipClickWithUserName:self.u];
}

- (IBAction)followBtnClick:(id)sender {
    [self.delegate followVipClickWithFollowBtn:sender andUser:self.u];
}

@end
