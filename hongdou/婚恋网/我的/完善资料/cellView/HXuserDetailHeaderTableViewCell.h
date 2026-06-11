//
//  HXuserDetailHeaderTableViewCell.h
//  婚恋网
//
//  Created by iMac on 2019/3/29.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^AlterHeadBlock)(void);


@interface HXuserDetailHeaderTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property(nonatomic, copy) AlterHeadBlock alterHeadBlock;
@end

NS_ASSUME_NONNULL_END
