//
//  HXChooseController.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXChooseController : HXBaseViewController

@property (nonatomic, copy) void (^block)(NSString *cid);
@property (nonatomic, strong) NSMutableArray *seleArray;

@end

NS_ASSUME_NONNULL_END
