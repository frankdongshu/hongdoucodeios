//
//  HLPlayPopView.h
//  hongdou
//
//  Created by 李龙 on 2020/7/6.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface HLPlayPopView : UIView

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSString *)title;

@property (nonatomic, copy) void(^SelectBlock)(NSString *);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
