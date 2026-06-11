//
//  HLExchangeModel.h
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLExchangeModel : NSObject

@property (nonatomic, strong) NSString *productId; // id
@property (nonatomic, strong) NSString *pic; // 图片
@property (nonatomic, strong) NSString *price; // 价格
@property (nonatomic, strong) NSString *title; // 标题
@property (nonatomic, strong) NSString *introduce; // 产品简介

@end

NS_ASSUME_NONNULL_END
