//
//  HLPhoneNumberLoginVC.h
//  hongdou
//
//  Created by 李龙 on 2021/5/6.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLPhoneNumberLoginVC : UIViewController

// 没有拿到手机号, 需要添加导航高度
@property (nonatomic, assign) BOOL isPhoneNum;

@end

NS_ASSUME_NONNULL_END
