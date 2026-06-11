//
//  HLCommunityCell.h
//  hongdou
//
//  Created by user on 2022/3/15.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLCommunityCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labHeight;

@end

NS_ASSUME_NONNULL_END
