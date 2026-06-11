//
//  HLPreviewPhotoViewController.h
//  hongdou
//
//  Created by iMac on 2019/9/27.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"
#import "HLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLPreviewPhotoViewController : HXBaseViewController

@property (nonatomic, strong) NSIndexPath *scrollIndexPath;

@property (nonatomic, strong) HLAlbumDetails *albumModel;

@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, strong) NSString *isTag;

@end

NS_ASSUME_NONNULL_END
