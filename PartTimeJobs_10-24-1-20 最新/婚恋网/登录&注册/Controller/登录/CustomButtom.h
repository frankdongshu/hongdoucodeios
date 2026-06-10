//
//  CustomButtom.h
//  ShuShangShuo
//
//  Created by 这是一个笑脸 on 2019/7/17.
//  Copyright © 2019 lanmao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, ZYGButtonEdgeInsetsStyle) {
    ZYGButtonEdgeInsetsStyleTop, // image在上，label在下
    ZYGButtonEdgeInsetsStyleLeft, // image在左，label在右
    ZYGButtonEdgeInsetsStyleBottom, // image在下，label在上
    ZYGButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface CustomButtom : UIButton
@property (nonatomic, assign) ZYGButtonEdgeInsetsStyle type;
@end

NS_ASSUME_NONNULL_END
