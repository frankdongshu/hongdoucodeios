//
//  LLPhotoManageCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/24.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LLPhotoManageCellDeleagte <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;
- (void)deleteButtonClickIndexPath:(NSIndexPath *)indexPath;
- (void)colletionButtonClick:(BOOL)isLike;

@end

@interface LLPhotoManageCell : UITableViewCell

@property (nonatomic, strong) UIButton *deleteButton; // 删除按钮
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic,strong) HLAlbumDetails *albumModel;
@property (nonatomic,assign) id <LLPhotoManageCellDeleagte>delegate;

@end

NS_ASSUME_NONNULL_END
