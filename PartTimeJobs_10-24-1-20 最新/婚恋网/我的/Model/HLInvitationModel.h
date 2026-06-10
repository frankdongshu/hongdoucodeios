//
//  HLInvitationModel.h
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLInvitationModel : NSObject

@property (nonatomic, copy) NSString *counts; // 邀请人数
@property (nonatomic, copy) NSString *reward; // 奖金
@property (nonatomic, strong) NSArray *myinvite; //邀请人数组
@property (nonatomic, strong) NSString *invitemy; // 推荐人信息

@end

NS_ASSUME_NONNULL_END
