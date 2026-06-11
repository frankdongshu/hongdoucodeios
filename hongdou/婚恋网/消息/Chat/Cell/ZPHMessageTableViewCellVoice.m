//
//  ZPHMessageTableViewCellVoice.m
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import "ZPHMessageTableViewCellVoice.h"
#import "LGAudioPlayer.h"

@interface ZPHMessageTableViewCellVoice ()<LGAudioPlayerDelegate>

@property (nonatomic, strong) UIImageView *voiceAnimationImageView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSString *voiceUrl;


@end
@implementation ZPHMessageTableViewCellVoice

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _voiceAnimationImageView  = [[UIImageView alloc] init];
        
        _voiceAnimationImageView.image = [UIImage imageNamed:@"wechatvoice3"];
        _voiceAnimationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"wechatvoice3"],[UIImage imageNamed:@"wechatvoice3_1"],[UIImage imageNamed:@"wechatvoice3_0"],[UIImage imageNamed:@"wechatvoice3_1"],[UIImage imageNamed:@"wechatvoice3"],nil];
        
        _voiceAnimationImageView.animationDuration = 1;
        
        _voiceAnimationImageView.animationRepeatCount = -1;
        
        [self.contentView addSubview:_voiceAnimationImageView];
        
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_messageLabel];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
        
        self.messageBackView.userInteractionEnabled = YES;
        [self.messageBackView addGestureRecognizer:tap];
        
    }
    
    return self;
}

-(void)setLayout:(ZPHMessageTableViewCellLayout *)layout {
    
    [super setLayout:layout];
    
    _voiceAnimationImageView.frame = CGRectMake(layout.contentFrame.origin.x, layout.contentFrame.origin.y, 13, layout.contentFrame.size.height);
    
    _voiceAnimationImageView.transform = [[NSString stringWithFormat:@"%@",layout.model.uid] isEqualToString:[LoginManager defaultManager].userid]?CGAffineTransformMakeRotation(M_PI):CGAffineTransformMakeRotation(0);
    
    
    _messageLabel.frame = CGRectMake(CGRectGetMaxX(_voiceAnimationImageView.frame)+10, CGRectGetMinY(_voiceAnimationImageView.frame), layout.contentFrame.size.width-13, layout.contentFrame.size.height);
    
    NSRange range = [layout.model.text rangeOfString:@"#"];
    
    NSString *okStr;
    
    if (range.location != NSNotFound) {
        okStr = [layout.model.text substringFromIndex:range.location+1];
        _voiceUrl = [layout.model.text substringToIndex:range.location];
    } else {
        // Not Found
        okStr = @"0";
        _voiceUrl = layout.model.text;
    }
    
    _messageLabel.text = [NSString stringWithFormat:@"%ld''",[okStr integerValue]];
    
    
    self.messageBackView.frame = layout.messageBackViewFrame;
}

// 点击音频
- (void)doTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    NSLog(@"=播放的音频==>: %@",self.voiceUrl);
    
    if ([[LGAudioPlayer shareInstance] isPlaying]) {
        
        if ([[[LGAudioPlayer shareInstance] playingFileName] isEqualToString:self.voiceUrl]) {
            [_voiceAnimationImageView stopAnimating];
            [[LGAudioPlayer shareInstance] stopPlaying];
        } else {
            
            [[LGAudioPlayer shareInstance] startPlayWithUrl:self.voiceUrl isLocalFile:NO];
            [_voiceAnimationImageView startAnimating];
            
            [[LGAudioPlayer shareInstance] setDelegate:self];
        }
        
        
    } else {
        
        [[LGAudioPlayer shareInstance] startPlayWithUrl:self.voiceUrl isLocalFile:NO];
        [_voiceAnimationImageView startAnimating];
        
        [[LGAudioPlayer shareInstance] setDelegate:self];
    }
    
}

- (void)dealloc {
    
    [[LGAudioPlayer shareInstance] setDelegate:nil];
    
}

// 播放完成
- (void)didAudioPlayerComplete {
    [_voiceAnimationImageView stopAnimating];
}

// 播放失败
- (void)didAudioPlayerStatusFailed {
    [_voiceAnimationImageView stopAnimating];
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
