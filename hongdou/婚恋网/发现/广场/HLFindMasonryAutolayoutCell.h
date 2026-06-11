//
//  HLFindMasonryAutolayoutCell.h
//  hongdou
//
//  Created by iMac on 2019/10/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLPhotoModel.h"

#define kMasonryCell @"kMasonryCell"


@protocol HLFindMasonryAutolayoutDelegate <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;

- (void)colletionButtonClick;

@end


NS_ASSUME_NONNULL_BEGIN

@interface HLFindMasonryAutolayoutCell : HXBaseTableViewCell

@property (nonatomic,strong) HLAlbumDetails *albumModel;
@property (nonatomic,assign) id <HLFindMasonryAutolayoutDelegate>delegate;

@property (nonatomic, strong)NSMutableArray *btnArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic ,weak) UIViewController *weakSelf;

// 按钮
@property (nonatomic ,strong) UIButton *isLikeButton;

@end

NS_ASSUME_NONNULL_END
