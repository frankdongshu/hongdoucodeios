//
//  VirtualLoverCell.h
//  hongdou
//
//  Created by xk work's computer on 2025/3/28.
//  Copyright © 2025 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VirtualLoverModel.h"

NS_ASSUME_NONNULL_BEGIN

//typedef enum : NSUInteger {
//    FollowType,
//    CoachListType,
//    CoachDetailType,
//    BlackPushType,
//} ListType;
//
//typedef void(^AttentionBlock)(NSInteger row, NSInteger status);
//typedef void(^ConnectBlock)(NSInteger row, BOOL isConnected);

@interface VirtualLoverCell : UITableViewCell


@property (nonatomic, strong) UIImageView *sexImageView;

//@property (nonatomic, strong) VirtualLoverModel *virtualLoverModel;
//@property (nonatomic, assign) ListType type;
//@property (nonatomic, assign) NSInteger row;
//@property (nonatomic, copy) AttentionBlock attentionBlock;
//@property (nonatomic, copy) ConnectBlock connectBlock;

@end

NS_ASSUME_NONNULL_END
