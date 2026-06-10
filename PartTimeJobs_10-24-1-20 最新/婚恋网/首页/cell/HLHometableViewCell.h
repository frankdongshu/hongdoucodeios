//
//  HLHometableViewCell.h
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"


@protocol HLHomeDelegate <NSObject>

- (void)closeButtonClick:(NSIndexPath *_Nullable)indexPath;

- (void)followButtonClick;

- (void)chartButtonClick:(NSIndexPath *_Nullable)indexPath;

- (void)browerPhotoClick:(NSArray *)picArrs withCurrentIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLHometableViewCell : HXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nicknameLable;
@property (weak, nonatomic) IBOutlet UILabel *ageLable;
@property (weak, nonatomic) IBOutlet UILabel *constellaLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLable;
@property (weak, nonatomic) IBOutlet UILabel *occupationLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIImageView *VIPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet UIView *photosView;


@property (weak, nonatomic) IBOutlet UIButton *chartButton;
@property (weak, nonatomic) IBOutlet UIButton *isLikeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;
@property (weak, nonatomic) IBOutlet UIImageView *crownImgV;

@property (nonatomic,assign) id <HLHomeDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) HLUser *model;

@property(nonatomic ,weak) UIViewController      *weakSelf;

@property (nonatomic, strong)NSMutableArray *imgArray;

@end

NS_ASSUME_NONNULL_END
