//
//  ZPHMessageTableViewCellLayoutVoice.m
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import "ZPHMessageTableViewCellLayoutVoice.h"

@implementation ZPHMessageTableViewCellLayoutVoice

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self = [super init]) {
        
        ZPHMessage *messageModel = [ZPHMessage messageWithDic:dictionary];
        
        if ([[NSString stringWithFormat:@"%@",messageModel.uid] isEqualToString:[LoginManager defaultManager].userid]) {
            [self setRightLayoutWithModel:messageModel];
        }else {
            [self setLeftLayoutWithModel:messageModel];
        }
    }
    
    return self;
}

//左
-(void)setLeftLayoutWithModel:(ZPHMessage *)model {
    
    [super setLeftLayoutWithModel:model];
    
    NSRange range = [model.text rangeOfString:@"#"];
    
    NSString *okStr;
    
    if (range.location != NSNotFound) {
        okStr = [model.text substringFromIndex:range.location+1];
    } else {
        // Not Found
        okStr = model.text;
    }
    
    NSInteger voiceWidth = [self setupVoiceSize:[NSNumber numberWithString:okStr]];
    
    self.contentFrame = CGRectMake(CGRectGetMaxX(self.headPictureFrame) +20, CGRectGetMidY(self.headPictureFrame) -10, voiceWidth, 17.9);
    
    //背景
    self.messageBackViewFrame = CGRectMake(CGRectGetMinX(self.contentFrame) -18, CGRectGetMinY(self.contentFrame) -12, self.contentFrame.size.width +35, self.contentFrame.size.height +35);
    
    if (self.messageBackViewFrame.size.height >self.headPictureFrame.size.height) {
        self.rowHeight = CGRectGetMaxY(self.messageBackViewFrame);
    }
    
}

//右
-(void)setRightLayoutWithModel:(ZPHMessage *)model {
    
    [super setRightLayoutWithModel:model];

    NSRange range = [model.text rangeOfString:@"#"];
    
    NSString *ok = [model.text substringFromIndex:range.location+1];
    
    NSInteger voiceWidth = [self setupVoiceSize:[NSNumber numberWithString:ok]];
    
    self.contentFrame = CGRectMake(kScreenWidth - self.headPictureFrame.size.width -30 -voiceWidth, CGRectGetMidY(self.headPictureFrame) -10, voiceWidth, 17.9);
    
    
    //背景
    self.messageBackViewFrame = CGRectMake(CGRectGetMinX(self.contentFrame) -18, CGRectGetMinY(self.contentFrame) -12, self.contentFrame.size.width +35, self.contentFrame.size.height +35);
    
    if (self.messageBackViewFrame.size.height >self.headPictureFrame.size.height) {
        self.rowHeight = CGRectGetMaxY(self.messageBackViewFrame);
    }
    
}


- (NSInteger)setupVoiceSize:(NSNumber *)timeduration {
    
    NSInteger voiceBubbleWidth = 0;
    NSInteger duration = [timeduration integerValue];
    
    if (duration <= 2) {
      voiceBubbleWidth = 60;
    } else if (duration >2 && duration <=20) {
      voiceBubbleWidth = 60 + 2.5 * duration;
    } else if (duration > 20 && duration < 30){
      voiceBubbleWidth = 110 + 2 * (duration - 20);
    } else if (duration >30  && duration < 60) {
      voiceBubbleWidth = 130 + 1 * (duration - 30);
    } else {
      voiceBubbleWidth = 160;
    }
    
    return voiceBubbleWidth;
    
}


@end
