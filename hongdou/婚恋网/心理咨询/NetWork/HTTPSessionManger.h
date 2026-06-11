//
//  HTTPSessionManger.h
//  hongdou
//
//  Created by 李龙 on 2020/3/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "AFHTTPSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPSessionManger : AFHTTPSessionManager

/**
 @return VKHTTPSessionManager
 */
+ (instancetype)sharedClient;

/**
 普通GET请求
 */
+ (void)getDataWithNSString : (NSString *)actionUrlStr
             withDictionary : (NSDictionary *) nsDic
                    success : (void (^)(NSDictionary* dictionary))success
                    failure : (void (^)(NSError *error))failure;

/**
 普通POST请求
 */
+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *) nsDic
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure;



//上传附件
+ (void)postDataWithNSString : (NSString *)actionUrlStr
              withDictionary : (NSDictionary *) nsDic
    constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                     success : (void (^)(NSDictionary* dictionary))success
                     failure : (void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
