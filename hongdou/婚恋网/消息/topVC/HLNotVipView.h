//
//  HLNotVipView.h
//  hongdou
//
//  Created by user on 2022/4/14.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLNotVipView : UIView

- (instancetype)initWithFrame:(CGRect)frame andDataArray:(NSMutableArray *)array andTitle:(NSString *)title;

@property (nonatomic, copy) void(^SelectBlock)(HLNotVipView *);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
