//
//  HDPreviewPhotoController.h
//  hongdou
//
//  Created by 维康1 on 2019/12/9.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"
#import "HLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDPreviewPhotoController : HXBaseViewController

@property (nonatomic, strong) NSIndexPath *scrollIndexPath;

@property (nonatomic, strong) HLAlbumDetails *albumModel;

@property (nonatomic, strong) NSArray *picArray;
@property (nonatomic, assign) NSInteger selectIdx;

@end

NS_ASSUME_NONNULL_END
