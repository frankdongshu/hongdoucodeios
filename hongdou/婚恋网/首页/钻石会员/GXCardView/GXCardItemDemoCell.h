//
//  GXCardItemDemoCell.h
//  GXCardViewDemo
//
//  Created by Gin on 2018/8/3.
//  Copyright © 2018年 gin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXCardView.h"

@protocol GXCardViewCellDelegate <NSObject>

///分享回调
- (void)shareVipClickWithUid:(NSString *)uid;

///聊天回调
- (void)chatVipClickWithUserName:(HLUser *)user;

///关注回调
- (void)followVipClickWithFollowBtn:(UIButton *)sender andUser:(HLUser *)u;

///跳转详情
- (void)detailVipClickWithUser:(HLUser *)u;

@end

@interface GXCardItemDemoCell : GXCardViewCell

@property (nonatomic, assign) id<GXCardViewCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *listenLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgView;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property (weak, nonatomic) IBOutlet UILabel *xingZuoLab;
@property (weak, nonatomic) IBOutlet UILabel *xueLiLab;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;


@property (nonatomic, strong) HLUser *u;

@end
