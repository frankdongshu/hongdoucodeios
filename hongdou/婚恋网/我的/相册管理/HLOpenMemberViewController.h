//
//  HLOpenMemberViewController.h
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"
#import <GDTRewardVideoAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLOpenMemberViewController : HXBaseViewController

// 聊天界面进入开通会员界面点击钻石会员
@property (nonatomic, assign) BOOL isChat;

@property (nonatomic, strong) UINavigationController *chatVC;

@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;

@end

NS_ASSUME_NONNULL_END
