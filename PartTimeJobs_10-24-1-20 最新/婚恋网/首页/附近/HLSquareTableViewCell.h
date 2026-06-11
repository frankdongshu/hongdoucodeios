//
//  HLSquareTableViewCell.h
//  婚恋网
//
//  Created by iMac on 2019/6/28.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

#import "HLUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSquareTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nicknameLable;
@property (weak, nonatomic) IBOutlet UILabel *ageLable;
@property (weak, nonatomic) IBOutlet UILabel *constellaLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLable;
@property (weak, nonatomic) IBOutlet UILabel *occupationLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabe;

@property (weak, nonatomic) IBOutlet UIImageView *VIPImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;
@property (weak, nonatomic) IBOutlet UIImageView *crownImgV;

- (void)setUserInfo:(HLUser *)model;

@end

NS_ASSUME_NONNULL_END
