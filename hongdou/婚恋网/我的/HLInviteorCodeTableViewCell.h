//
//  HLInviteorCodeTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^InviteBlock)(void);

@interface HLInviteorCodeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *fuZhiBtn;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *inviteImgV;

@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (nonatomic, copy) InviteBlock inviteBlock;

@end

NS_ASSUME_NONNULL_END
