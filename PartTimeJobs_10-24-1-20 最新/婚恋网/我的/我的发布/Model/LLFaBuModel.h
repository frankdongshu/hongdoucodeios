//
//  LLFaBuModel.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLFaBuModel : NSObject


@property (nonatomic, assign) NSInteger iid; // id
@property (nonatomic, copy) NSString *addtime; // 添加时间
@property (nonatomic, copy) NSString *cost_high; // 最高价格
@property (nonatomic, copy) NSString *cost_low; // 最低价格
@property (nonatomic, copy) NSString *curriculum; // 课程
@property (nonatomic, copy) NSString *demand; // 描述
@property (nonatomic, copy) NSString *identity; // 身份
@property (nonatomic, copy) NSString *place; // 地址
@property (nonatomic, copy) NSString *teaching; // 授课方式
@property (nonatomic, copy) NSString *head; // 头像
@property (nonatomic, copy) NSString *username; // username

//新接口数据
@property (nonatomic, assign) NSInteger age; // age
@property (nonatomic, copy) NSString *birthday; // birthday
@property (nonatomic, copy) NSString *city; //
@property (nonatomic, copy) NSString *education; //
@property (nonatomic, copy) NSString *intelligence; //
@property (nonatomic, copy) NSString *major; //
@property (nonatomic, copy) NSString *mobile; //
@property (nonatomic, copy) NSString *nickname; //
@property (nonatomic, copy) NSString *school; //
@property (nonatomic, copy) NSString *sex; //


@end

NS_ASSUME_NONNULL_END
