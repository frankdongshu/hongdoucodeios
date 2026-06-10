//
//  AptitudeView.h
//  hongdou
//
//  Created by 李龙 on 2020/3/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SureBlock)(void);

@interface AptitudeView : UIView

@property (nonatomic, copy) SureBlock sureBlock;

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
