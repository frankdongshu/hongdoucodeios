//
//  HLRealHeadCell.h
//  hongdou
//
//  Created by 维康1 on 2021/8/26.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLRealHeadCellDelegate <NSObject>

///分享回调
- (void)shareVipClickWithPicArr:(NSArray *)picArray;

///聊天回调
- (void)chatVipClickWithUserName:(HLUser *)user;

///关注回调
- (void)followVipClickWithFollowBtn:(UIButton *)sender andUser:(HLUser *)u;

///跳转详情
- (void)detailVipClickWithUser:(HLUser *)u;

@end

@interface HLRealHeadCell : UITableViewCell

@property (nonatomic, assign) id<HLRealHeadCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *listenLab;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgView;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property (weak, nonatomic) IBOutlet UILabel *xingZuoLab;
@property (weak, nonatomic) IBOutlet UILabel *xueLiLab;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic, strong) HLUser *u;

@end

NS_ASSUME_NONNULL_END
