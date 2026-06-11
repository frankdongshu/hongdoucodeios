//
//  HLWebYanPinController.m
//  hongdou
//
//  Created by 维康1 on 2021/3/16.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLWebYanPinController.h"
#import "HZIAPManager.h"

#import <WebKit/WebKit.h>

@interface HLWebYanPinController ()<WKScriptMessageHandler, WKNavigationDelegate> {
    HZIAPManager *_IAPTool;
}

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation HLWebYanPinController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _IAPTool = [[HZIAPManager alloc] init];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = kISNullObject(self.titleString)?@"更多":self.titleString;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    // 1. 创建 WKWebViewConfiguration
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
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
    [self.view addSubview:self.progressView];
    
    
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

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}


// 4. 处理 H5 调用的方法
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {

}



@end
