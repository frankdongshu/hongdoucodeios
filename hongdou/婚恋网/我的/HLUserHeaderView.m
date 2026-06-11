//
//  HLUserHeaderView.m
//  婚恋网
//
//  Created by iMac on 2019/3/25.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLUserHeaderView.h"

@implementation HLUserHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
//    [self az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xF3B2A1],[UIColor colorWithHex:0xEE7998]] locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    
    
    self.haadImageView.layer.cornerRadius = 30.0f;
    self.haadImageView.layer.masksToBounds = YES;
    self.vipLabel.hidden = YES;
    self.crownImgV.hidden = YES;
    self.haadImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
    self.haadImageView.layer.borderWidth = 2;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectHeaderImage)];
    [self.haadImageView addGestureRecognizer:tap];
    // 修改昵称
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectName)];
    self.nameLabel.userInteractionEnabled = YES;
    [self.nameLabel addGestureRecognizer:tap1];
    
    // 粉丝
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fansClick)];
    self.fansView.userInteractionEnabled = YES;
    [self.fansView addGestureRecognizer:tap2];
    
    // 关注
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followClick)];
    self.followView.userInteractionEnabled = YES;
    [self.followView addGestureRecognizer:tap3];
    
    // 提现
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cashClick)];
    self.cashView.userInteractionEnabled = YES;
    [self.cashView addGestureRecognizer:tap4];
    
    [self setHeadeInfo];
}

+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLUserHeaderViewDelegate>)delegate{
    HLUserHeaderView *view = [[UINib nibWithNibName:NSStringFromClass([HLUserHeaderView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    view.delegate = delegate;
    [view awakeFromNib];
    return view;
}

- (void)setUserInfo:(HLUser *)userInfo{
    _userInfo = userInfo;
    [self.haadImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    if ([userInfo.memberdata isEqualToString:@"0"]) { // 非会员
        self.vipLabel.hidden = YES;
        self.crownImgV.hidden = YES;
        self.haadImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.haadImageView.layer.borderWidth = 2;
    } else { // 会员
        self.vipLabel.hidden = NO;
        self.crownImgV.hidden = NO;
        self.haadImageView.layer.borderColor=[kRGBA(248, 221, 115, 1) CGColor];
        self.haadImageView.layer.borderWidth = 2; //边框的宽度
    }
    self.nameLabel.text = [LoginManager defaultManager].nickName;
    self.userIDLabel.text = [NSString stringWithFormat:@"ID:%@",[LoginManager defaultManager].userid];
    self.fansLable.text = userInfo.fans ? userInfo.fans : @"0";
    self.followLable.text = userInfo.follow ? userInfo.follow : @"0";
    self.moneyLable.text = userInfo.balance ? userInfo.balance : @"0";
    self.itemCountLab.text = [NSString stringWithFormat:@"%@项未填",kISNullObject(userInfo.itemCount)?@"???":userInfo.itemCount];
}

- (void)setHeadeInfo{
    [self.haadImageView sd_setImageWithURL:[NSURL URLWithString:[LoginManager defaultManager].avatar] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    if (![LoginManager defaultManager].isVip) {
        self.vipLabel.hidden = YES;
    }
    self.nameLabel.text = [LoginManager defaultManager].nickName;
    self.userIDLabel.text = [NSString stringWithFormat:@"ID:%@",[LoginManager defaultManager].userid];

    
    self.fansLable.text = [NSString stringWithFormat:@"%@",[LoginManager defaultManager].fans.length ? [LoginManager defaultManager].follows : @"0"];
    self.followLable.text = [NSString stringWithFormat:@"%@",[LoginManager defaultManager].follows.length ? [LoginManager defaultManager].follows : @"0"];
    self.moneyLable.text = [LoginManager defaultManager].balance.length ? [LoginManager defaultManager].balance : @"0";
    
}
- (IBAction)pushDetailClick:(id)sender {
    if([_delegate respondsToSelector:@selector(pushyUserDetailAction)]){
        [_delegate pushyUserDetailAction];
    }
}
- (void)selectHeaderImage{
    if([_delegate respondsToSelector:@selector(changeHeaderImage)]){
        [_delegate changeHeaderImage];
    }
}

// 进入粉丝界面
- (void)fansClick {
    if([_delegate respondsToSelector:@selector(pushFansVC)]){
        [_delegate pushFansVC];
    }
}
// 进入关注界面
- (void)followClick {
    if([_delegate respondsToSelector:@selector(pushFollowVC)]){
        [_delegate pushFollowVC];
    }
}

// 进入提现界面
- (void)cashClick {
    if ([_delegate respondsToSelector:@selector(pushCashVC)]) {
//        [_delegate pushCashVC];
    }
}


// 修改昵称
- (void)selectName {
    if([_delegate respondsToSelector:@selector(changeName)]){
        [_delegate changeName];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
