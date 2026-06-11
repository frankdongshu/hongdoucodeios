//
//  HXChooseModel.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/27.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXChooseListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXChooseModel : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSMutableArray <HXChooseListModel*> *data;

@end

NS_ASSUME_NONNULL_END
