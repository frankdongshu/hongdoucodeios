//
//  ZPHMessageTableViewCell.m
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import "ZPHMessageTableViewCell.h"
#import "ZPHMessageTableViewCellText.h"
#import "ZPHMessageTableViewCellImage.h"
#import "ZPHMessageTableViewCellVoice.h"
#import "ZPHMessageTableViewCellCard.h"
#import "ZPHMessageTableViewCellHtml.h"

@implementation ZPHMessageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;//点击效果
//        self.userInteractionEnabled = NO;//交互
        self.backgroundColor = [UIColor clearColor];
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:8];
        _timeLabel.layer.cornerRadius = 3;
        _timeLabel.layer.masksToBounds = YES;
        [_timeLabel setTextColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:_timeLabel];
        
        _headImageView = [[UIImageView alloc]init];         //头像
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        [self.contentView addSubview:_headImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        _headImageView.userInteractionEnabled = YES;
        [_headImageView addGestureRecognizer:tap];
        
        _messageBackView = [[UIImageView alloc]init];       //背景图片
        [self.contentView addSubview:_messageBackView];
    }
    return self;
}

// 点击头像进入详情
- (void)tapClick {
    
    if ([[NSString stringWithFormat:@"%@",self.layout.model.uid] isEqualToString:[LoginManager defaultManager].userid]) {
        [self.delegate requestReceived:YES];
        
    } else {
        [self.delegate requestReceived:NO];
    }
    
}

//赋值
-(void)setLayout:(ZPHMessageTableViewCellLayout *)layout {
    
    _layout = layout;

    //时间
    _timeLabel.attributedText = layout.timeAttributedString;
    _timeLabel.frame = layout.timeFrame;
    _timeLabel.hidden = NO;

    
    //头像
    _headImageView.frame = layout.headPictureFrame;
    
    
    
    if ([[NSString stringWithFormat:@"%@",layout.model.uid] isEqualToString:[LoginManager defaultManager].userid]) {
        
        if (layout.headImage == nil) {
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:[LoginManager defaultManager].avatar] placeholderImage:[UIImage imageNamed:@"message_headImage"]];
        }else {
            _headImageView.image = layout.headImage;
        }
    }else {

//        _headImageView.image = [UIImage imageNamed:@"message_kefu"];
        
//        if ([[NSString stringWithFormat:@"%@",layout.model.chead] isEqualToString:[LoginManager defaultManager].avatar]) {
//            [_headImageView sd_setImageWithURL:[NSURL URLWithString:layout.model.uhead]];
//        } else {
//            [_headImageView sd_setImageWithURL:[NSURL URLWithString:layout.model.chead]];
//        }
        
       
        NSArray *components = [[LoginManager defaultManager].avatar componentsSeparatedByString:@"?"];
        NSString * avatar;
        if (components.count > 0) {

            avatar = [components firstObject];
        }else{
            avatar = [LoginManager defaultManager].avatar;
        }

        NSLog(@"===============avatar=%@",avatar);
       
        
        if ([layout.model.chead containsString:avatar] ) {
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:layout.model.uhead]];
        } else {
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:layout.model.chead]];
        }
        //修改头像
//        [_headImageView sd_setImageWithURL:[NSURL URLWithString:layout.model.uhead]];
        

    }
    _rowHeight = layout.rowHeight;
    
    //背景
    if ([[NSString stringWithFormat:@"%@",layout.model.uid] isEqualToString:[LoginManager defaultManager].userid]) {
        _messageBackView.image = [[UIImage imageNamed:@"selfcontactBg"]stretchableImageWithLeftCapWidth:50 topCapHeight:30];
    }else {
        _messageBackView.image = [[UIImage imageNamed:@"otherContactBg"]stretchableImageWithLeftCapWidth:50 topCapHeight:30];
    }
}

-(ZPHMessageType)messageType {
    
    if ([self isKindOfClass:[ZPHMessageTableViewCellText class]]) {
        return ZPHMessageTypeText;
    }else if ([self isKindOfClass:[ZPHMessageTableViewCellImage class]]) {
        return ZPHMessageTypeImage;     //图片
    }else if ([self isKindOfClass:[ZPHMessageTableViewCellVoice class]]) {
        return ZPHMessageTypeVoice;     //语音
    }else if ([self isKindOfClass:[ZPHMessageTableViewCellHtml class]]) {
        return ZPHMessageTypeHtml;     //html
    }else if ([self isKindOfClass:[ZPHMessageTableViewCellCard class]]) {
        return ZPHMessageTypeCard;     //名片
    }
    return ZPHMessageTypeUnknow;        //未知
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
