//
//  HXWelcomeView.h
//  hongdou
//
//  Created by 维康1 on 2021/6/16.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXWelcomeView : UIView

@property (nonatomic, copy) void(^SelectBlock)(NSString *sign);

- (void)showSelf;
- (void)removeSelf;

@end

NS_ASSUME_NONNULL_END
