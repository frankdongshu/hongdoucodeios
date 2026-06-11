//
//  HLUser.m
//  婚恋网
//
//  Created by jxzhang on 2019/4/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLUser.h"

@implementation HLUser

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"userid":@"id",
             @"itemCount":@"count"
             };
}
- (void)mj_keyValuesDidFinishConvertingToObject{
    NSMutableArray *arr = [NSMutableArray array];
    if (self.pic_one.length>0) {
        [arr addObject:self.pic_one];
    }
    if (self.pic_two.length>0) {
        [arr addObject:self.pic_two];
    }
    if (self.pic_three.length>0) {
        [arr addObject:self.pic_three];
    }
    self.picArray = arr;
}
@end


@implementation HLFriendModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"userid":@"id"
             };
}

- (void)mj_keyValuesDidFinishConvertingToObject{
   
}
@end

@implementation HLSoundModel

@end

@implementation HLFriendUserModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"userid":@"id"
             };
}

@end
