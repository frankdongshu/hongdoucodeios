//
//  HXInAppPurchaseTool.h
//  ebase
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#pragma mark --------HXInAppPurchaseToolDelegate--内购代理
/**
 *  内购工具的代理
 */
@protocol HXInAppPurchaseToolDelegate <NSObject>

/**
 *  代理：系统错误
 */
-(void)IAPToolSysWrong;

/**
 *  代理：已刷新可购买商品
 *
 *  @param products 商品数组
 */
-(void)IAPToolGotProducts:(NSMutableArray *)products;

/**
 *  代理：取消购买
 *
 *  @param productID 商品ID
 */
-(void)IAPToolCanceldWithProductID:(NSString *)productID;

/**
 *  代理：购买成功，开始验证购买
 *
 *  @param productID 商品ID
 */
-(void)IAPToolBeginCheckingdWithProductID:(NSString *)productID;

/**
 *  代理：服务器校验成功，并充值完毕
 *
 *  @param productID 购买成功的商品ID
 */
-(void)IAPToolCheckSuccessedWithProductID:(NSString *)productID
                                  andInfo:(NSString *)info;

/**
 *  代理：服务器验证失败
 *
 *  @param productID 商品ID
 */
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSString *)info;

/**
 *  恢复了已购买的商品（永久性商品）
 *
 *  @param productID 商品ID
 */
-(void)IAPToolRestoredProductID:(NSString *)productID;

@end

#pragma mark --------HXInAppPurchaseTool--内购工具
/**
 *  内购工具
 */
@interface HXInAppPurchaseTool : NSObject

typedef void(^BoolBlock)(BOOL successed,BOOL result);

typedef void(^DicBlock)(BOOL successed,NSDictionary *result);


@property (nonatomic, strong) NSString *payMobile; // 跟畅聊用户的手机号
@property (nonatomic, strong) NSString *svipPricId; // svip价格id
@property (nonatomic, assign) BOOL isYanPinVip; // 颜品vip标识

/**
 *  代理
 */
@property(nonatomic,weak) id <HXInAppPurchaseToolDelegate> delegate;

/**
 *  询问苹果的服务器能够销售哪些商品
 *
 *  @param products 商品ID的数组
 */
- (void)requestProductsWithProductArray:(NSArray *)products;

/**
 用户决定购买会员商品
 
 @param productID 商品ID
 @return 允许程序内付费购买 返回 YES
 */
- (BOOL)buyProduct:(NSString *)productID;


/**
 *  恢复商品（仅限永久有效商品）
 */
- (void)restorePurchase;

@end
