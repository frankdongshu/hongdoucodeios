//
//  HXSettingView.h
//  hongdou
//
//  Created by 维康1 on 2020/10/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXSettingView : UIView


// 是否只看同城
@property (nonatomic, assign) BOOL isSwichOn;

@property (nonatomic, copy) void(^SelectBlock)(BOOL isSelect);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
