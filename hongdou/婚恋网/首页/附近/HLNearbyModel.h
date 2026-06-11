//
//  HLNearbyModel.h
//  婚恋网
//
//  Created by iMac on 2019/6/28.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLNearbyModel : NSObject

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *uid; // 用户id

@property (nonatomic, copy) NSString *profile_photo; // 头像

@property (nonatomic, assign) BOOL isVip; // 是否是VIP用户
@property (nonatomic, assign) BOOL is_follow; // 是否关注

@property (nonatomic, copy) NSString *distance; // 距离
@property (nonatomic, copy) NSString *age; // 年龄
@property (nonatomic, copy) NSString *stature; // 身高
@property (nonatomic, copy) NSString *constellation; // 星座
@property (nonatomic, copy) NSString *sex; // 性别

@property (nonatomic, copy) NSString *birthday; // 生日
@property (nonatomic, copy) NSString *animal;//  属性
@property (nonatomic, copy) NSString *education; // 学历
@property (nonatomic, copy) NSString *jobs; // 工作
@property (nonatomic, assign) NSInteger income_level; // 收入等级
@property (nonatomic, copy) NSString *income; // 收入

@property (nonatomic, copy) NSString *my_voice; // 倾听我心

@property (nonatomic, copy) NSString *longitude; // 经度
@property (nonatomic, copy) NSString *latitude; // 纬度
@end

NS_ASSUME_NONNULL_END
