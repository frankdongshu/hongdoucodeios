//
//  ChooseCityController.h
//  hongdou
//
//  Created by 李龙 on 2020/3/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChooseCityController : UIViewController

@property (nonatomic, copy) void (^block)(NSString *city);
@property (nonatomic, strong) NSMutableArray *seleArray;

@end

NS_ASSUME_NONNULL_END
