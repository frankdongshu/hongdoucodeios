//
//  HLRecordModel.h
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLRecordModel : NSObject

@property (nonatomic, strong) NSString *recordId; // id
@property (nonatomic, strong) NSString *time; // 下单时间
@property (nonatomic, strong) NSString *consignee; // 收货人
@property (nonatomic, strong) NSString *tel; // 联系电话
@property (nonatomic, strong) NSString *address; // 收货地址
@property (nonatomic, strong) NSString *pic; // 产品图片
@property (nonatomic, strong) NSString *title; // 产品名称
@property (nonatomic, strong) NSString *state; // 订单状态

@end

NS_ASSUME_NONNULL_END
