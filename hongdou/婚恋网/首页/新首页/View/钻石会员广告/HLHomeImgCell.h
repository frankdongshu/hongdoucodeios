//
//  HLHomeImgCell.h
//  hongdou
//
//  Created by 维康1 on 2021/9/9.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLHomeImgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@end

NS_ASSUME_NONNULL_END
