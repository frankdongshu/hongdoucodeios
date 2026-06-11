//
//  MyLogin.h
//  hongdou
//
//  Created by 李龙 on 2020/3/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyLogin : NSObject<NSCoding>

@property (nonatomic, copy) NSString *userid;  //用户id
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *habitation;
@property (nonatomic, copy) NSString *identity;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *pay_city;
@property (nonatomic, copy) NSString *locking;
// 以下属性登录接口没有返回, 获取其他信息接口返回的
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
@property (nonatomic, copy) NSArray *pic; // 图片数组 v
@property (nonatomic, copy) NSArray *curriculum; // 咨询类型 v

// 获取当前登录人信息
+ (MyLogin *)getCurrentLoginUser;
// 退出登录
+ (void)logOut;
// 是否登录
+ (BOOL)userHadLogin;
// 修改信息
+ (BOOL)updateUser:(MyLogin *)newUser;


@end

NS_ASSUME_NONNULL_END
