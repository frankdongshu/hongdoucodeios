//
//  LLSelectKeMuController.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLSelectKeMuController : HXBaseViewController

@property (nonatomic, copy) void (^block)(NSString *city);
@property (nonatomic, strong) NSMutableArray *seleArray;

@end

NS_ASSUME_NONNULL_END
