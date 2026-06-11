//
//  HLVipBuyController.m
//  hongdou
//
//  Created by 维康1 on 2020/8/20.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLVipBuyController.h"
#import "HXInAppPurchaseTool.h"
#import "myWK.h"

@interface HLVipBuyController ()<HXInAppPurchaseToolDelegate, WKNavigationDelegate> {
    HXInAppPurchaseTool *IAPTool;
}

@property (weak, nonatomic) IBOutlet UILabel *vipPriceLab;

@property (weak, nonatomic) IBOutlet UILabel *messageLab;
@property (weak, nonatomic) IBOutlet myWK *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabHeight;

@end

@implementation HLVipBuyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"缴费钻石会员会费";
    self.sc_navigationBar.titleLabel.textColor = [UIColor whiteColor];
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self createMainView];
    
    // 为什么开钻石会员
    [self descriptionText];
    
    IAPTool = [[HXInAppPurchaseTool alloc] init];
    IAPTool.payMobile = @"SVIP";
    IAPTool.svipPricId = [NSString stringWithFormat:@"%ld",self.vipPriceLab.tag];
    IAPTool.delegate = self;
    
    // 获取钻石会员价格
//    [self requestMemberInfo];
}

- (void)createMainView {
    
    self.webView.layer.masksToBounds = YES;
    self.webView.layer.cornerRadius = 7;
    
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.alwaysBounceVertical = NO;
    self.webView.scrollView.scrollEnabled = NO;
    
    self.webView.navigationDelegate = self;
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    if (!webView.isLoading) {
        
        [webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable any, NSError * _Nullable error) {
            
            NSString *heightStr = [NSString stringWithFormat:@"%@",any];
            NSLog(@"--高度--%@",heightStr);
            
            self.messageLabHeight.constant = [heightStr floatValue];
            
        }];
    }
    
}

// 为什么开钻石会员
- (void)descriptionText {
    
    
    NSDictionary *dic = @{
        @"sign":@"svip"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
//            [MBProgressHUD hideLoading];
            
            
            NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'><style>img{max-width:100%}</style></header>";
            
            [self.webView loadHTMLString:[headerString stringByAppendingString:dictionary[@"data"][@"val"]] baseURL:nil];
            
            
            
        } else {
//            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
//        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

/** 超文本HTML格式转换为富文本AtrributeString格式*/
- (NSMutableAttributedString *)attributeStringByHtmlString:(NSString *)htmlString {
    NSMutableAttributedString *attributeString;
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]
                                   };
    NSError *error = nil;
    attributeString = [[NSMutableAttributedString alloc] initWithData:htmlData options:importParams documentAttributes:NULL error:&error];
    
    
    attributeString.color = [UIColor darkGrayColor];
    attributeString.font = [UIFont systemFontOfSize:14];
    attributeString.lineSpacing = 8;
    
    return attributeString;
}

// 请求当会员价格信息
- (void)requestMemberInfo{
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"type":@"S.iOS"
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLVip_PriceList withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"~~~~: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            
            NSString *productIdString = [dictionary[@"data"][0][@"spid"] stringValue];
            
            [self->IAPTool requestProductsWithProductArray:@[productIdString]];
            
            self.vipPriceLab.tag = [dictionary[@"data"][0][@"id"] intValue];
            
            self.vipPriceLab.text = [NSString stringWithFormat:@"¥%d",[dictionary[@"data"][0][@"money"] intValue]];
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];

}

// 支付
- (IBAction)buyClick:(id)sender {
    
    [MBProgressHUD showLoading];
    
    if (![IAPTool buyProduct:@"S.iOS_11_M"]) {
        [MBProgressHUD showMessage:@"您没有权限购买商品！" view:nil];
    } else {
        
    }
    
}


//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"获取到可购买商品%lu个",(unsigned long)products.count);
    
    if (products.count < 1) {
        [MBProgressHUD showMessage:@"暂无可购买会员产品" view:nil];
    }
    
}

// 支付已被取消
- (void)IAPToolCanceldWithProductID:(NSString *)productID {
    NSLog(@"canceld:%@",productID);
    [MBProgressHUD showMessage:@"购买失败" view:nil];
}

// 支付成功了，并开始上服务器验证收据有效性
- (void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"BeginChecking:%@",productID);
    
}

// 充值成功
- (void)IAPToolCheckSuccessedWithProductID:(NSString *)productID andInfo:(NSString *)info {
    
    NSLog(@"BoughtSuccessed:%@",productID);
    
    [[LoginManager defaultManager] setIsVip:YES];
    
    [MBProgressHUD showSuccess:@"购买成功" toView:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BUY_SUCCESS" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

//服务器验证失败了
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSString *)info {
    NSLog(@"CheckFailed:%@",productID);
    
    [MBProgressHUD showError:info toView:nil];
    
}

//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    NSLog(@"Restored:%@",productID);
    [MBProgressHUD showSuccess:@"成功恢复了商品！" toView:nil];
}

//内购系统错误了
-(void)IAPToolSysWrong {
    [MBProgressHUD showError:@"未连接到itunes store，请稍后再试！" toView:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
