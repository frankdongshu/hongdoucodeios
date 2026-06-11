//
//  HLAlertOpenVipView.h
//  hongdou
//
//  Created by 维康1 on 2020/8/24.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLAlertOpenVipView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMessage:(NSString *)message;

@property (nonatomic, copy) void(^SelectBlock)(void);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
