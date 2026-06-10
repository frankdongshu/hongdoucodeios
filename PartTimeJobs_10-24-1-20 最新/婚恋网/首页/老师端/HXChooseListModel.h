//
//  HXChooseListModel.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/27.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXChooseListModel : NSObject

@property (nonatomic, assign) NSInteger cid; // id
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, assign) NSInteger cou; // 数量

@end

NS_ASSUME_NONNULL_END
