//
//  HLWebNoNavigationController.m
//  hongdou
//
//  Created by xk work's computer on 2025/5/13.
//  Copyright © 2025 红豆-婚恋网. All rights reserved.
//

#import "HLWebNoNavigationController.h"
#import "HZIAPManager.h"

#import <WebKit/WebKit.h>
static NSString * const KcallApplePayToBuy = @"callApplePayToBuy";

@interface HLWebNoNavigationController ()<WKScriptMessageHandler, WKNavigationDelegate> {
    HZIAPManager *_IAPTool;
}

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;


@end

@implementation HLWebNoNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _IAPTool = [[HZIAPManager alloc] init];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    // 1. 创建 WKWebViewConfiguration
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    // 2. 注册 JS 调用的 Native 方法
    [config.userContentController addScriptMessageHandler:self name:KcallApplePayToBuy];
    // 添加 JS 调用 OC 的接口（桥接方法）
    //    [config.userContentController addScriptMessageHandler:self name:@"callNative"];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    
    NSLog(@"url: %@",self.url);
    
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    NSURL *url = [NSURL fileURLWithPath:htmlPath];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    
        [self.webView loadRequest:request];
    
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
//    [self.view addSubview:self.progressView];
//
    @weakify(self);
    HXBarButtonItem *leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self callJavaScriptHandleLeaveRoom];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    if (leftBarButtonItem) {
        leftBarButtonItem.view.x = 0;
        leftBarButtonItem.view.centerY = kStatusBarHeight+22;
        [self.view addSubview:leftBarButtonItem.view];
    }
    
    [self.view addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(leftBarButtonItem.view);
        make.left.equalTo(leftBarButtonItem.view.mas_left).offset(41);
    }];
    self.titleLab.text = self.titleString;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sc_setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self sc_setNavigationBarHidden:NO animated:NO];
}



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        self.progressView.progress = self.webView.estimatedProgress;
        // 加载完成
        if (self.webView.estimatedProgress  >= 1.0f ) {
            
            [UIView animateWithDuration:0.25f animations:^{
                self.progressView.alpha = 0.0f;
                self.progressView.progress = 0.0f;
            }];
            
        }else{
            self.progressView.alpha = 1.0f;
        }
    }
}



#pragma mark- XXXXXXXXXXXXXXX懒加载部分XXXXXXXXXXXXXXXXXXXX
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _webView.scrollView.contentInset = UIEdgeInsetsZero;
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, 2);
        //        _progressView.tintColor = [UIColor blueColor]; // 动态颜色
        //        _progressView.trackTintColor = [UIColor magentaColor]; // 背景颜色
    }
    return _progressView;
}


- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    }
    return _titleLab;
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:KcallApplePayToBuy];
}


// 4. 处理 H5 调用的方法
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:KcallApplePayToBuy]) {
        NSDictionary *params = message.body;
        NSLog(@"H5 传递的数据: %@", params);
        [self didSelectBuyButtonWithProductID:params[@"productId"] agentId:params[@"agentid"]];
    }
}

- (void)callJavaScriptFunction {
    NSString *jsCode = @"refreshPage()";
    
    // 在主线程执行 JS
    [self.webView evaluateJavaScript:jsCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"调用 JS 失败: %@", error.localizedDescription);
        } else {
            NSLog(@"成功调用 JS，返回值: %@", result);
        }
    }];
}

- (void)callJavaScriptHandleLeaveRoom {
    NSString *jsCode = @"handleLeaveRoom()";
    
    // 在主线程执行 JS
    [self.webView evaluateJavaScript:jsCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"调用 JS 失败: %@", error.localizedDescription);
        } else {
            NSLog(@"成功调用 JS，返回值: %@", result);
        }
    }];
}





- (void)didSelectBuyButtonWithProductID:(NSString *)productID agentId:(NSString *)agentId {
    
    NSLog(@"%@",productID);
    
    [self.view showLoading];
    
    [_IAPTool startIAPWithProductID:productID  agentId:agentId andUrl:@"agent/addRemainingTime" completeHandle:^(IAPResultType type, NSData * _Nonnull data) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (type) {
                case IAPResultSuccess:
                    [self.view showSuccessWithMessage:@"购买成功"];
                    break;
                case IAPResultFailed:
                    [self.view showErrorWithMessage:@"购买失败"];
                    break;
                case IAPResultCancle:
                    [self.view showErrorWithMessage:@"取消购买"];
                    break;
                case IAPResultVerFailed:
                    [self.view showErrorWithMessage:@"订单校验失败"];
                    break;
                case IAPResultVerSuccess:
                    [self.view showSuccessWithMessage:@"订单校验成功"];
                    break;
                case IAPResultNotArrow:
                    [self.view showErrorWithMessage:@"不允许程序内付费"];
                    break;
                default:
                    break;
            }
            [self callJavaScriptFunction];
            
            
        });
    }];
    
}


@end
