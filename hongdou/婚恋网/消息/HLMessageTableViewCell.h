//
//  HLMessageTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLMessageTableViewCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageNumberLabel;
- (void)setCellDataWithConversation:(JMSGConversation *)conversation;


- (void)setCellDataWithLastMessage:(NSDictionary *)dic unReadArr:(NSMutableArray *)unReadArray;


- (void)setSocketCellDataWithLastMessage:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
