//
//  HLSquareTableViewCell.m
//  婚恋网
//
//  Created by iMac on 2019/6/28.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSquareTableViewCell.h"

@implementation HLSquareTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.followButton.hidden = YES;
    self.ageLable.layer.cornerRadius = 10.f;
    self.ageLable.layer.masksToBounds = YES;
    self.constellaLabel.layer.cornerRadius = 10.f;
    self.constellaLabel.layer.masksToBounds = YES;
    
}

- (void)setUserInfo:(HLUser *)model{
//    self.followButton.hidden  = !model.in_follow;
    
    if ([model.memberdata isEqualToString:@"0"]) { // 非会员
        self.vipImgV.hidden = YES;
        self.crownImgV.hidden = YES;
        self.headerImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.headerImageView.layer.borderWidth = 2; //边框的宽度
    } else { // 会员
        self.vipImgV.hidden = NO;
        self.crownImgV.hidden = NO;
        self.headerImageView.layer.borderColor=[kRGBA(248, 221, 115, 1) CGColor];
        self.headerImageView.layer.borderWidth = 2; //边框的宽度
    }
    
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    self.nicknameLable.text = model.nickname;
    self.distanceLabe.text = [NSString stringWithFormat:@"%@",model.distance ? model.distance : @"未知"];
    self.ageLable.text = @"";
    if (model.age.length>0 && model.height.length>0) {
        self.ageLable.text = [NSString stringWithFormat:@" %@岁· %@ ",model.age,model.height];
    }else{
        if (model.age.length>0) {
            self.ageLable.text = [NSString stringWithFormat:@" %@岁 ",model.age];
        }else{
            self.ageLable.text = [NSString stringWithFormat:@" %@ ",model.height];

        }
    }
    
    
    
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.constellation];
//    [text addAttribute:NSFontAttributeName value:kScaleFont(8) range:NSMakeRange(0, 1)];
//
//    self.constellaLabel.attributedText = text;
    
    NSString *string = [NSString stringWithFormat:@" %@ ",model.constellation];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSFontAttributeName value:kScaleFont(11) range:NSMakeRange(1, 1)];
    self.constellaLabel.attributedText = text;
//    self.constellaLabel.text =  [NSString stringWithFormat:@" %@ ", model.constellation.length ? model.constellation : @""];
    self.stageLable.text = model.education.length ? model.education : @"";
    self.occupationLabel.text = model.position.length ? model.position : @"";
    self.incomeLabel.text = model.earns.length ? model.earns : @"";
    self.introduceLabel.text = model.listen.length ? [NSString stringWithFormat:@"\n%@\n",model.listen]  : @"" ;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
