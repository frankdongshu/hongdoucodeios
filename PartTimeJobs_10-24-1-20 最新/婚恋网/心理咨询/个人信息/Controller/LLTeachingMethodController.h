//
//  LLTeachingMethodController.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DefaultType,
    FaBuType,
} TeaType;

typedef void(^SureBlock)(void);
typedef void(^FaBuBlock)(NSString *teaching);

@interface LLTeachingMethodController : HXBaseViewController

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSArray *listArray;

@property (nonatomic, copy) SureBlock sureBlock;
@property (nonatomic, copy) FaBuBlock teachingBlock;

@property (nonatomic, assign) TeaType teaType;

@end

NS_ASSUME_NONNULL_END
