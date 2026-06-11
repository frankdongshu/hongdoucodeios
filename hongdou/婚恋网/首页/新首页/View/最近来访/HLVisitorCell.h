//
//  HLVisitorCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLVisitorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) NSDictionary *dic;

@end

NS_ASSUME_NONNULL_END
