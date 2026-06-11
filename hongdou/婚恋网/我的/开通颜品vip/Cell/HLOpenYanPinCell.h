//
//  HLOpenYanPinCell.h
//  hongdou
//
//  Created by 维康1 on 2021/3/11.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLOpenYanPinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeight;

@end

NS_ASSUME_NONNULL_END
