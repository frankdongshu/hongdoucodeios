//
//  HLPhotoTopTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^PublicPhotoBlock)();

@interface HLPhotoTopTableViewCell : HXBaseTableViewCell

@property (nonatomic, copy) PublicPhotoBlock publicPhotoBlock;


@end

NS_ASSUME_NONNULL_END
