//
//  HLListModel.m
//  hongdou
//
//  Created by iMac on 2019/9/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLListModel.h"

@implementation HLListModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
        @"Id":@"id",
        @"name":@"val"
    };
}

@end


@implementation HLAllCityModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"cityArray":@"lists"
             };
}
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"cityArray":@"HLCityModel"};
}
@end

@implementation HLCityModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"cityID":@"id",
             @"cityName":@"city"
             };
}

@end
