//
//  CSHomeGradeDetailModel.m
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/18.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

#import "CSHomeGradeDetailModel.h"

@implementation CSHomeGradeDetailModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id",
             @"parentGradeID":@"parent"
             };
}

@end
