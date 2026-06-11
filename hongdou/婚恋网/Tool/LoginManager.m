//
//  LoginManager.m
//  婚恋网
//
//  Created by jxzhang on 2019/4/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "LoginManager.h"

#define HLAutoLogin @"LoginSuccess"
#define HLisEditInfo @"isEditInfo"

#define HLLastLoginAccount @"username"
#define HLLastLoginPassword @"password"
#define HLVisitorLoginAccount @"visitorUsername"
#define HLLastLoginUserId @"userid"
#define HLLoginType @"loginType"
#define HLLastLoginUserNick @"loginnick"
#define HLLastLoginUserSex @"loginSex"
#define HLWeixinRefreshToken @"refreshtoken"
#define HLToken @"token"
#define HLPhoto @"photo"

#define HLFans  @"fans"
#define HLFollews @"follows"
#define HLBalance @"balance"
#define HLISVIP @"isVIP"

@implementation LoginManager

+ (instancetype)defaultManager {
    
    static LoginManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [LoginManager new];
    });
    
    return sharedInstance;
}

// 是否已经登录
- (BOOL)isLogin {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:HLAutoLogin];
}

// 设置已经登录
- (void)setIsLogin:(BOOL)isLogin {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isLogin forKey:HLAutoLogin];
    [defaults synchronize];
}

// 获取是否完善
- (BOOL)isEditInfo {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:HLisEditInfo];
}

// 设置是否完善
- (void)setIsEditInfo:(BOOL)isEditInfo {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isEditInfo forKey:HLisEditInfo];
    [defaults synchronize];
}

// 获取上一次自动登录的用户名
- (NSString *)account {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLLastLoginAccount];
}

// 设置上一次自动登录的用户名
- (void)setAccount:(NSString *)account {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (account) {
        [defaults setObject:account forKey:HLLastLoginAccount];
    } else {
        [defaults removeObjectForKey:HLLastLoginAccount];
    }
    [defaults synchronize];
}

// 获取密码
- (NSString *)password {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLLastLoginPassword];
}

// 设置密码
- (void)setPassword:(NSString *)password {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (password) {
        [defaults setObject:password forKey:HLLastLoginPassword];
    } else {
        [defaults removeObjectForKey:HLLastLoginPassword];
    }
    [defaults synchronize];
}

// 获取上一次自动登录的用户的昵称--用于设置页面显示
- (NSString *)nickName {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLLastLoginUserNick];
}

// 设置上一次自动登录的用户名
- (void)setNickName:(NSString *)nick {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!kISNullString(nick)) {
        [defaults setObject:nick forKey:HLLastLoginUserNick];
    } else {
        [defaults removeObjectForKey:HLLastLoginUserNick];
    }
    [defaults synchronize];
}

// 获取性别
- (NSString *)gender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLLastLoginUserSex];
}

// 设置性别
- (void)setGender:(NSString *)sex {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!kISNullObject(sex)) {
        [defaults setObject:sex forKey:HLLastLoginUserSex];
    } else {
        [defaults removeObjectForKey:HLLastLoginUserSex];
    }
    [defaults synchronize];
}

// 获取生日
- (NSString *)birthday {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"loginBirthday"];
}

// 设置生日
- (void)setBirthday:(NSString *)birthday {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!kISNullObject(birthday)) {
        [defaults setObject:birthday forKey:@"loginBirthday"];
    } else {
        [defaults removeObjectForKey:@"loginBirthday"];
    }
    [defaults synchronize];
}

// 获取所在地
- (NSString *)habitation {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"loginHabitation"];
}

// 设置所在地
- (void)setHabitation:(NSString *)habitation {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!kISNullObject(habitation)) {
        [defaults setObject:habitation forKey:@"loginHabitation"];
    } else {
        [defaults removeObjectForKey:@"loginHabitation"];
    }
    [defaults synchronize];
}

// 获取上一次自动登录的用户id
- (NSString *)userid {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLLastLoginUserId];
}

// 设置上一次自动登录的用户id
- (void)setUserid:(NSString *)userid {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (userid) {
        userid = [NSString stringWithFormat:@"%@",userid];
        [defaults setObject:userid forKey:HLLastLoginUserId];
    } else {
        [defaults removeObjectForKey:HLLastLoginUserId];
    }
    [defaults synchronize];
}

// 微信openId
- (NSString *)wxOpenId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"WX_OPENID"];
}

// 设置上一次自动登录的用户id
- (void)setWxOpenId:(NSString *)wxOpenId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (wxOpenId) {
        wxOpenId = [NSString stringWithFormat:@"%@",wxOpenId];
        [defaults setObject:wxOpenId forKey:@"WX_OPENID"];
    } else {
        [defaults removeObjectForKey:@"WX_OPENID"];
    }
    [defaults synchronize];
}

// 获取token
- (NSString *)token {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLToken];
}

// 设置Token
- (void)setToken:(NSString *)token {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (token) {
        [defaults setObject:token forKey:HLToken];
    } else {
        [defaults removeObjectForKey:HLToken];
    }
    [defaults synchronize];
}

// 获取头像
- (NSString *)avatar {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLPhoto];
}

// 设置头像
- (void)setAvatar:(NSString *)avatar {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!kISNullString(avatar)) {
        [defaults setObject:avatar forKey:HLPhoto];
    } else {
        [defaults removeObjectForKey:HLPhoto];
    }
    [defaults synchronize];
}

// 获取粉丝
- (NSString *)fans {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLFans];
}

// 设置粉丝数
- (void)setFans:(NSString *)fans {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (fans) {
        [defaults setObject:fans forKey:HLFans];
    } else {
        [defaults removeObjectForKey:HLFans];
    }
    [defaults synchronize];
}

// 获取关注
- (NSString *)follows {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLFollews];
}

// 设置关注数
- (void)setFollows:(NSString *)follows {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (follows) {
        [defaults setObject:follows forKey:HLFollews];
    } else {
        [defaults removeObjectForKey:HLFollews];
    }
    [defaults synchronize];
}

// 获取余额
- (NSString *)balance {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLBalance];
}

// 设置余额
- (void)setBalance:(NSString *)balance {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (balance) {
        [defaults setObject:balance forKey:HLBalance];
    } else {
        [defaults removeObjectForKey:HLBalance];
    }
    [defaults synchronize];
}

// 是否开通畅聊
- (BOOL)isVip {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:HLISVIP];
}

// 设置是否开通畅聊
- (void)setIsVip:(BOOL)isVip {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isVip forKey:HLISVIP];
    [defaults synchronize];
}

// 获取微信的RefreshToken
- (NSString *)weixinRefreshToken {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:HLWeixinRefreshToken];
}

// 设置微信的RefreshToken
- (void)setWeixinRefreshToken:(NSString *)token {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (token) {
        [defaults setObject:token forKey:HLWeixinRefreshToken];
    } else {
        [defaults removeObjectForKey:HLWeixinRefreshToken];
    }
    [defaults synchronize];
}

// 退出当前账号
- (void)doLogout {
    
    [self setIsLogin:NO];
    [self setAccount:@""];
    [self setPassword:@""];
    [self setToken:@""];
    [self setUserid:@""];
    [self setNickName:@""];
    [self setAvatar:@""];
    [self setFans:@"0"];
    [self setFollows:@"0"];
    [self setBalance:@"0.0"];
    [self setWxOpenId:@""];
    [self setBirthday:@""];
    [self setHabitation:@""];
}

@end
