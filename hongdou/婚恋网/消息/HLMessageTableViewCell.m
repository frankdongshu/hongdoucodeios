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

- (void)setSocketCellDataWithLastMessage:(NSDictionary *)dic {
    
    // 是否置顶
    NSString *topString = [NSString stringWithFormat:@"%@",dic[@"type"]];
    
    if ([topString isEqualToString:@"1"]) {
        self.contentView.backgroundColor = kRGBA(235, 235, 236, 1);
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    
    self.lastMessageLabel.text = dic[@"text"];
    
    self.userNamelabel.text = kISNullObject(dic[@"cname"])?@"未知用户":dic[@"cname"];
    
    if (!kISNullObject(dic[@"chead"])) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:dic[@"chead"]] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    }
    
    self.timeLabel.text = [JCHATStringUtils getFriendlyDateString:[dic[@"time"] doubleValue] forConversation:YES];
    
    
    if (kISNullObject(dic[@"unread"])) {
        return;
    }
    
    NSString *unread = [NSString stringWithFormat:@"%@",dic[@"unread"]];
    
    // 未读数
    if ([unread isEqualToString:@"0"]) {
        [self.messageNumberLabel setHidden:YES];
    } else {
        [self.messageNumberLabel setHidden:NO];
        self.messageNumberLabel.text = unread;
    }
    
}

- (void)setCellDataWithLastMessage:(NSDictionary *)dic unReadArr:(NSMutableArray *)unReadArray{
    
    NSString *str = dic[@"lastMessage"][@"payload"];
    
    NSData *sData = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:sData options:NSJSONReadingMutableLeaves error:nil];
    
    NSData *tData = [[NSData alloc]initWithBase64EncodedString:responseJSON[@"payload"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *dataString = [[NSString alloc]initWithData:tData encoding:NSUTF8StringEncoding];
    
    self.lastMessageLabel.text = dataString;
    
    
    if ([responseJSON[@"head"] isEqualToString:[LoginManager defaultManager].avatar]) {
        
        self.userNamelabel.text = responseJSON[@"fromNickname"];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:responseJSON[@"fromHead"]] placeholderImage:[UIImage imageNamed:@"icon_head"]];
        
        
    } else {
        
        self.userNamelabel.text = responseJSON[@"nickname"];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:responseJSON[@"head"]] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    }
    
    
    self.timeLabel.text = [JCHATStringUtils getFriendlyDateString:[dic[@"timestamp"] doubleValue] forConversation:YES];
    
    
    
    // 未读数
    if (unReadArray.count == 0) {
        [self.messageNumberLabel setHidden:YES];
    } else {
        
        for (NSDictionary *unReadDic in unReadArray) {
            
            if ([unReadDic[@"username"] isEqualToString:dic[@"name"]]) {
                [self.messageNumberLabel setHidden:NO];
                self.messageNumberLabel.text = [NSString stringWithFormat:@"%@",unReadDic[@"c"]];
                
                return;
                
            } else {
                [self.messageNumberLabel setHidden:YES];
                
            }
            
        }
    }
    
    
    
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
