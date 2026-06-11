//
//  HLYanPinListCell.h
//  hongdou
//
//  Created by 维康1 on 2021/3/16.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLPhotoModel.h"

#define kMasonryCell @"kMasonryCell"


@protocol HLYanPinListCellDelegate <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;

- (void)colletionButtonClick;

- (void)webViewControllerWithUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLYanPinListCell : HXBaseTableViewCell

@property (nonatomic,strong) HLAlbumDetails *albumModel;
@property (nonatomic,assign) id <HLYanPinListCellDelegate>delegate;

@property (nonatomic, strong)NSMutableArray *btnArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic ,weak) UIViewController *weakSelf;


// 按钮
@property (nonatomic ,strong) UIButton *isLikeButton;

@end

NS_ASSUME_NONNULL_END
