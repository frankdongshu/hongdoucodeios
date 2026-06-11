//
//  HLTopicCell.h
//  hongdou
//
//  Created by 维康1 on 2020/12/10.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLPhotoModel.h"

#define kMasonryCell @"kMasonryCell"


@protocol HLTopicCellDelegate <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;


/// 跳转发布界面
/// @param huatiString 话题文字
/// @param hId 话题Id
- (void)fabuClick:(NSString *)huatiString andHuaTiId:(NSString *)hId;


/// 删除动态
/// @param uid 用户id
/// @param albumId 动态id
- (void)deleteButtonWithUid:(NSString *)uid andAlbumId:(NSString *)albumId;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLTopicCell : HXBaseTableViewCell

@property (nonatomic,strong) HLAlbumDetails *albumModel;
@property (nonatomic,assign) id <HLTopicCellDelegate>delegate;

@property (nonatomic, strong)NSMutableArray *btnArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic ,weak) UIViewController      *weakSelf;

// 喜欢数
@property (nonatomic ,strong) UILabel *likesLabel;
// 按钮
@property (nonatomic ,strong) UIButton *isLikeButton;

// 主题名称和id及获奖人数
- (void)setTopicString:(NSString *)topicString andTopicId:(NSString *)topicId andWin:(NSInteger)win;

@property (nonatomic, strong) NSString *topicId;


@end

NS_ASSUME_NONNULL_END
