//
//  CSCoachDetailModel.h
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHomeGradeDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSCoachDetailModel : NSObject

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *habitation;
@property (nonatomic, copy) NSString *intelligence; // 资质类别
@property (nonatomic, copy) NSString *education; // 最高学历 v
@property (nonatomic, copy) NSString *school; // 院校 v
@property (nonatomic, copy) NSString *major; // 专业 v
@property (nonatomic, copy) NSString *descr; // 自我介绍 v
@property (nonatomic, copy) NSString *motto; // 职业格言 v
@property (nonatomic, copy) NSString *head; // 头像 v
@property (nonatomic, copy) NSString *wx; // 微信 v
@property (nonatomic, copy) NSString *qq; // QQ v
@property (nonatomic, copy) NSString *contact; // 电话 v
@property (nonatomic, copy) NSArray *papers; // 图片数组 v
 // 咨询类型 v
@property (nonatomic, strong) NSMutableArray <CSHomeGradeDetailModel*> *curriculum;

@end

NS_ASSUME_NONNULL_END
