//
//  HLOpenVVipView.h
//  hongdou
//
//  Created by 维康1 on 2020/8/20.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLVVipViewDelegate <NSObject>

// 手机认证
- (void)shoujirenzheng;
// 本人头像认证
- (void)benrentouxiang;
// 身份认证
- (void)shenfenzheng;
// 学历认证
- (void)xulirenzheng;
// 下一步
- (void)nextPushClick;

@end

@interface HLOpenVVipView : UIView
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) id<HLVVipViewDelegate>delegate;
+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLVVipViewDelegate>)delegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSDictionary *authDic;

@end

NS_ASSUME_NONNULL_END
