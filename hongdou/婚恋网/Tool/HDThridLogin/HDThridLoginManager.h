//
//  HDThridLoginManager.h
//  婚恋网
//
//  Created by iMac on 2019/4/3.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDThridLoginManager : NSObject

+ (instancetype)sharedManager;

- (void)openQQWithNumber:(BOOL)isNumber;

// 是不是提现界面需要绑定微信
- (void)openWeixinWithBind:(BOOL)isBind isNumber:(BOOL)isNumber;


@end

NS_ASSUME_NONNULL_END
