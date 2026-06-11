//
//  HLUserHeaderView.h
//  婚恋网
//
//  Created by iMac on 2019/3/25.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLUserHeaderViewDelegate <NSObject>

- (void)pushyUserDetailAction;
- (void)changeHeaderImage; // 修改头像
- (void)changeName; // 修改昵称
- (void)pushFansVC; // 进入粉丝界面
- (void)pushFollowVC; // 进入关注界面
- (void)pushCashVC; // 进入提现界面


@end

NS_ASSUME_NONNULL_BEGIN

@interface HLUserHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *haadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLable;
@property (weak, nonatomic) IBOutlet UILabel *followLable;
@property (weak, nonatomic) IBOutlet UILabel *moneyLable;
@property (weak, nonatomic) IBOutlet UIView *fansView;
@property (weak, nonatomic) IBOutlet UIView *followView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *cashView; // 提现View
@property (weak, nonatomic) IBOutlet UILabel *itemCountLab;
@property (weak, nonatomic) IBOutlet UIImageView *crownImgV;

@property (nonatomic, strong)HLUser *userInfo;


@property (nonatomic, assign) id<HLUserHeaderViewDelegate>delegate;
+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLUserHeaderViewDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
