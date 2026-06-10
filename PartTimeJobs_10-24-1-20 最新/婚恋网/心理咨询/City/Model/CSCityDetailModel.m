//
//  CSCityDetailModel.m
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/19.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

#import "CSCityDetailModel.h"

@implementation CSCityDetailModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"lists":@"CSCityInfoModel"};
}
@end

@implementation CSCityInfoModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id"};
}
@end

@implementation CSCityChooseModel

@end

