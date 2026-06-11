//
//  HLInviteAwardTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLInvitationModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^ShareBlock)(void);

@interface HLInviteAwardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *inviteView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneysLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UIImageView *imgV1;
@property (weak, nonatomic) IBOutlet UIImageView *imgV2;
@property (weak, nonatomic) IBOutlet UIImageView *imgV3;
@property (weak, nonatomic) IBOutlet UIImageView *imgV4;
@property (weak, nonatomic) IBOutlet UIImageView *imgV5;

@property (nonatomic, strong) HLInvitationModel *inviteModel;
@property (nonatomic, copy) ShareBlock shareBlock;

@end

NS_ASSUME_NONNULL_END
