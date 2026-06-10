//
//  LLBuyVipModel.h
//  hongdou
//
//  Created by 李龙 on 2020/3/17.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLBuyVipModel : NSObject

@property (nonatomic, copy) NSString *vipId;
@property (nonatomic, copy) NSString *day;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, copy) NSString *type; // 苹果产品ID

@end

NS_ASSUME_NONNULL_END
