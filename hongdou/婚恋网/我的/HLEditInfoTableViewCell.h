//
//  HLEditInfoTableViewCell.h
//  婚恋网
//
//  Created by iMac on 2019/5/15.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLEditInfoTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *nextImageView;
@property (weak, nonatomic) IBOutlet UIImageView *redImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

- (void)setTitleLableText:(NSString *)title withHLUserInfo:(HLUser *)userModel withCurrentIndex:(NSIndexPath *)indexPath;

- (void)setBaseinfoText:(NSString *)title withHLUserInfo:(HLUser *)userModel withCurrentIndex:(NSIndexPath *)indexPath;

- (void)setFriendTitleLableText:(NSString *)title withHLUserInfo:(HLFriendModel *)frindModel withCurrentIndex:(NSIndexPath *)indexPath;

- (void)setTitleLableText:(NSString *)title withContent:(NSString *)conetent;

@end

NS_ASSUME_NONNULL_END
