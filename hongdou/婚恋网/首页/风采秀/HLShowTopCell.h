//
//  HLShowTopCell.h
//  hongdou
//
//  Created by user on 2022/8/4.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLShowTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeight;

@end

NS_ASSUME_NONNULL_END
