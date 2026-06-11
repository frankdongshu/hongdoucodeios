//
//  HLNewVipModel.h
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLNewVipModel : NSObject

@property (nonatomic, strong) NSArray *vipArr;

@end

@interface HLNewVipPerModel : NSObject

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *age;

@end

NS_ASSUME_NONNULL_END
