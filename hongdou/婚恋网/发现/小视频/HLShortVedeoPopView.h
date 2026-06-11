//
//  HLShortVedeoPopView.h
//  hongdou
//
//  Created by 李龙 on 2021/12/22.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLShortVedeoPopView : UIView

+(instancetype)initWithXib:(CGRect)frame;

@property (nonatomic, copy) void(^SelectBlock)(void);

@property (nonatomic ,strong) NSString *vid;

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
