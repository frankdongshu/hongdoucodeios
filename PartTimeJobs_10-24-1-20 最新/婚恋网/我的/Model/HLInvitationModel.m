//
//  HLInvitationModel.m
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLInvitationModel.h"

@implementation HLInvitationModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"counts":@"count",
             @"invitemy":@"invitemy.head"
             };
}

@end
