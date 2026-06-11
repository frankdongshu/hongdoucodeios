//
//  HLSoundTagView.h
//  hongdou
//
//  Created by 李龙 on 2021/12/12.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSoundTagView : UIView

- (instancetype)initWithFrame:(CGRect)frame andArr:(NSMutableArray *)arr;

@property (nonatomic, copy) void(^SelectBlock)(NSArray *);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
