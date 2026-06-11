//
//  HLRecordModel.m
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLRecordModel.h"

@implementation HLRecordModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"recordId":@"id"
             };
}

@end
