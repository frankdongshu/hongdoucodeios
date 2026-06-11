//
//  LLActivityModel.h
//  hongdou
//
//  Created by 李龙 on 2020/3/18.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLFutureModel.h"
#import "LLBeingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLActivityModel : NSObject

@property (nonatomic, strong) LLBeingModel *being;
@property (nonatomic, strong) NSMutableArray <LLFutureModel*> *future;


@end

NS_ASSUME_NONNULL_END
