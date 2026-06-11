//
//  HLNewVipModel.m
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLNewVipModel.h"

@implementation HLNewVipModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"vipArr":@"new_vip"
             };
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"vipArr":@"HLNewVipPerModel"};
}

@end

@implementation HLNewVipPerModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"uid":@"id"
             };
}

@end
