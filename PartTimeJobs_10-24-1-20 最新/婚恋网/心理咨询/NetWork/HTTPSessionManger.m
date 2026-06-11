//
//  HTTPSessionManger.m
//  hongdou
//
//  Created by 李龙 on 2020/3/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HTTPSessionManger.h"

@implementation HTTPSessionManger

+ (instancetype)sharedClient {
    
    static HTTPSessionManger *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HTTPSessionManger alloc] init];
        
        _sharedClient.requestSerializer.timeoutInterval = 10;
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
    });
    
    return _sharedClient;
}

+ (void)getDataWithNSString : (NSString *)actionUrlStr
             withDictionary : (NSDictionary *) nsDic
                    success : (void (^)(NSDictionary* dictionary))success
                    failure : (void (^)(NSError *error))failure
{
    
    HTTPSessionManger * client = [HTTPSessionManger sharedClient];
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] initWithDictionary:nsDic];
    
//    www.jiajiao211.net http://39.97.187.95/index.php/mind
    [client GET:[NSString stringWithFormat:@"http://www.jiajiao211.net/index.php/mind%@",actionUrlStr] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
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
    HTTPSessionManger * client = [HTTPSessionManger sharedClient];
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] initWithDictionary:nsDic];
    
    NSLog(@"参数: %@",parameters);
    NSLog(@"接口: %@",actionUrlStr);
//    www.jiajiao211.net  http://39.97.187.95/index.php/mind
    [client POST:[NSString stringWithFormat:@"http://www.jiajiao211.net/index.php/mind%@",actionUrlStr] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (dictionary) {
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            
            if ([code isEqualToString:@"2160"] ||  [code isEqualToString:@"401"]) {
                failure(nil);
                NSLog(@"登录信息已经过期 请重新登录");
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                [[[UIApplication sharedApplication] keyWindow] showErrorWithMessage:@"授权过期，请重新登录！"];
            } else {
                success(dictionary);
            }
            
        } else {
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
    HTTPSessionManger * client = [HTTPSessionManger sharedClient];
    
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
