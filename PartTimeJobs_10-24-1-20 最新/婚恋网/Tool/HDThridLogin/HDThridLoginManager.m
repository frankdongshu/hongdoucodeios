//
//  HDThridLoginManager.m
//  婚恋网
//
//  Created by iMac on 2019/4/3.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HDThridLoginManager.h"

@implementation HDThridLoginManager

+ (instancetype)sharedManager {
    
    static HDThridLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[HDThridLoginManager alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - QQ登录
- (void)openQQ {
    
    [ShareSDK authorize:SSDKPlatformTypeQQ settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
                [self tencentDidLoginWithAccessToken:user.credential.rawData[@"access_token"] OpenId:user.credential.rawData[@"openid"]];
                break;
                
            case SSDKResponseStateFail:
                NSLog(@"--%@",error.description);
                break;
                
            case SSDKResponseStateCancel:
                //用户取消授权
                NSLog(@"用户取消授权");
                break;
                
            default:
                break;
        }
        
    }];
    
}

#pragma mark - 微信登录
- (void)openWeixin {
    
    [ShareSDK authorize:SSDKPlatformTypeWechat settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
                [self weixinDidLoginWithAccessToken:user.credential.rawData[@"access_token"] OpenId:user.credential.rawData[@"openid"] RefreshToken:user.credential.rawData[@"refresh_token"]];
                break;
                
            case SSDKResponseStateFail:
                NSLog(@"--%@",error.description);
                break;
                
            case SSDKResponseStateCancel:
                //用户取消授权
                NSLog(@"用户取消授权");
                break;
                
            default:
                break;
        }
        
    }];
    
}

#pragma mark - TencentLoginDelegate

- (void)tencentDidLoginWithAccessToken:(NSString *)access_token OpenId:(NSString *)openid {
    
    NSDictionary *params = @{
        @"openid":openid,
        @"access_token":access_token
    };
    
    [kAppDelegate.window showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLThird_QQLOGIN withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~%@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) { // 登陆成功
            [kAppDelegate.window hideLoading];
            
            [[LoginManager defaultManager] setLoginType:NeedBindAccount]; //三方登录
            //保存最后登录的手机号
            [[LoginManager defaultManager] setAccount:[dictionary[@"data"][@"data"] objectForKey:@"username"]];
            [[LoginManager defaultManager] setPassword:[dictionary[@"data"][@"data"] objectForKey:@"password"]]; // 密码
            [[LoginManager defaultManager] setUserid:[dictionary[@"data"][@"data"] objectForKey:@"id"]];
            //保存最后登录的用户昵称
            [[LoginManager defaultManager] setNickName:[dictionary[@"data"][@"data"] objectForKey:@"nickname"]];
            [[LoginManager defaultManager] setToken:[dictionary[@"data"][@"data"] objectForKey:@"token"]];
            [[LoginManager defaultManager] setAvatar:[dictionary[@"data"][@"data"] objectForKey:@"head"]];
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]];
            
            [self requestCurrentUserInfoWithUid:[NSString stringWithFormat:@"%@",dictionary[@"data"][@"data"][@"id"]]]; // 会员否
            
            
            // 设置别名
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {
                    NSLog(@"qq添加别名成功");
                }
                
            } seq:0];
            
            if (![dictionary[@"data"][@"type"] boolValue]) { // 需要绑定
                
                NSDictionary *dic = @{
                    @"type":dictionary[@"data"][@"in"],
                    @"openid":openid
                };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginNeedBindPhoneNoti object:dic];
                
            } else {
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            }
            
            
        } else {
            [kAppDelegate.window showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showErrorWithMessage:error.localizedDescription];
    }];

}



#pragma mark - WXApiDelegate

- (void)weixinDidLoginWithAccessToken:(NSString *)access_token OpenId:(NSString *)openid RefreshToken:(NSString *)refresh_token {
    
    NSDictionary *params = @{
        @"openid":openid,
        @"access_token":access_token
    };
    
    [kAppDelegate.window showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLThird_WXLOGIN withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~%@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) { // 登陆成功
            [kAppDelegate.window hideLoading];
            
            [[LoginManager defaultManager] setLoginType:NeedBindAccount]; //三方登录
            //保存最后登录的手机号
            [[LoginManager defaultManager] setAccount:[dictionary[@"data"][@"data"] objectForKey:@"username"]];
            [[LoginManager defaultManager] setPassword:[dictionary[@"data"][@"data"] objectForKey:@"password"]]; // 密码
            [[LoginManager defaultManager] setUserid:[dictionary[@"data"][@"data"] objectForKey:@"id"]];
            //保存最后登录的用户昵称
            [[LoginManager defaultManager] setNickName:[dictionary[@"data"][@"data"] objectForKey:@"nickname"]];
            [[LoginManager defaultManager] setToken:[dictionary[@"data"][@"data"] objectForKey:@"token"]];
            [[LoginManager defaultManager] setAvatar:[dictionary[@"data"][@"data"] objectForKey:@"head"]];
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]];
            
            [self requestCurrentUserInfoWithUid:[NSString stringWithFormat:@"%@",dictionary[@"data"][@"data"][@"id"]]]; // 会员否
            
            
            // 设置别名
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {
                    NSLog(@"vx添加别名成功");
                }

            } seq:0];
            
            
            if (![dictionary[@"data"][@"type"] boolValue]) { // 需要绑定
                
                NSDictionary *dic = @{
                    @"type":dictionary[@"data"][@"in"],
                    @"openid":openid
                };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginNeedBindPhoneNoti object:dic];
                
            } else {
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            }
            
            
        } else {
            [kAppDelegate.window showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showErrorWithMessage:error.localizedDescription];
    }];
    
}

// 请求当前用户的信息
- (void)requestCurrentUserInfoWithUid:(NSString *)uid{
    
    NSDictionary *params = @{
        @"uid":uid
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLGET_UserINFO withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [[LoginManager defaultManager] setMemberdata:dictionary[@"data"][@"memberdata"]]; // 会员否
            
        } else {
            [kAppDelegate.window showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showErrorWithMessage:error.localizedDescription];
    }];
    
}

//test
-(void)getUserInfoWithAccessToken:(NSString *)accessToken OpenId:(NSString *)openid
{
//    HXHTTPSessionManager * sessionManager = [HXHTTPSessionManager sharedClient];
//
//    NSString * url = [NSString stringWithFormat:WeiXin_UserInfo,accessToken,openid];
//
//    [sessionManager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        //
//
//        //        NSString * access_token= [responseObject objectForKey:@"access_token"];
//        //        NSString * refresh_token = [responseObject objectForKey:@"refresh_token"];
//        //        NSString * unionid = [responseObject objectForKey:@"unionid"];
//        //        NSString * openid = [responseObject objectForKey:@"openid"];
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        //
//        [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:@"授权失败！"];
//
//    }];
}

//test
-(void)refreshToken
{
//    HXHTTPSessionManager * sessionManager = [HXHTTPSessionManager sharedClient];
//
//    NSString * refreshToken = [[HXLoginManager defaultManager] weixinRefreshToken];
//
//    NSString * url = [NSString stringWithFormat:WeiXin_Refresh_Token,WeiXinAppID,refreshToken];
//
//    [sessionManager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        //
//
//        NSString * access_token= [responseObject objectForKey:@"access_token"];
//
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        //
//
//        [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:@"授权失败！"];
//    }];
}

@end
