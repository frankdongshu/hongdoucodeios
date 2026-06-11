//
//  HLMoreQingRenView.h
//  hongdou
//
//  Created by 李龙 on 2020/7/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface HLMoreQingRenView : UIView

- (instancetype)initWithFrame:(CGRect)frame andArray:(NSArray *)array;

@property (nonatomic, copy) void(^SelectBlock)(NSString *);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
