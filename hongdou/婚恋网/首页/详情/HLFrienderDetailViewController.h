//
//  HLFrienderDetailViewController.h
//  hongdou
//
//  Created by iMac on 2019/10/16.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN
//其他定义
typedef void(^RefreshBlock)(void);
// 拉黑等移除类操作
typedef void(^RemoveBlock)(void);

typedef enum : NSUInteger {
    NormalType,
    DianZanType,
} DetailType;

@interface HLFrienderDetailViewController : HXBaseViewController

@property (nonatomic, assign) DetailType detailType;

@property (nonatomic, copy) RefreshBlock refreshBlock;
@property (nonatomic, copy) RemoveBlock removeBlock;

@property (nonatomic, strong) NSIndexPath *idx;


@property (nonatomic, strong) HLUser *userInfo;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *nickName; // 广场进来用, 后台做的不一致

@property (nonatomic, assign) BOOL isChatting; // 是否是聊天进入的

@end

NS_ASSUME_NONNULL_END
