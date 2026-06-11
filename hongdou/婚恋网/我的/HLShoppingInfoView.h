//
//  HLShoppingInfoView.h
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLShoppingInfoView : UIView

/**
 初始化
 */
- (instancetype)initWithParamDic:(void(^)(NSDictionary *))dic;

/**
 显示
 */
- (void)show;

/**
 隐藏
 */
- (void)hide;

/**
 输入框确定之后的block回调
 */
@property (nonatomic, copy) void(^textFieldTextBlock)(NSDictionary *dic);

@end

NS_ASSUME_NONNULL_END
