//
//  HLNotifionModel.h
//  hongdou
//
//  Created by iMac on 2019/9/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLNotifionModel : NSObject

@property (nonatomic , assign) BOOL voice;  //声音开关
@property (nonatomic , assign) BOOL shock;  //震动开关
@property (nonatomic , assign) BOOL letter;  //私信提醒
@property (nonatomic , assign) BOOL follow; // 被关注提醒
@property (nonatomic , assign) BOOL likes; // 被赞提醒
@property (nonatomic , assign) BOOL see; // 被阅览提醒

@end

NS_ASSUME_NONNULL_END
