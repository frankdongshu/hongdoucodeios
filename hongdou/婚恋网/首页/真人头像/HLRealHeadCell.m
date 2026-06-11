//
//  HLRealHeadCell.m
//  hongdou
//
//  Created by 维康1 on 2021/8/26.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLRealHeadCell.h"

@implementation HLRealHeadCell

- (void)setU:(HLUser *)u {
    _u = u;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:u.head]];
    
    [self.addBtn setTitle:u.habitation forState:UIControlStateNormal];
    
    self.nameLab.text = u.nickname;
    
    NSString *heightStr = kISNullObject(u.height)?@"":[NSString stringWithFormat:@"·%@",u.height];
    
    self.ageLab.text = [NSString stringWithFormat:@" %@岁%@   ",u.age,heightStr];
    self.ageLab.layer.borderWidth = .5;
    self.ageLab.layer.borderColor = [kRGBA(197, 158, 108, 1) CGColor];
    
    // 婚否
    self.xingZuoLab.text = [NSString stringWithFormat:@" %@   ",u.marital];
    self.xingZuoLab.layer.borderWidth = .5;
    self.xingZuoLab.layer.borderColor = [kRGBA(197, 158, 108, 1) CGColor];
    
    if (kISNullObject(u.marital)) {
        self.xingZuoLab.hidden = YES;
    } else {
        self.xingZuoLab.hidden = NO;
    }
    
    // 学历
    self.xueLiLab.text = [NSString stringWithFormat:@" %@   ",u.education];
    self.xueLiLab.layer.borderWidth = .5;
    self.xueLiLab.layer.borderColor = [kRGBA(197, 158, 108, 1) CGColor];
    
    if (kISNullObject(u.education)) {
        self.xueLiLab.hidden = YES;
    } else {
        self.xueLiLab.hidden = NO;
    }
    
    [self.shareBtn setTitle:[NSString stringWithFormat:@"%ld张",u.picArray.count] forState:UIControlStateNormal];
    
    self.followBtn.selected = u.in_follow;
    [self.followBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    
    self.listenLab.text = u.listen;
    
    
}

// 跳转详情
- (void)buttonAction {
    [self.delegate detailVipClickWithUser:self.u];
}

- (IBAction)shareBtnClick:(id)sender {
    [self.delegate shareVipClickWithPicArr:self.u.picArray];
}

- (IBAction)chatBtnClick:(id)sender {
    [self.delegate chatVipClickWithUserName:self.u];
}

- (IBAction)followBtnClick:(id)sender {
    [self.delegate followVipClickWithFollowBtn:sender andUser:self.u];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0;
    
    [self.shareBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [self.chatBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
