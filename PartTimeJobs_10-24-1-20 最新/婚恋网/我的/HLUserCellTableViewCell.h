//
//  HLUserCellTableViewCell.h
//  婚恋网
//
//  Created by iMac on 2019/3/26.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLUserCellTableViewCell : HXBaseTableViewCell

- (void)setCellInfo:(NSString *)imageName withTitle:(NSString *)title withContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
