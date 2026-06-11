//
//  HLAuthOhterPhoto.h
//  hongdou
//
//  Created by 维康1 on 2020/6/18.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLAuthOhterPhoto : HXBaseViewController

@property (nonatomic, strong) NSString *typeString;

@property (nonatomic, copy) void (^block)(void);

@end

NS_ASSUME_NONNULL_END
