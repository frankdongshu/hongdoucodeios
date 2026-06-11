//
//  HLSettingPopView.h
//  hongdou
//
//  Created by 维康1 on 2020/9/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLSettingPopView : UIView

@property (nonatomic, copy) void(^SelectBlock)(void);

@property (nonatomic, strong) NSDictionary *dataDic;

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
