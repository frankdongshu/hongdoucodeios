//
//  HLHTTPSessionManager.m
//  婚恋网
//
//  Created by iMac on 2019/4/8.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLHTTPSessionManager.h"

@implementation HLHTTPSessionManager

+ (instancetype)sharedClient {
    
    static HLHTTPSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HLHTTPSessionManager alloc] init];
        
        _sharedClient.requestSerializer.timeoutInterval = 20;
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
    });
    
    return _sharedClient;
}

+ (void)getDataWithNSString : (NSString *)actionUrlStr
             withDictionary : (NSDictionary *) nsDic
                    success : (void (^)(NSDictionary* dictionary))success
                    failure : (void (^)(NSError *error))failure
{
    
    HLHTTPSessionManager * client = [HLHTTPSessionManager sharedClient];
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] initWithDictionary:nsDic];
    
        NSString * token = [[LoginManager defaultManager] token];
        if (token.length > 0) {
            [parameters setObject:token forKey:@"token"];
        }
    [client GET:[NSString stringWithFormat:@"%@%@",BaseUrl,actionUrlStr] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if(dictionary)
        {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];

            if ([code isEqualToString:@"2160"] ||  [code isEqualToString:@"401"]) {
                failure(nil);
                NSLog(@"登录信息已经过期 请重新登录");
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:@"授权过期，请重新登录！"];
            }else
            {
                success(dictionary);
            }
        }else
        {
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *) nsDic
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure
{
    HLHTTPSessionManager * client = [HLHTTPSessionManager sharedClient];
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] initWithDictionary:nsDic];
    
        
    NSString * token = [[LoginManager defaultManager] token];
    
    if (token.length > 0) {
        [parameters setObject:token forKey:@"token"];
    }
    
    
    
//    if (kISNullString(parameters[@"uid"])&&
//        ![actionUrlStr isEqualToString:HLTuijian_friends]&&
//        ![actionUrlStr isEqualToString:HLLOGIN]&&
//        ![actionUrlStr isEqualToString:HLREGISTER]&&
//        ![actionUrlStr isEqualToString:HLEdit_UserEVPI]&&
//        ![actionUrlStr isEqualToString:HLThird_QQLOGIN]&&
//        ![actionUrlStr isEqualToString:HLThird_WXLOGIN]&&
//        ![actionUrlStr isEqualToString:HLUser_Detailed]&&
//        ![actionUrlStr isEqualToString:HLVip_PriceList]&&
//        ![actionUrlStr isEqualToString:HLNotice]&&
//        ![actionUrlStr isEqualToString:HLSyntax_list]&&
//        ![actionUrlStr isEqualToString:HLPiccomplaint_list]&&
//        ![actionUrlStr isEqualToString:HLComplaint_List]&&
//        ![actionUrlStr isEqualToString:HLAlbum_Square]&&
//        ![actionUrlStr isEqualToString:HLBINDIN_PHONE]&&
//        ![actionUrlStr isEqualToString:@"/user/newIndex"]) {
//        
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
//    }
    
    NSLog(@"参数: %@",parameters);
    NSLog(@"接口: %@",actionUrlStr);
    
    
    [client POST:[NSString stringWithFormat:@"%@%@",BaseUrl,actionUrlStr] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if(dictionary)
        {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            
            if ([code isEqualToString:@"2160"] ||  [code isEqualToString:@"401"]) {
                failure(nil);
                NSLog(@"登录信息已经过期 请重新登录");
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                
            }else
            {
                success(dictionary);
            }
        }else
        {
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        failure(error);
    }];
}

+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *) nsDic
    constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure
{
    HLHTTPSessionManager * client = [HLHTTPSessionManager sharedClient];
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] initWithDictionary:nsDic];
    
    NSString * token = [[LoginManager defaultManager] token];
    
    if (token.length > 0) {
        [parameters setObject:token forKey:@"token"];
    }
    
    [client POST:[NSString stringWithFormat:@"%@%@",BaseUrl,actionUrlStr] parameters:parameters constructingBodyWithBlock:block success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if(dictionary)
        {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            
            if ([code isEqualToString:@"2160"] ||  [code isEqualToString:@"401"]) {
                failure(nil);
                NSLog(@"登录信息已经过期 请重新登录");
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:@"授权过期，请重新登录！"];
            }else
            {
                success(dictionary);
            }
        }else
        {
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
        failure(error);
    }];
}
@end
