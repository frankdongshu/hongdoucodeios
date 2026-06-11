//
//  HLSoundRecordView.m
//  hongdou
//
//  Created by 李龙 on 2021/12/13.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLSoundRecordView.h"
#import "HWCircleView.h"

@interface HLSoundRecordView ()
@property (nonatomic, strong) UIButton *resetBtn; // 重置按钮
@property (nonatomic, strong) UIButton *playBtn; // 播放按钮
@property (nonatomic, strong) UIButton *confirmBtn; // 确定按钮
@property (nonatomic, strong) UIButton *pauseBtn; //暂停/恢复按钮

@property (nonatomic, strong) HWCircleView *circle;

@property (nonatomic, strong) UILabel *secondsLab;
@property (nonatomic, strong) UILabel *resetLab, *playLab, *confirmLab;

@property (nonatomic, assign) NSInteger totalTime; //总时长

@end

@implementation HLSoundRecordView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.state = PIVoiceRecordViewStateReady;
        
        [self addSubview:self.resetBtn];
        [self addSubview:self.circle];
        [self addSubview:self.playBtn];
        [self addSubview:self.pauseBtn];
        [self addSubview:self.confirmBtn];
        
        [self addSubview:self.resetLab];
        [self addSubview:self.playLab];
        [self addSubview:self.confirmLab];
        [self addSubview:self.secondsLab];
        
        
        
        [self.secondsLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).equalTo(@30);
        }];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.secondsLab.mas_bottom).equalTo(@20);
        }];
        
        [self.pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playBtn);
            make.centerX.equalTo(self.playBtn);
            make.width.height.equalTo(self.playBtn);
        }];
        
        [self.circle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_left).equalTo(@-5);
            make.top.equalTo(self.playBtn.mas_top).equalTo(@-5);
            make.right.equalTo(self.playBtn.mas_right).equalTo(@5);
            make.bottom.equalTo(self.playBtn.mas_bottom).equalTo(@5);
        }];
        
        [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.playBtn.mas_left).equalTo(@-50);
            make.centerY.equalTo(self.playBtn.mas_centerY);
        }];
        
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playBtn.mas_right).equalTo(@50);
            make.centerY.equalTo(self.playBtn.mas_centerY);
        }];
        
        [self.resetLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.resetBtn.mas_bottom).equalTo(@10);
            make.centerX.equalTo(self.resetBtn.mas_centerX);
        }];
        
        [self.playLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playBtn.mas_bottom).equalTo(@10);
            make.centerX.equalTo(self.playBtn.mas_centerX);
        }];

        [self.confirmLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.confirmBtn.mas_bottom).equalTo(@10);
            make.centerX.equalTo(self.confirmBtn.mas_centerX);
        }];
        
        
    }
    return self;
}

- (HWCircleView *)circle {
    if (!_circle) {
        _circle = [[HWCircleView alloc] init];
    }
    return _circle;
}

- (UIButton *)pauseBtn {
    if (!_pauseBtn) {
        //暂停/恢复按钮
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pauseBtn.hidden = YES;
        [_pauseBtn setImage:[UIImage imageNamed:@"sound_ play"] forState:UIControlStateNormal];
        
        [_pauseBtn addTarget:self action:@selector(pauseClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}

- (void)pauseClick:(UIButton *)sender {
    sender.hidden = YES;
    self.playBtn.hidden = NO;
    self.playLab.text = @"播放中";
    [self.delegate voiceRecordViewPause:NO];
}

// 重置
- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetBtn.hidden = YES;
        [_resetBtn setBackgroundImage:[UIImage imageNamed:@"sound_ reset"] forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (void)resetClick {
    
    [self.delegate voiceRecordViewStartReRecording];
    
}


// 开始
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.tag = 0;
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"sound_ luyin"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (void)playClick:(UIButton *)sender {
    
    if (self.state == PIVoiceRecordViewStateReady) {
        [self.delegate voiceRecordViewRecordAction:YES];
        return;
    }
    
    if (self.state == PIVoiceRecordViewStateRecording) {
        [self.delegate voiceRecordViewRecordAction:NO];
        return;
    }
    
    if (self.state == PIVoiceRecordViewStateFinish) {
        self.circle.progress = 0;
        [self.delegate voiceRecordViewStartReplaying];
        return;
    }
    
    if (self.state == PIVoiceRecordViewStateReplaying) {
        self.playBtn.hidden = YES;
        self.pauseBtn.hidden = NO;
        self.playLab.text = @"继续播放";
        [self.delegate voiceRecordViewPause:YES];
        return;
    }
    
}

// 确定
- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.hidden = YES;
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"sound_ confirm"] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

// 确定
- (void)confirmClick {
    
    [self.delegate voiceConfirmPlayingWithTimeText:self.totalTime];
    
}

- (UILabel *)resetLab {
    if (!_resetLab) {
        _resetLab = [[UILabel alloc] init];
        _resetLab.hidden = YES;
        _resetLab.text = @"重置";
        _resetLab.textColor = kRGBA(156, 164, 175, 1);
        _resetLab.font = [UIFont systemFontOfSize:12];
    }
    return _resetLab;
}

- (UILabel *)playLab {
    if (!_playLab) {
        _playLab = [[UILabel alloc] init];
        _playLab.text = @"点击录音，至少5s";
        _playLab.textColor = kRGBA(156, 164, 175, 1);
        _playLab.font = [UIFont systemFontOfSize:12];
    }
    return _playLab;
}

- (UILabel *)confirmLab {
    if (!_confirmLab) {
        _confirmLab = [[UILabel alloc] init];
        _confirmLab.hidden = YES;
        _confirmLab.text = @"确定";
        _confirmLab.textColor = kRGBA(156, 164, 175, 1);
        _confirmLab.font = [UIFont systemFontOfSize:12];
    }
    return _confirmLab;
}

- (UILabel *)secondsLab {
    if (!_secondsLab) {
        _secondsLab = [[UILabel alloc] init];
        _secondsLab.text = @"0s";
        _secondsLab.textColor = kRGBA(156, 164, 175, 1);
        _secondsLab.font = [UIFont systemFontOfSize:12];
    }
    return _secondsLab;
}

- (void)updateState:(PIVoiceRecordViewState)state seconds:(NSUInteger)seconds{
    
    if (_state != state) {
        self.state = state;
        //更换UI
        
        switch (self.state) {
            case PIVoiceRecordViewStateReady: {
                //准备录制
                self.secondsLab.text = @"0s";
                [self.playBtn setBackgroundImage:[UIImage imageNamed:@"sound_ luyin"] forState:UIControlStateNormal];
                self.pauseBtn.hidden = YES;
                self.playBtn.hidden = NO;
                self.playLab.text = @"点击录音，至少5s";
                self.resetBtn.hidden = YES;
                self.confirmBtn.hidden = YES;
                self.resetLab.hidden = YES;
                self.confirmLab.hidden = YES;
                
            }
                break;
            case PIVoiceRecordViewStateRecording: {
                
                
            }
                break;
                
            case PIVoiceRecordViewStateReplaying: {
                self.secondsLab.text = [NSString stringWithFormat:@"%lds",self.totalTime];
                
                [self.playBtn setBackgroundImage:[UIImage imageNamed:@"sound_ pause"] forState:UIControlStateNormal];
                
                self.playLab.text = @"播放中";
                
            }
                break;
                
            case PIVoiceRecordViewStateFinish: {
                
                self.resetBtn.hidden = NO;
                self.confirmBtn.hidden = NO;
                self.resetLab.hidden = NO;
                self.confirmLab.hidden = NO;
                
                self.playLab.text = @"点击试听";
                [self.playBtn setBackgroundImage:[UIImage imageNamed:@"sound_ play"] forState:UIControlStateNormal];
                
            }
                break;
            default:
                break;
        }
    }
    
    
    switch (self.state) {
        case PIVoiceRecordViewStateReady: {
            
            _circle.progress = 0;
            
        }
            break;
        case PIVoiceRecordViewStateRecording: {
            _circle.progress += 0.01;
            
            //录制中
            self.playLab.text = @"点击结束录音";
            [_playBtn setBackgroundImage:[UIImage imageNamed:@"sound_ luyinzhong"] forState:UIControlStateNormal];
            
            self.secondsLab.text = [NSString stringWithFormat:@"%lds",MIN(seconds, MAXRECORDTIME)];
            
            if (MIN(seconds, MAXRECORDTIME)>59) {
                [self.delegate voiceRecordViewRecordAction:NO];
                return;
            }
            
        }
            break;
            
        case PIVoiceRecordViewStateReplaying: {
            
            _circle.progress += 0.01;
            
//            NSInteger i = MAX(0, self.totalTime - seconds);
            NSInteger i = MIN(seconds, self.totalTime);
            
            if (i<0) {
                return;
            }
            
            self.secondsLab.text = [NSString stringWithFormat:@"%lds",i];
            
        }
            break;
            
        case PIVoiceRecordViewStateFinish: {
            
            self.playLab.text = @"点击试听";
            
            if (seconds > 0) {
                self.totalTime = seconds;
                self.secondsLab.text = [NSString stringWithFormat:@"%lds",seconds];
                
            }
            
        }
            break;
        default:
            break;
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
