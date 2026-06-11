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
- (void)openQQWithNumber:(BOOL)isNumber {
    
    [ShareSDK authorize:SSDKPlatformTypeQQ settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:
                [self tencentDidLoginWithAccessToken:user.credential.rawData[@"access_token"] OpenId:user.credential.rawData[@"openid"] andIsNum:isNumber];
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
- (void)openWeixinWithBind:(BOOL)isBind isNumber:(BOOL)isNumber {
    
    [ShareSDK authorize:SSDKPlatformTypeWechat settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        
        switch (state) {
            case SSDKResponseStateSuccess:

                if (!isBind) {
                    [self weixinDidLoginWithAccessToken:user.credential.rawData[@"access_token"] OpenId:user.credential.rawData[@"openid"] RefreshToken:user.credential.rawData[@"refresh_token"] isNumber:isNumber];
                } else {
                    [self requestBindWeChatId:user.credential.rawData[@"openid"]];
                }
                
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

- (void)tencentDidLoginWithAccessToken:(NSString *)access_token OpenId:(NSString *)openid andIsNum:(BOOL)isNumber {
    
    [HLHTTPSessionManager postDataWithNSString:HLThird_QQLOGIN withDictionary:@{@"openid":openid,@"access_token":access_token} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"QQ登录: %@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            //保存最后登录的手机号
            [[LoginManager defaultManager] setAccount:[dictionary[@"data"][@"data"] objectForKey:@"username"]];
            [[LoginManager defaultManager] setPassword:[dictionary[@"data"][@"data"] objectForKey:@"password"]]; // 密码
            [[LoginManager defaultManager] setUserid:[dictionary[@"data"][@"data"] objectForKey:@"id"]];
            [[LoginManager defaultManager] setWxOpenId:[dictionary[@"data"][@"data"] objectForKey:@"WXid"]]; // openid
            //保存最后登录的用户昵称
            [[LoginManager defaultManager] setNickName:[dictionary[@"data"][@"data"] objectForKey:@"nickname"]];
            [[LoginManager defaultManager] setGender:[dictionary[@"data"][@"data"] objectForKey:@"gender"]];
            [[LoginManager defaultManager] setToken:[dictionary[@"data"][@"data"] objectForKey:@"token"]];
            [[LoginManager defaultManager] setAvatar:[dictionary[@"data"][@"data"] objectForKey:@"head"]];
            
            [[LoginManager defaultManager] setBirthday:dictionary[@"data"][@"data"][@"birthday"]]; // 生日
            [[LoginManager defaultManager] setHabitation:dictionary[@"data"][@"data"][@"habitation"]]; // 所在地
            
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]];
            
            if (kISNullObject(dictionary[@"data"][@"data"][@"member"]) || ![self checkProductDate:dictionary[@"data"][@"data"][@"member"]]) {
                [[LoginManager defaultManager] setIsVip:NO];
            } else {
                [[LoginManager defaultManager] setIsVip:YES];
            }
            
            // 获取咨询师信息
            [self requestData];
            
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {

                    NSLog(@"qq添加别名成功");

                }

            } seq:0];
            
            if (![[dictionary[@"data"] objectForKey:@"type"] boolValue]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginNeedBindPhoneNoti object:@{@"type":[dictionary[@"data"] objectForKey:@"in"],@"openid":openid}];
                
            }else{
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isWanShan" object:[NSNumber numberWithBool:isNumber]];
                
            }
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];

}

#pragma mark - WXApiDelegate

- (void)weixinDidLoginWithAccessToken:(NSString *)access_token OpenId:(NSString *)openid RefreshToken:(NSString *)refresh_token isNumber:(BOOL)isNumber {
    
    [HLHTTPSessionManager postDataWithNSString:HLThird_WXLOGIN withDictionary:@{@"openid":openid,@"access_token":access_token} success:^(NSDictionary * _Nonnull dictionary) {
        
        HDLog(@"微信登录: %@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) { // 登陆成功
            
            [[LoginManager defaultManager] setUserid:[dictionary[@"data"][@"data"] objectForKey:@"id"]]; // userid
            [[LoginManager defaultManager] setToken:[dictionary[@"data"][@"data"] objectForKey:@"token"]]; // token
            [[LoginManager defaultManager] setWxOpenId:[dictionary[@"data"][@"data"] objectForKey:@"WXid"]]; // 微信openid
            
            [[LoginManager defaultManager] setAccount:[dictionary[@"data"][@"data"] objectForKey:@"username"]]; // 手机号
            [[LoginManager defaultManager] setPassword:[dictionary[@"data"][@"data"] objectForKey:@"password"]]; // 密码
            
            [[LoginManager defaultManager] setNickName:[dictionary[@"data"][@"data"] objectForKey:@"nickname"]]; // 昵称
            [[LoginManager defaultManager] setGender:[dictionary[@"data"][@"data"] objectForKey:@"gender"]]; // 性别
            [[LoginManager defaultManager] setAvatar:[dictionary[@"data"][@"data"] objectForKey:@"head"]];
            
            [[LoginManager defaultManager] setBirthday:dictionary[@"data"][@"data"][@"birthday"]]; // 生日
            [[LoginManager defaultManager] setHabitation:dictionary[@"data"][@"data"][@"habitation"]]; // 所在地
            
            // 头像
            [[LoginManager defaultManager] setBalance:[dictionary[@"data"][@"data"] objectForKey:@"balance"]]; // 余额
            
            
            if (kISNullObject(dictionary[@"data"][@"data"][@"member"]) || ![self checkProductDate:dictionary[@"data"][@"data"][@"member"]]) {
                [[LoginManager defaultManager] setIsVip:NO];
            } else {
                [[LoginManager defaultManager] setIsVip:YES];
            }
            
            // 获取咨询师信息
            [self requestData];
            
            [JPUSHService setAlias:[LoginManager defaultManager].account completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                NSLog(@"%@",iAlias);

                if (iResCode == 0) {

                    NSLog(@"vx添加别名成功");

                }

            } seq:0];
            
            if (![[dictionary[@"data"] objectForKey:@"type"] boolValue]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LoginNeedBindPhoneNoti object:@{@"type":[dictionary[@"data"] objectForKey:@"in"],@"openid":openid}];
                
            } else {
                //保存是否需要自动登录
                [[LoginManager defaultManager] setIsLogin:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isWanShan" object:[NSNumber numberWithBool:isNumber]];
                
            }
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

// 获取用户信息
- (void)requestData {
    
    if (kISNullObject([LoginManager defaultManager].userid)) {
        return;
    }
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/show" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/show: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            
            MyLogin *u = [MyLogin mj_objectWithKeyValues:dictionary[@"data"]];
            
            u.descr = dictionary[@"data"][@"description"]; // 因关键字冲突, 单独赋值
            u.sex = dictionary[@"data"][@"gender"];
            
            NSData *uData = [NSKeyedArchiver archivedDataWithRootObject:u];
            
            [[NSUserDefaults standardUserDefaults] setObject:uData forKey:Login_USER];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // 获取已选课程
            [self requestSelect];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}

// 获取已选课程
- (void)requestSelect {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/get_coach_curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/get_coach_curriculum: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in dictionary[@"data"]) {
                for (NSDictionary *dic1 in dic[@"lists"]) {
                    [arr addObject:dic1[@"id"]];
                }
            }
            u.curriculum = arr; // 咨询类型, 取id
            
            [MyLogin updateUser:u];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 与当前时间比较是否过期
- (BOOL)checkProductDate: (NSString *)tempDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:tempDate];
    
    // 判断是否大于当前时间
    if ([date earlierDate:[NSDate date]] != date) {
        
        return NO;
    } else {
        
        return YES;
    }
    
}

// 绑定微信
- (void)requestBindWeChatId:(NSString *)wxid {
    
    NSDictionary *params = @{
        @"mobile":[LoginManager defaultManager].account,
        @"sms":@"0524",
        @"openid":wxid,
        @"in":@"wechat"
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLBINDIN_PHONE withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"绑定微信: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"] ) {
            
            [MBProgressHUD showSuccess:@"绑定成功" toView:nil];
            
            // 设置openid
            [[LoginManager defaultManager] setWxOpenId:[dictionary[@"data"] objectForKey:@"WXid"]];
            
            // 刷新token
            [[LoginManager defaultManager] setToken:[dictionary[@"data"] objectForKey:@"token"]];
            

        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
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
