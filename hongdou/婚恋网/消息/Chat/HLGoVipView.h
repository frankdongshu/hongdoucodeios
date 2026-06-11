//
//  HLGoVipView.h
//  hongdou
//
//  Created by user on 2022/4/15.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLGoVipView : UIView

@property (nonatomic, copy) void(^SelectBlock)(void);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
