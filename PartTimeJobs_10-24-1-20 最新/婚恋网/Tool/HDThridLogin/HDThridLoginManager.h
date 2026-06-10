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

- (void)openQQ;

- (void)openWeixin;


@end

NS_ASSUME_NONNULL_END
