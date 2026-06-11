//
//  LLFutureModel.h
//  hongdou
//
//  Created by 李龙 on 2020/3/18.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLFutureModel : NSObject

@property (nonatomic, copy) NSString *end_time; // 活动结束时间
@property (nonatomic, copy) NSString *activityId; // 活动id
@property (nonatomic, copy) NSString *introduce; // 活动说明
@property (nonatomic, copy) NSString *mininv; // 资格数量
@property (nonatomic, copy) NSString *name; // 奖品名称
@property (nonatomic, copy) NSString *number; // 获奖人数
@property (nonatomic, copy) NSString *pic; // 活动图片
@property (nonatomic, copy) NSString *start_time; // 活动开始时间

@end

NS_ASSUME_NONNULL_END
