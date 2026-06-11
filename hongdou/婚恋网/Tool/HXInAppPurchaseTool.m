//
//  HXInAppPurchaseTool.m
//  ebase
//
//  Created by iMac on 2018/1/20.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXInAppPurchaseTool.h"
#import "HXIAPProducts.h"
// 购买会员
#define HXIAP_CERTIFICATE @"/index.php/api/translate/member"  //服务器验证凭据  receipt-base64String
//用户是否与我畅聊
#define HLOpen_Chatting @"/index.php/api/friends/chatting"

#ifdef EPLATFORM_SERVICE
#define IAPCheckURL @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define IAPCheckURL @"https://buy.itunes.apple.com/verifyReceipt"
#endif

@interface HXInAppPurchaseTool ()<SKPaymentTransactionObserver,SKProductsRequestDelegate,SKRequestDelegate>
{
    SKProductsRequest *request;
}
/**
 *  商品字典
 */
@property(nonatomic,strong)NSMutableDictionary *productDict;

@end

@implementation HXInAppPurchaseTool

#pragma mark  初始化

-(instancetype)init
{
    if (self = [super init]) {
        // 设置购买队列的监听器
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc
{
    request.delegate = nil;
    [request cancel];
    request = nil;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark 询问苹果的服务器能够销售哪些商品
/**
 *  询问苹果的服务器能够销售哪些商品
 */
- (void)requestProductsWithProductArray:(NSArray *)products
{
    NSLog(@"开始请求可销售商品");
    
    // 能够销售的商品
    NSSet *set = [[NSSet alloc] initWithArray:products];
    
    // "异步"询问苹果能否销售
    request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    
    request.delegate = self;
    
    // 启动请求
    [request start];
}

#pragma mark 获取询问结果，成功采取操作把商品加入可售商品字典里
/**
 *  获取询问结果，成功采取操作把商品加入可售商品字典里
 *
 *  @param request  请求内容
 *  @param response 返回的结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (self.productDict == nil) {
        self.productDict = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
    }
    
    NSMutableArray *productArray = [NSMutableArray array];
    
    for (SKProduct *product in response.products) {
        NSLog(@"%@", product.productIdentifier);
        
        // 填充商品字典
        [self.productDict setObject:product forKey:product.productIdentifier];
        
        [productArray addObject:product];
    }
    
    //按照价格升序排序
    [productArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SKProduct *product1 = obj1;
        SKProduct *product2 = obj2;
        return product1.price.intValue > product2.price.intValue;
    }];
    
    //通知代理
    [self.delegate IAPToolGotProducts:productArray];
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"===============请求结束===============");
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"请求失败：%@",error.localizedDescription);
    [self.delegate IAPToolSysWrong];
}

#pragma mark - 用户决定购买商品
/**
 用户决定购买商品

 @param productID 商品ID
 @return 允许程序内付费购买 返回 YES
 */
- (BOOL)buyProduct:(NSString *)productID
{
    // 是否允许内购
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProduct *product = self.productDict[productID];
        
        // 要购买产品(店员给用户开了个小票)
        SKMutablePayment * payment = [SKMutablePayment paymentWithProduct:product];
        payment.applicationUsername = APP_NAME;
        payment.productIdentifier = productID;
        
        // 去收银台排队，准备购买(异步网络)
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
        return YES;
    }
    else {
        NSLog(@"用户不允许内购");
        
        return NO;
    }
}

#pragma mark - SKPaymentTransaction Observer
#pragma mark 购买队列状态变化,,判断购买状态是否成功
/**
 *  监测购买队列的变化
 *
 *  @param queue        队列
 *  @param transactions 交易
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    // 处理结果
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"队列状态变化 %@", transaction);
        
        // 如果小票状态是购买完成
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
            NSLog(@"交易完成");
            
            //通知代理
            [self.delegate IAPToolBeginCheckingdWithProductID:transaction.payment.productIdentifier];
            
            // 验证购买凭据
            if (self.payMobile.length>0 && ![self.payMobile isEqualToString:@"SVIP"]) {
                [self verifyChattingPruchaseWithTransaction:transaction];
            } else if ([self.payMobile isEqualToString:@"SVIP"]) {
                [self verifySVipPruchaseWithTransaction:transaction];
            } else{
                
                if (self.isYanPinVip) { // 颜品vip
                    [self verifyYanPinPruchaseWithTransaction:transaction];
                } else {
                    [self verifyPruchaseWithTransaction:transaction];
                }
                
            }
            
        }
        else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
            NSLog(@"已经购买过商品");
            //NSLog(@"恢复成功 :%@", transaction.payment.productIdentifier);
            // 通知代理
            [self.delegate IAPToolRestoredProductID:transaction.payment.productIdentifier];
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        else if (SKPaymentTransactionStateFailed == transaction.transactionState){
            NSLog(@"交易失败");
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            //NSLog(@"交易失败");
            [self.delegate IAPToolCanceldWithProductID:transaction.payment.productIdentifier];
            
        }
        else if (SKPaymentTransactionStatePurchasing == transaction.transactionState){
            NSLog(@"商品添加进列表");
            
        }
        else if (SKPaymentTransactionStateDeferred == transaction.transactionState){
            NSLog(@"最终状态未确定");
            
        }
        
    }
}
// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads
{
    
}

// Sent when a user initiates an IAP buy from the App Store
- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product
{
    return YES;
}

#pragma mark - 恢复商品
/**
 *  恢复商品
 */
- (void)restorePurchase
{
    // 恢复已经完成的所有交易.（仅限永久有效商品）
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark 验证交易凭据，并充值
/**
 *  验证VIP会员交易凭据，充值
 *
 *  @param transaction 交易
 */
- (void)verifyPruchaseWithTransaction:(SKPaymentTransaction *)transaction
{
    NSString * productID = transaction.payment.productIdentifier;
    
    // 验证凭据，获取到苹果返回的交易凭据
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];  //iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    if (receiptData == nil) {
        //收据丢失,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"收据无效，请稍后重试！"];
        return;
    }
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDictionary *parameters = @{
        @"uid":[LoginManager defaultManager].userid,
        @"token":[LoginManager defaultManager].token,
        @"pay":@"ios",
        @"spid":productID,
        @"receipt":encodeStr
    };
    
    
//    [MBProgressHUD showLoading];
    
    AFHTTPSessionManager * client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    client.requestSerializer.timeoutInterval = 30;
//    client.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [client POST:HXIAP_CERTIFICATE parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull dic) {
        
//        [MBProgressHUD hideLoading];
        
        NSString *code = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.delegate IAPToolCheckSuccessedWithProductID:productID andInfo:@"购买成功！"];
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }else{
            //验证失败,通知代理
            [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"验证失败，请稍后重试！"];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error: %@",error);
        
        //
        //验证失败,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"网络错误，请稍后重试！"];
    }];
}

/**
 *  验证畅聊交易凭据，充值
 *
 *  @param transaction 交易
 */
 - (void)verifyChattingPruchaseWithTransaction:(SKPaymentTransaction *)transaction
{
    NSString * productID = transaction.payment.productIdentifier;
    
    // 验证凭据，获取到苹果返回的交易凭据
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];  //iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    if (receiptData == nil) {
        //收据丢失,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"收据无效，请稍后重试！"];
        return;
    }
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDictionary * parameters = @{
        @"receipt":encodeStr,
        @"uid":[LoginManager defaultManager].userid,
        @"pay":@"ios",
        @"mobile":self.payMobile,
        @"token":[LoginManager defaultManager].token
    };
    

    
    AFHTTPSessionManager * client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    client.requestSerializer.timeoutInterval = 30;
    
    [client POST:HLOpen_Chatting parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull dic) {
        //
        
        NSString *code = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.delegate IAPToolCheckSuccessedWithProductID:productID andInfo:@"购买成功！"];
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }else{
            //验证失败,通知代理
            [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"验证失败，请稍后重试！"];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
        //验证失败,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"网络错误，请稍后重试！"];
    }];
}


/**
*  验证SVIP交易凭据，充值
*
*  @param transaction 交易
*/

 - (void)verifySVipPruchaseWithTransaction:(SKPaymentTransaction *)transaction
{
    NSString * productID = transaction.payment.productIdentifier;
    
    // 验证凭据，获取到苹果返回的交易凭据
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];  //iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    if (receiptData == nil) {
        //收据丢失,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"收据无效，请稍后重试！"];
        return;
    }
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDictionary * parameters = @{
        @"uid":[LoginManager defaultManager].userid,
        @"token":[LoginManager defaultManager].token,
        @"pay":@"ios",
        @"spid":productID,
        @"receipt":encodeStr
    };
    
    
    AFHTTPSessionManager * client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    client.requestSerializer.timeoutInterval = 30;
    
    [client POST:@"/index.php/api/Svip/member" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull dic) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.delegate IAPToolCheckSuccessedWithProductID:productID andInfo:@"购买成功！"];
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }else{
            //验证失败,通知代理
            [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"验证失败，请稍后重试！"];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
        //验证失败,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"网络错误，请稍后重试！"];
    }];
}

/**
 *  验证颜品vip交易凭据，充值
 *
 *  @param transaction 交易
 */
 - (void)verifyYanPinPruchaseWithTransaction:(SKPaymentTransaction *)transaction
{
    NSString * productID = transaction.payment.productIdentifier;
    
    // 验证凭据，获取到苹果返回的交易凭据
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];  //iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    if (receiptData == nil) {
        //收据丢失,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"收据无效，请稍后重试！"];
        return;
    }
    
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDictionary * parameters = @{
        @"uid":[LoginManager defaultManager].userid,
        @"token":[LoginManager defaultManager].token,
        @"spid":productID,
        @"pay":@"ios",
        @"receipt":encodeStr
    };
    
    HDLog(@"%@",parameters);
    
    AFHTTPSessionManager * client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
    client.requestSerializer.timeoutInterval = 30;
    
    [client POST:@"/index.php/api/translate/abvip" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull dic) {
        //
        
        NSLog(@"^^^: %@",dic);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.delegate IAPToolCheckSuccessedWithProductID:productID andInfo:@"购买成功！"];
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }else{
            //验证失败,通知代理
            [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"验证失败，请稍后重试！"];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
        
        NSLog(@"~~~: %@",error.localizedDescription);
        
        //验证失败,通知代理
        [self.delegate IAPToolCheckFailedWithProductID:productID andInfo:@"网络错误，请稍后重试！"];
    }];
}
                
@end
