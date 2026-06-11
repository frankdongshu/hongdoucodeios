//
//  HLFindSoundCell.m
//  hongdou
//
//  Created by 李龙 on 2021/12/11.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLFindSoundCell.h"

@interface HLFindSoundCell ()<LGAudioPlayerDelegate>

@end

@implementation HLFindSoundCell

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
    
    if ([[dataDic[@"uid"] stringValue] isEqualToString:[LoginManager defaultManager].userid]) {
        self.deleteBtn.hidden = NO;
    } else {
        self.deleteBtn.hidden = YES;
    }
    
}


- (IBAction)likeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self requestCollectionUrl:@"/album/likes_voice_wall" andBtn:sender];
    } else {
        [self requestCollectionUrl:@"/album/no_likes_voice_wall" andBtn:sender];
    }
    
}


- (void)requestCollectionUrl:(NSString *)url andBtn:(UIButton *)sender {
    
    [kAppDelegate.window showLoading];
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"vwid":self.dataDic[@"id"]} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            
            if ([url isEqualToString:@"/album/likes_voice_wall"]) { // 点赞
                [self.likeBtn setTitle:[NSString stringWithFormat:@" %d",[sender.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            } else { // 取消点赞
                [self.likeBtn setTitle:[NSString stringWithFormat:@" %d",[sender.titleLabel.text intValue]-1] forState:UIControlStateNormal];
            }

        } else {
            sender.selected = !sender.selected;
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        sender.selected = !sender.selected;
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
    
}

- (IBAction)playClick:(UIButton *)sender {
//    _playBtn.selected = !_playBtn.selected;
    
    if ([[LGAudioPlayer shareInstance] isPlaying]) {
        
        if ([[[LGAudioPlayer shareInstance] playingFileName] isEqualToString:self.dataDic[@"voi"]]) {
            
            _playBtn.selected = NO;
            [_voiceAnimationImageView stopAnimating];
            [[LGAudioPlayer shareInstance] stopPlaying];
        } else {
            _playBtn.selected = YES;
            [[LGAudioPlayer shareInstance] startPlayWithUrl:self.dataDic[@"voi"] isLocalFile:NO];
            [_voiceAnimationImageView startAnimating];
            [[LGAudioPlayer shareInstance] setDelegate:self];
        }
        
        
    } else {
        
        _playBtn.selected = YES;
        [[LGAudioPlayer shareInstance] startPlayWithUrl:self.dataDic[@"voi"] isLocalFile:NO];
        [_voiceAnimationImageView startAnimating];
        
        [[LGAudioPlayer shareInstance] setDelegate:self];
    }
    
}

- (IBAction)deleteClick:(UIButton *)sender {
    
    if ([[LGAudioPlayer shareInstance] isPlaying]) {
        [[LGAudioPlayer shareInstance] stopPlaying];
    }
    
    [self.delegate deleteButtonClick:_dataDic[@"id"]];
    
}

// 播放完成
- (void)didAudioPlayerComplete {
    _playBtn.selected = NO;
    [_voiceAnimationImageView stopAnimating];
}

// 播放失败
- (void)didAudioPlayerStatusFailed {
    
    [MBProgressHUD showMessage:@"音频加载失败" view:kAppDelegate.window];
    
    _playBtn.selected = NO;
    [_voiceAnimationImageView stopAnimating];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_recordBgView az_setGradientBackgroundWithColors:@[kRGB(255, 174, 157),kRGB(255, 112, 152)] locations:@[@(0),@(.8),@(0),@(0)] startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    
    _voiceAnimationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"sheng_three"],[UIImage imageNamed:@"sheng_two"],[UIImage imageNamed:@"sheng_one"],[UIImage imageNamed:@"sheng_two"],[UIImage imageNamed:@"sheng_three"],nil];
    
    _voiceAnimationImageView.animationDuration = 1;
    
    _voiceAnimationImageView.animationRepeatCount = -1;
    
    _voiceAnimationImageView.transform = CGAffineTransformMakeRotation(0);
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
