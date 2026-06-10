//
//  HLPhotoManageTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/9/26.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLPhotoModel.h"


@protocol HLPhotoManageDeleagte <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;
- (void)deleteButtonClickIndexPath:(NSIndexPath *)indexPath;
- (void)colletionButtonClick:(BOOL)isLike;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLPhotoManageTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet UIButton *collectionButtn;
@property (weak, nonatomic) IBOutlet UILabel *likeNumLable;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, strong)NSMutableArray *btnArray;

@property (nonatomic,assign) id <HLPhotoManageDeleagte>delegate;

@property (nonatomic,strong) HLAlbumDetails *albumModel;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
