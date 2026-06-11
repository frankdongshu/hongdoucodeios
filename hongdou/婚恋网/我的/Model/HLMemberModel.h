//
//  HLMemberModel.h
//  hongdou
//
//  Created by iMac on 2019/11/1.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLMemberModel : NSObject

@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *title; //会员套餐名称
@property (nonatomic, copy) NSString *payId;  //内购购买的产品ID
@property (nonatomic, copy) NSString *timevar; //会员套餐时间
@property (nonatomic, copy) NSString *price;  //会员套餐实际价格
@property (nonatomic, copy) NSString *money;  //会员套餐支付价格
@property (nonatomic, copy) NSString *type; //iOS  Android 平台区分
@property (nonatomic, copy) NSString *discount; //会员套餐折扣
@property (nonatomic, copy) NSString *face; // 赠送颜值骇客次数
@property (nonatomic, copy) NSString *spid; // 用于内购产品id
@property (nonatomic, copy) NSString *ProductId; // 用于内购产品id
@property (nonatomic, copy) NSString *ProductType; 
@end

NS_ASSUME_NONNULL_END
