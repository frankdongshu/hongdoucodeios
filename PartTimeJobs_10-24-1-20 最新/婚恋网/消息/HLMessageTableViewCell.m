//
//  HLMessageTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLMessageTableViewCell.h"
#import "JCHATStringUtils.h"
#import "JCHATSendMsgManager.h"
@implementation HLMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellDataWithConversation:(JMSGConversation *)conversation{
    
    if ([[conversation getExtraValueForKey:@"ext"] isEqualToString:@"1"]) {
        self.backgroundColor = kRGBA(235, 235, 236, 1);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    
    
    self.userNamelabel.text = conversation.title;
    // 获取头像
    [conversation avatarData:^(NSData *data, NSString *objectId, NSError *error) {
        if (error == nil && data != nil) {
            self.headImageView.image = [UIImage imageWithData:data];
        }else{
            self.headImageView.image = [UIImage imageNamed:@"icon_head"];
        }
    }];
    
    
    // 最新收到信息时间
    if (conversation.latestMessage.timestamp != nil ) {
        double time = [conversation.latestMessage.timestamp doubleValue];
        self.timeLabel.text = [JCHATStringUtils getFriendlyDateString:time forConversation:YES];
    } else {
        self.timeLabel.text = @"";
    }
    // 最后一条信息
    if ([[[JCHATSendMsgManager ins] draftStringWithConversation:conversation] isEqualToString:@""]) {
        self.lastMessageLabel.text = conversation.latestMessageContentText;
    }
    
    // 未读数
    if ([conversation.unreadCount integerValue] > 0) {
        [self.messageNumberLabel setHidden:NO];
        self.messageNumberLabel.text = [NSString stringWithFormat:@"%@", conversation.unreadCount];
    } else {
        [self.messageNumberLabel setHidden:YES];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
