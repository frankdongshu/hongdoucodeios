//
//  MultipleImgCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/10.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WriteRead, // 可操作(默认)
    OnlyShow, // 只展示
} PicType;

@interface MultipleImgCell : UITableViewCell

@property (nonatomic, copy) void (^block)(UIViewController *);
@property (nonatomic, assign) PicType picType;
@property (nonatomic, strong) NSArray *pictures;

@end

NS_ASSUME_NONNULL_END
