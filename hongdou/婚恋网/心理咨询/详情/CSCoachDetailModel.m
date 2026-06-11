//
//  CSCoachDetailModel.m
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSCoachDetailModel.h"

@implementation CSCoachDetailModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"descr":@"description"};
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"curriculum":@"CSHomeGradeDetailModel"};
}

@end
