//
//  LoginManager.h
//  婚恋网
//
//  Created by jxzhang on 2019/4/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic , assign) BOOL isLogin;  //是否已经登录
@property (nonatomic , assign) BOOL isEditInfo;  //是否需要编辑信息

@property (nonatomic , retain) NSString *account;   //登录账号
@property (nonatomic , retain) NSString *password;   //登录密码
@property (nonatomic , retain) NSString *userid;    //用户id
@property (nonatomic , retain) NSString *nickName;  //昵称
@property (nonatomic , retain) NSString *gender;  //性别
@property (nonatomic,  retain) NSString *avatar; //头像
@property (nonatomic,  retain) NSString *birthday; //生日
@property (nonatomic,  retain) NSString *habitation; //城市

@property (nonatomic,  retain) NSString *token; //token
@property (nonatomic , retain) NSString *wxOpenId; // 微信openId

@property (nonatomic , retain) NSString *fans; //粉丝数
@property (nonatomic , retain) NSString *follows; // 关注数
@property (nonatomic , retain) NSString *balance; //余额

@property (nonatomic , assign) BOOL isVip; // 是否为VIP

@property (nonatomic , retain) NSString *weixinRefreshToken;

//退出当前账号
-(void)doLogout;

@end

NS_ASSUME_NONNULL_END
