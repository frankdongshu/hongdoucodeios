//
//  HLDreamLoverDesView.h
//  hongdou
//
//  Created by 李龙 on 2020/7/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLDreamLoverDesView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMessage:(NSString *)message;

@property (nonatomic, copy) void(^SelectBlock)(void);
@property (nonatomic, copy) void(^CloseBlock)(void);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
