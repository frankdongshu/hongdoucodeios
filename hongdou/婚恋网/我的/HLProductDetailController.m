//
//  HLProductDetailController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLProductDetailController.h"
#import "HLShoppingInfoView.h"
#import <WebKit/WebKit.h>

@interface HLProductDetailController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *chatBtn;
@property (nonatomic, strong) UILabel *myPriceLab;
@property (nonatomic, strong) HLUser *userInfo;

@end

@implementation HLProductDetailController

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0 , kNavBarHeight , kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight)];
        
        NSString *str = @"1、欢迎新豆豆加入红豆佳缘，欢迎您使用红豆佳缘，希望您在这里早日找到幸福<br/>\n2、红豆佳缘是一款高端正规的婚恋交友软件，鼓励上传真实头像及信息现在上传本人头像并通过真实认证，可获得永久VIP.<a href=\"paraches://?id=rzym\">现在去认证</a><br/>\n3、现在购买年VIP（18元/年）买一年赠一年。<a href=\"paraches://?id=gmym\">现在去购买</a>";
        
        
        [_webView loadHTMLString:[self reSizeImageWithHTML:str] baseURL:nil];
        
    }
    return _webView;
}

- (NSString *)reSizeImageWithHTML:(NSString *)html {
    return [NSString stringWithFormat:@"<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'><meta name='apple-mobile-web-app-capable' content='yes'><meta name='apple-mobile-web-app-status-bar-style' content='black'><meta name='format-detection' content='telephone=no'><style type='text/css'>img{width:%fpx}</style>%@", kScreenWidth - 20, html];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"商品详情";
    
    [self.view addSubview:self.webView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kTabBarHeight, kScreenWidth, kTabBarHeight)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    
    self.bottomView.layer.masksToBounds = NO;
    self.bottomView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.bottomView.layer.shadowOffset = CGSizeMake(0,0);
    self.bottomView.layer.shadowOpacity = 0.5;
    self.bottomView.layer.shadowRadius = 5;
    // 单边阴影 顶边
    float shadowPathWidth = self.bottomView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, self.bottomView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    self.bottomView.layer.shadowPath = path.CGPath;
    [self.view addSubview:self.bottomView];
    
    [self settingBottomViewWithFrame];
    
    
    // 请求当前用户的信息(获取账号余额)
    [self requestCurrentUserInfo];
    
}

// 底部视图
- (void)settingBottomViewWithFrame {
    
    UILabel *productPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.frame.size.width-120, self.bottomView.frame.size.height/2)];
    productPriceLab.font = kScaleFont(12);
    productPriceLab.textColor = [UIColor redColor];
    productPriceLab.text = [NSString stringWithFormat:@"    ¥%@",self.model.price];
    
    [self.bottomView addSubview:productPriceLab];
    
    self.myPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(productPriceLab.frame), self.bottomView.frame.size.width-120, self.bottomView.frame.size.height/2)];
    self.myPriceLab.font = kScaleFont(12);
    self.myPriceLab.textColor = [UIColor darkGrayColor];
    
    [self.bottomView addSubview:self.myPriceLab];
    
    
    self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomView.frame.size.width-120, 0, 120, self.bottomView.frame.size.height)];
    [self.chatBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995FF8],[UIColor colorWithHex:0x5D57ED]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    [self.chatBtn setTitle:@"立即兑换" forState:UIControlStateNormal];
    [self.chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.chatBtn addTarget:self action:@selector(shoppingProductClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.chatBtn];
    
}

- (void)shoppingProductClick {
    
    NSLog(@"可用余额: %@",self.userInfo.balance);
    NSLog(@"产品价格: %@",self.model.price);
    
    if ([self.userInfo.balance floatValue] < [self.model.price floatValue]) {
        
        [self.view showTostWithMessage:@"您的可用余额不足!"];
        
    } else {
        
        HLShoppingInfoView *popView = [[HLShoppingInfoView alloc] initWithParamDic:^(NSDictionary *parmas) {
            
            [self requsetExchangeListWithParmas:parmas];
            
        }];
        
        [popView show];
    }
    
}


// 提交兑换产品请求
- (void)requsetExchangeListWithParmas:(NSDictionary *)dic {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pid":self.model.productId,
        @"consignee":dic[@"name"],
        @"tel":dic[@"phone"],
        @"address":dic[@"add"]
    };
    
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLExchange_Shopping withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            // 请求当前用户的信息(获取账号余额)
            [self requestCurrentUserInfo];
        }
        
        [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 请求当前用户的信息
- (void)requestCurrentUserInfo{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLGET_UserINFO withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.userInfo = [HLUser mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            
            self.myPriceLab.text = [NSString stringWithFormat:@"    可用余额: %@",weakSelf.userInfo.balance];
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"获取账号余额失败"];
    }];
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
