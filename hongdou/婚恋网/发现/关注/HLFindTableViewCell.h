//
//  HLFindTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLPhotoModel.h"

@protocol HLFindDelegate <NSObject>

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike;

- (void)colletionButtonClick;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLFindTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contenLable;
@property (weak, nonatomic) IBOutlet UIView *picBackGroudView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UIButton *isLikeButton;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;
@property (weak, nonatomic) IBOutlet UIImageView *crownImgV;

@property (nonatomic,strong) HLAlbumDetails *albumModel;
@property (nonatomic,assign) id <HLFindDelegate>delegate;

@property (nonatomic, strong)NSMutableArray *btnArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) CGFloat cellHight;

@end

NS_ASSUME_NONNULL_END
