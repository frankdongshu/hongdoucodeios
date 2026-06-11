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
@property (nonatomic,  retain) NSString *avatar; //头像
@property (nonatomic , retain) NSString *loginType; //登录类型
@property (nonatomic,  retain) NSString *token; //token

@property (nonatomic , retain) NSString *fans; //粉丝数
@property (nonatomic , retain) NSString *follows; // 关注数
@property (nonatomic , retain) NSString *balance; //余额

@property (nonatomic , retain) NSString *memberdata; // 会员否

@property (nonatomic , retain) NSString *iid; // 发布课程iid

@property (nonatomic , assign) BOOL isVip; // 是否为VIP

@property (nonatomic , retain) NSString *weixinRefreshToken;
//@property (nonatomic , strong) HLUser * currentUser; //从数据库中获取的当前用户信息

//初始化登录信息
-(void)doLoginWithDictionary:(NSDictionary *)dic;

//退出当前账号
-(void)doLogout;

@end

NS_ASSUME_NONNULL_END
