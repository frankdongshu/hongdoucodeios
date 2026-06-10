//
//  CSDetailContactCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSDetailContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weChatLab;
@property (weak, nonatomic) IBOutlet UILabel *phoneLab;
@property (weak, nonatomic) IBOutlet UILabel *qqLab;

@property (weak, nonatomic) IBOutlet UIView *wxView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *qqView;


@end

NS_ASSUME_NONNULL_END
