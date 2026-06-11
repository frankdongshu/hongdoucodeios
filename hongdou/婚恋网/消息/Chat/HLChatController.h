//
//  HLChatController.h
//  hongdou
//
//  Created by 维康1 on 2021/7/29.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLChatController : HXBaseViewController

@property (nonatomic, strong) NSString *statusString; // 连接状态

@property (strong, nonatomic) NSDictionary *chatDic;


// 判断是否从会话列表进来, 默认0: 不是, 1: 是
@property (assign, nonatomic) BOOL isList;


@end

NS_ASSUME_NONNULL_END
