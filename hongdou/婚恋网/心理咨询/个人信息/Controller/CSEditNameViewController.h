//
//  CSEditNameViewController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    NickNamePage, // 昵称
    SchoolPage, // 毕业院校
    MajorPage, // 所学专业
    DiscriPage, // 自我介绍
    AphorismPage, // 职业格言
    WeChatPage, // 微信
    QQPage, // QQ
    PhonePage, // 电话
} PageType;

typedef void(^SureBlock)(void);

@interface CSEditNameViewController : HXBaseViewController

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, assign) PageType pageType;

@property (nonatomic, copy) SureBlock sureBlock;

@end

NS_ASSUME_NONNULL_END
