//
//  LLTeacherCell.h
//  hongdou
//
//  Created by 李龙 on 2020/4/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLTeatherModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FollowType,
    CoachListType,
    CoachDetailType,
    BlackPushType,
} ListType;

typedef void(^AttentionBlock)(NSInteger row, NSInteger status);
typedef void(^ConnectBlock)(NSInteger row, BOOL isConnected);

@interface LLTeacherCell : UITableViewCell

@property (nonatomic, strong) LLTeatherModel *infoModel;
@property (nonatomic, assign) ListType type;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy) AttentionBlock attentionBlock;
@property (nonatomic, copy) ConnectBlock connectBlock;

@end

NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@interface CSCoachMajorView : UIView
@property (nonatomic, copy) NSString *titleString;
@end

NS_ASSUME_NONNULL_END
