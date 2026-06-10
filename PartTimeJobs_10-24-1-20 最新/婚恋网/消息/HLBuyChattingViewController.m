//
//  HLBuyChattingViewController.m
//  hongdou
//
//  Created by iMac on 2019/11/4.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLBuyChattingViewController.h"
#import "HXInAppPurchaseTool.h"
#import "HXIAPProducts.h"
@interface HLBuyChattingViewController ()<HXInAppPurchaseToolDelegate>
{
    HXInAppPurchaseTool * IAPTool;
}
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation HLBuyChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
//        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:234/255.f green:234/255.f blue:234/255.f alpha:1.0];
    
    self.sc_navigationBar.title = @"订单支付";
    self.sc_navigationBar.titleLabel.textColor = [UIColor whiteColor];;
    self.dataSource = [NSMutableArray array];

    [self initSubViews];
    IAPTool = [[HXInAppPurchaseTool alloc] init];
    IAPTool.payMobile = self.userName;
    IAPTool.delegate = self;
    [self requestMemberInfo];
}

- (void)initSubViews{
    
    [self.topView az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xBD64FF],[UIColor colorWithHex:0x825CF4]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    _contentView.layer.shadowOffset =CGSizeMake(0,1);

    self.contentLabel.text = [NSString stringWithFormat:@"开通与%@的畅聊",self.nickName];
    
    self.payButton.backgroundColor = [UIColor lightGrayColor];
//    [self.payButton az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xBD64FF],[UIColor colorWithHex:0x825CF4]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    self.payButton.userInteractionEnabled = NO;

    
}

// 请求畅聊价格信息
- (void)requestMemberInfo{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view showLoading];
    });
    
    
    [IAPTool requestProductsWithProductArray:IAP_Products_Arr];
}

#pragma mark - 内购按钮点击
- (IBAction)payChattingClick:(id)sender {
    
    if (self.dataSource.count==0) {
        [self.view showErrorWithMessage:@"暂时无法购买此商品！"];

        return;
    }
    
    SKProduct *product = self.dataSource.firstObject;

    
    NSLog(@"内购按钮点击 产品ID：%@",product.productIdentifier);
    [self.view showLoading];
    BOOL success = [IAPTool buyProduct:product.productIdentifier];
    
    if (!success) {
        [self.view showErrorWithMessage:@"您没有权限购买商品！"];
    }
}

//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"获取到可购买商品%lu个",(unsigned long)products.count);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view hideLoading];
        
        self.dataSource = products;
        //设置空白页
        if (products.count==0) {
            self.priceLabel.text = @"￥0";
            [self.view showErrorWithMessage:@"获取畅聊价格失败，请稍后再试！" hideAfter:3.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            self.priceLabel.text = @"￥1";
            [self.payButton az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xBD64FF],[UIColor colorWithHex:0x825CF4]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
            self.payButton.userInteractionEnabled = YES;
        }
        
    });
    

    
    
    
}

//支付已被取消
-(void)IAPToolCanceldWithProductID:(NSString *)productID {
    NSLog(@"canceld:%@",productID);
    [self.view showErrorWithMessage:@"旅客购买未成功"];
}

//支付成功了，并开始上服务器验证收据有效性
-(void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"BeginChecking:%@",productID);
    [self.view showLoadingWithMessage:@"支付成功，正在购买……"];
}

//充值成功
-(void)IAPToolCheckSuccessedWithProductID:(NSString *)productID
                                  andInfo:(NSString *)info {
    NSLog(@"BoughtSuccessed:%@",productID);
    
    [self.view showSuccessWithMessage:@"购买成功！" hideAfter:3];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openChatiing" object:nil];
        }];
    });
}

//服务器验证失败了
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSString *)info {
    NSLog(@"CheckFailed:%@",productID);
    [self.view showErrorWithMessage:info hideAfter:5];
    
}

//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    [self.view showSuccessWithMessage:@"成功恢复了商品！"];
}

//内购系统错误了
-(void)IAPToolSysWrong {
    [self.view showErrorWithMessage:@"未连接到itunes store，请稍后再试！" hideAfter:3.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
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
