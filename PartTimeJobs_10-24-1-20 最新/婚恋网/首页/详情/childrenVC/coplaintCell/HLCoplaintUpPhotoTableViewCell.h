//
//  HLCoplaintUpPhotoTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/22.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ReturnPicsArrayBlock)(NSArray *picArray);

@interface HLCoplaintUpPhotoTableViewCell : HXBaseTableViewCell

@property(nonatomic ,weak) UIViewController      *weakSelf;
@property (nonatomic, copy) ReturnPicsArrayBlock picsBlock;

@end

NS_ASSUME_NONNULL_END
