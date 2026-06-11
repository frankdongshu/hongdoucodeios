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
- (void)deleteButtonClickIndexPath:(NSIndexPath *)indexPath andMessage:(NSString *)message;
- (void)colletionButtonClick:(BOOL)isLike;

- (void)linkButtonClickWithTag:(NSInteger)senderTag oldUrl:(NSString *)oldUrl;

@end

@interface LLPhotoManageCell : UITableViewCell

@property (nonatomic, strong) UIButton *deleteButton; // 删除按钮
@property (nonatomic, strong) UIButton *shuaButton, *linkBtn; // 刷新按钮/设置链接按钮
@property (nonatomic, strong) UILabel *zwLab; // 占位
@property (nonatomic, strong) UILabel *dateTimeLab; // 倒计时
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic,strong) HLAlbumDetails *albumModel;
@property (nonatomic,assign) id <LLPhotoManageCellDeleagte>delegate;


@property (nonatomic, assign) BOOL isYanPin;

@end

NS_ASSUME_NONNULL_END
