//
//  HLResultTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/30.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

@protocol HLResultDelegate <NSObject>

- (void)dropdownButtonClick;

- (void)followButtonClick;

- (void)chartButtonClick:(NSIndexPath *_Nullable)indexPath;


@end

NS_ASSUME_NONNULL_BEGIN

@interface HLResultTableViewCell : HXBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nicknameLable;
@property (weak, nonatomic) IBOutlet UILabel *ageLable;
@property (weak, nonatomic) IBOutlet UILabel *constellaLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLable;
@property (weak, nonatomic) IBOutlet UILabel *occupationLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;

@property (weak, nonatomic) IBOutlet UIButton *dropdownButton;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;

@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@property (weak, nonatomic) IBOutlet UIView *photosView;
@property (weak, nonatomic) IBOutlet UIImageView *picOneImageView;

@property (weak, nonatomic) IBOutlet UIImageView *picSecondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *picThridImageView;

@property (weak, nonatomic) IBOutlet UIButton *chartButton;
@property (weak, nonatomic) IBOutlet UIButton *isLikeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;
@property (weak, nonatomic) IBOutlet UIImageView *crownImgV;

@property (nonatomic,assign) id <HLResultDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) HLUser *model;

@property(nonatomic ,weak) UIViewController      *weakSelf;
@property (nonatomic, strong) NSMutableArray *picArray;

@end

NS_ASSUME_NONNULL_END
