//
//  HLUploadSoundController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/12.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLUploadSoundController.h"
#import "SKTagView.h"
#import "HLSoundTagView.h"
#import "HLSoundRecordView.h" // 录音视图
#import "LGAudioPlayer.h"
#import "LGVoiceRecorder.h"

@interface HLUploadSoundController ()<HLSoundRecordViewDelegate>{
    NSInteger _wid;
}

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) SKTagView *tagView;

@property (nonatomic, strong) UIView *soundView;
@property (nonatomic, strong) UIButton *playBtn; // 播放按钮
@property (nonatomic, strong) UILabel *timeLab; // 秒数
@property (nonatomic, strong) UIImageView *voiceAnimationImageView; // 播放动画
@property (nonatomic, strong) UIButton *closeBtn; // 关闭按钮

@property (nonatomic, strong) HLSoundRecordView *recordView;

@property (nonatomic, strong) NSMutableArray *tagArray;

@property (nonatomic, strong) LGAudioPlayer *audioPlayer;
@property (nonatomic, strong) LGVoiceRecorder *recorder;
@property (nonatomic, strong) NSTimer *recordTimer; //录音定时器
@property (nonatomic, strong) NSString *localAACUrl; //aac地址
@property (nonatomic, copy) NSString *audioUrl; ///<音频url

@end

@implementation HLUploadSoundController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"发布" withColor:kRGB(255, 92, 121) style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self rightNavItemClick];
        
    }];
    
    self.sc_navigationBar.title = @"发布声缘";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.soundView];
    [self.view addSubview:self.tagView];
    [self.view addSubview:self.recordView];
    
    [self.soundView addSubview:self.playBtn];
    [self.soundView addSubview:self.timeLab];
    [self.soundView addSubview:self.voiceAnimationImageView];
    
    [self.view addSubview:self.closeBtn];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.mas_bottom).mas_offset(5);
        make.right.equalTo(self.textView.mas_right).mas_offset(-5);
    }];
    
    // 音频条
    [self.soundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(15);
        make.height.mas_offset(0);
        make.left.equalTo(self.textView.mas_left);
        make.right.lessThanOrEqualTo(self.textView.mas_right);
    }];
    
    // 播放按钮
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.soundView.mas_centerY);
        make.left.equalTo(self.soundView.mas_left).mas_offset(@10);
    }];
    
    // 秒数
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.soundView.mas_centerY);
        make.left.equalTo(self.playBtn.mas_right).mas_offset(@10);
    }];
    
    [self.voiceAnimationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.soundView.mas_centerY);
        make.right.equalTo(self.soundView.mas_right).mas_offset(@-10);
    }];
    
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.soundView.mas_centerY);
        make.left.equalTo(self.soundView.mas_right).mas_offset(@10);
    }];
    
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.soundView.mas_bottom).mas_offset(15);
        make.left.equalTo(self.textView.mas_left);
        make.right.equalTo(self.textView.mas_right);
    }];
    
    
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).mas_offset(-20);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@200);
    }];
    
}

- (void)rightNavItemClick {
    
    if (self.recordView.hidden == NO) {
        [self.view showTitle:@"点击录音,至少5s"];
        return;
    }
    
    if (self.textView.text.length == 0) {
        [self.view showTitle:@"这一刻您想说点什么.."];
        return;
    }
    
    if (self.tagArray.count <= 1) {
        [self.view showTitle:@"请选择声缘标签"];
        return;
    }
    
    
    [self uploadAudio];
}

// 上传音频文件
- (void)uploadAudio {
    
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat   = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp3", str];
    
    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSError *error;
        BOOL success = [formData appendPartWithFileURL:[NSURL fileURLWithPath:self.localAACUrl] name:@"image" fileName:fileName mimeType:@"audio/mpeg" error:&error];
        if (!success) {
            
            NSLog(@"appendPartWithFileURL error: %@", error);
        }
        
    } success:^(NSDictionary *dictionary) {
        NSLog(@"~~~~~%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self settingAudioWithUrl:dictionary[@"data"][@"url"]];
            
        } else {
            
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
        
    }];
    
}

// 发布声缘
- (void)settingAudioWithUrl:(NSString *)url {
    
    [self.tagArray removeObject:@"#添加标签"];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"voi":url,
        @"txt":self.textView.text,
        @"sec":[NSString stringWithFormat:@"%ld",_wid],
        @"label":self.tagArray
    };
    
    NSLog(@"%@",params);
    
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/add_voice_wall" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_SOUND" object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
}

- (HLSoundRecordView *)recordView {
    if (!_recordView) {
        _recordView = [[HLSoundRecordView alloc] init];
        _recordView.delegate = self;
    }
    return _recordView;
}

- (SKTagView *)tagView {
    if (!_tagView) {
        _tagView = [[SKTagView alloc] init];
//        _tagView.backgroundColor = [UIColor systemBlueColor];
        _tagView.preferredMaxLayoutWidth = kScreenWidth-20;
        _tagView.padding = UIEdgeInsetsMake(0, 0, 0, 0);
        _tagView.lineSpacing = 12;
        _tagView.interitemSpacing = 12;
        _tagView.singleLine = NO;
        // 给出两个字段，如果给的是0，那么就是变化的,如果给的不是0，那么就是固定的
//        cell.tagView.regularWidth = 80;
        _tagView.regularHeight = 30;
        
        [self addTagViewWithArr:self.tagArray];
        
    }
    return _tagView;
}

- (void)addTagViewWithArr:(NSMutableArray *)arr {
    
    [self.tagView removeAllTags];
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKTag *tag = [[SKTag alloc] initWithText:arr[idx]];
        tag.font = [UIFont systemFontOfSize:14];
        
        if ([arr[idx] isEqualToString:@"#添加标签"]) {
            tag.textColor = kRGBA(155, 156, 161, 1);
            tag.bgColor = kRGBA(234, 235, 236, 1);
        } else {
            tag.textColor = kRGBA(188, 96, 255, 1);
            tag.bgColor = kRGBA(251, 240, 255, 1);
        }
        
        tag.cornerRadius = 15;
        tag.enable = YES;
        tag.padding = UIEdgeInsetsMake(5, 22, 5, 22);
        [_tagView addTag:tag];
        
    }];
    
    WeakSelf(weakSelf);
    _tagView.didTapTagAtIndex = ^(NSUInteger index, UIButton *btn) {
        
        if ([arr[index] isEqualToString:@"#添加标签"]) {
            
            [weakSelf.view endEditing:YES];
            
            HLSoundTagView *popView = [[HLSoundTagView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andArr:weakSelf.tagArray];
            
            popView.SelectBlock = ^(NSArray *arr) {
                [weakSelf.tagArray removeAllObjects];
                [weakSelf.tagArray addObjectsFromArray:arr];
                [weakSelf.tagArray addObject:@"#添加标签"];
                
                [weakSelf addTagViewWithArr:[NSMutableArray arrayWithArray:weakSelf.tagArray]];
            };
            
            [popView showSelf];
            
        }
    };
    
}

- (NSMutableArray *)tagArray {
    if (!_tagArray) {
        _tagArray = [NSMutableArray arrayWithArray:@[@"#添加标签"]];
    }
    return _tagArray;
}

-(UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.text = [NSString stringWithFormat:@"%ld/200",self.textView.text.length];
        _nameLabel.font = kScaleFont(14);
        _nameLabel.textColor = [UIColor grayColor];
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, kNavBarHeight+10, kScreenWidth-20, 200)];
        
        _textView.textColor = [UIColor lightGrayColor];
        _textView.font = [UIFont systemFontOfSize:16];
        
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = @"这一刻您想说点什么...";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = [UIColor lightGrayColor];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        placeHolderLabel.font = [UIFont systemFontOfSize:16];
        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        
    }
    return _textView;
}

-(void)textViewEditChanged:(NSNotification *)notification{
    
    // 拿到文本改变的 text field
    UITextView *textView = (UITextView *)notification.object;
    // 需要限制的长度
    NSUInteger maxLength = 200;
    
    // text field 的内容
    NSString *contentText = textView.text;
    
    // 获取高亮内容的范围
    UITextRange *selectedRange = [textView markedTextRange];
    // 这行代码 可以认为是 获取高亮内容的长度
    NSInteger markedTextLength = [textView offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
    // 没有高亮内容时,对已输入的文字进行操作
    if (markedTextLength == 0) {
        // 如果 text field 的内容长度大于我们限制的内容长度
        if (contentText.length > maxLength) {
            // 截取从前面开始maxLength长度的字符串
            //            textField.text = [contentText substringToIndex:maxLength];
            // 此方法用于在字符串的一个range范围内，返回此range范围内完整的字符串的range
            NSRange rangeRange = [contentText rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
            textView.text = [contentText substringWithRange:rangeRange];
        }
    }
    self.nameLabel.text = [NSString stringWithFormat:@"%ld/200",textView.text.length];

}

- (UIView *)soundView {
    if (!_soundView) {
        _soundView = [[UIView alloc] init];
        
        _soundView.layer.cornerRadius = 44/2;
        _soundView.layer.masksToBounds = YES;
        
        [_soundView az_setGradientBackgroundWithColors:@[kRGB(255, 174, 157),kRGB(255, 112, 152)] locations:@[@(0),@(.8),@(0),@(0)] startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    }
    return _soundView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"sheng_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"sheng_zhanting"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (void)playClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self voiceRecordViewStartReplaying];
        
        [self.voiceAnimationImageView startAnimating];
    } else {
        [self voiceStopPlaying];
        
        [self.voiceAnimationImageView stopAnimating];
    }
    
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.textColor = [UIColor whiteColor];
        _timeLab.font = [UIFont systemFontOfSize:14];
    }
    return _timeLab;
}

- (UIImageView *)voiceAnimationImageView {
    if (!_voiceAnimationImageView) {
        _voiceAnimationImageView = [[UIImageView alloc] init];
        
        _voiceAnimationImageView.image = [UIImage imageNamed:@"sheng_three"];
        _voiceAnimationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"sheng_three"],[UIImage imageNamed:@"sheng_two"],[UIImage imageNamed:@"sheng_one"],[UIImage imageNamed:@"sheng_two"],[UIImage imageNamed:@"sheng_three"],nil];
        
        _voiceAnimationImageView.animationDuration = 1;
        
        _voiceAnimationImageView.animationRepeatCount = -1;
    }
    return _voiceAnimationImageView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"sound_ del"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)closeClick {
    
    if (self.audioPlayer.isPlaying) {
        [self.view showError:@"正在播放中,不能进行删除操作!"];
        return;
    }
    
    self.audioUrl = nil;
    self.localAACUrl = nil;
    
    [self.recorder reRecording];
    [self.recordView updateState:PIVoiceRecordViewStateReady seconds:0];
    
    
    // 音频条
    [self.soundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(15);
        make.height.mas_offset(0);
        make.left.equalTo(self.textView.mas_left);
        make.right.lessThanOrEqualTo(self.textView.mas_right);
    }];
    
    [self.voiceAnimationImageView stopAnimating];
    self.closeBtn.hidden = YES;
    self.recordView.hidden = NO;
    
    
    
}

#pragma mark - 音频录制播放逻辑
/************录音定时器*********************/
- (void)startRecordTimer
{
    [self stopRecordTimer];
    self.recordTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateRecordTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
    [self.recordTimer fire];
}

- (void)stopRecordTimer
{
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}
//更新录音时间
- (void)updateRecordTime
{
    if (self.recorder.currentTime == MAXRECORDTIME) {
        [self stopRecordTimer];
        [self.recorder stopRecording];
    }
    [self.recordView updateState:PIVoiceRecordViewStateRecording seconds:self.recorder.currentTime];
}

#pragma mark -PIVoiceRecordViewDelegate

/**
 改变录制状态
 
 @param start 开始/结束 录制
 */
- (void)voiceRecordViewRecordAction:(BOOL)start
{
    if (start) {
        //开始录制
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer stopPlaying];
        }
        [self.recorder startRecording];
    } else {
        //停止录制
        [self.recorder stopRecording];
    }
}


/**
 播放音频
 */
- (void)voiceRecordViewStartReplaying
{

    [self.audioPlayer startPlayWithUrl:self.localAACUrl isLocalFile:YES];
}


/**
 暂停
 */
- (void)voiceRecordViewPause:(BOOL)pause
{
    if (pause) {
        self.audioPlayer.isPlaying = NO;
    } else {
        self.audioPlayer.isPlaying = YES;
    }
    
    [self.audioPlayer pause:pause];
}

- (void)voiceStopPlaying {
    [self.audioPlayer stopPlaying];
}

// 确定
- (void)voiceConfirmPlayingWithTimeText:(NSInteger)sec {
    
    if (self.audioPlayer.isPlaying) {
        [self.view showError:@"正在播放中,不能进行确认操作!"];
        return;
    }
    
    NSLog(@"->:%@",self.localAACUrl);
    
    self.timeLab.text = [NSString stringWithFormat:@"%ld\"",sec];
    
    _wid = sec;
    
    // 音频条
    [self.soundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(15);
        make.height.mas_offset(44);
        make.left.equalTo(self.textView.mas_left);
        make.right.lessThanOrEqualTo(self.textView.mas_right);
        make.width.mas_offset([self setupVoiceSize:sec]);
    }];
    
    
    [self.closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.soundView.mas_centerY);
        make.left.equalTo(self.soundView.mas_right).mas_offset(@10);
    }];
    
    
    self.recordView.hidden = YES;
    self.closeBtn.hidden = NO;
    
}


/**
 完成录制
 */
- (void)voiceRecordViewFinishRecording
{
    if (!self.localAACUrl) {
        return;
    }
}

/**
 重新录制
 */
- (void)voiceRecordViewStartReRecording
{
    
    if (self.audioPlayer.isPlaying) {
        [self.view showError:@"正在播放中,不能进行删除操作!"];
        return;
    }
    
    if (!self.localAACUrl) {
        return;
    }
    UIAlertController *alertAC =  [UIAlertController alertControllerWithTitle:@"确定重录吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ensure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer stopPlaying];
        }
        self.audioUrl = nil;
        self.localAACUrl = nil;
//        [self.voiceRecordView stopReplayingAnimation];
        [self.recorder reRecording];
        [self.recordView updateState:PIVoiceRecordViewStateReady seconds:0];
    }];
    [alertAC addAction:cancel];
    [alertAC addAction:ensure];
    [self presentViewController:alertAC animated:YES completion:nil];
    
}



#pragma mark -setter and getter
- (LGVoiceRecorder *)recorder
{
    if (!_recorder) {
        _recorder = [[LGVoiceRecorder alloc] init];
        __weak typeof(self) weakSelf = self;

        //开始录音
        _recorder.audioStartRecording = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf startRecordTimer];
                
                [weakSelf.recordView updateState:PIVoiceRecordViewStateRecording seconds:0];
//                [weakSelf.voiceRecordView startRecordingAnimation];
            } else {
                NSLog(@"未获取到麦克风，请检查麦克风权限是否开启");
            }
        };
        
        //录音失败，时间过短
        _recorder.audioRecordingFail = ^(NSString *reason) {
            [weakSelf stopRecordTimer];
//            [weakSelf.voiceRecordView stopRecordingAnimation];
            [weakSelf.recordView updateState:PIVoiceRecordViewStateReady seconds:0];
        };
        
        _recorder.audioFinishRecording = ^(NSString *aacUrl, NSUInteger audioTimeLength) {
            [weakSelf stopRecordTimer];
//            [weakSelf.voiceRecordView stopRecordingAnimation];
            if (audioTimeLength<5) {
     
                [weakSelf.view showTitle:@"声音不足5秒，请重录"];
                
                weakSelf.localAACUrl = nil;
                weakSelf.audioUrl = nil;
                [weakSelf.recordView updateState:PIVoiceRecordViewStateReady seconds:0];
                return ;
            }
            weakSelf.localAACUrl = aacUrl;
            [weakSelf.recordView updateState:PIVoiceRecordViewStateFinish seconds:MIN(180, audioTimeLength)];
        };
        
    }
    return _recorder;
}

- (LGAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        _audioPlayer = [[LGAudioPlayer alloc] init];
        __weak typeof(self) weakSelf = self;
        _audioPlayer.startPlaying = ^(AVPlayerItemStatus status, CGFloat duration) {
            if (status == AVPlayerItemStatusReadyToPlay) {
                if (weakSelf.audioPlayer.isLocalFile) {
                    //录音
                    
//                    [weakSelf.voiceRecordView startReplayingAnimation:duration];
                    [weakSelf.recordView updateState:PIVoiceRecordViewStateFinish seconds:(NSInteger)duration];
                } else {
                    //网络
                    NSLog(@"duration %f",duration);
                }
                
            } else {
                if (status == AVPlayerItemStatusFailed) {
                    
                    NSLog(@"音频播放失败，请重试");
                }
                if (weakSelf.audioPlayer.isLocalFile) {
//                    [weakSelf.voiceRecordView stopReplayingAnimation];
                    [weakSelf.recordView updateState:PIVoiceRecordViewStateFinish seconds:weakSelf.recorder.audioTimeLength];
                } else {
                    //网络音频
                }


            }
            
            
        };
        _audioPlayer.playComplete = ^{
            if (weakSelf.audioPlayer.isLocalFile) {
                [weakSelf.recordView updateState:PIVoiceRecordViewStateReplaying seconds:0];
//                [weakSelf.voiceRecordView stopReplayingAnimation];
                
                [weakSelf.recordView updateState:PIVoiceRecordViewStateFinish seconds:weakSelf.recorder.audioTimeLength];
                
                
                weakSelf.playBtn.selected = NO;
                [weakSelf.voiceAnimationImageView stopAnimating];
                
            } else {
                //网络
            }
        };
        _audioPlayer.playingBlock = ^(CGFloat currentTime) {
            if (weakSelf.audioPlayer.isLocalFile) {
                [weakSelf.recordView updateState:PIVoiceRecordViewStateReplaying seconds:currentTime];
            } else {
                //网络
            }
            
        };
    }
    return _audioPlayer;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (NSInteger)setupVoiceSize:(NSInteger)timeduration {
    
    NSInteger voiceBubbleWidth = 0;
    NSInteger duration = timeduration;
    
    if (duration <= 2) {
      voiceBubbleWidth = 115;
    } else if (duration >2 && duration <=20) {
      voiceBubbleWidth = 120 + 2.5 * duration;
    } else if (duration > 20 && duration < 30){
      voiceBubbleWidth = 150 + 2 * (duration - 20);
    } else if (duration >=30  && duration < 60) {
      voiceBubbleWidth = 170 + 1 * (duration - 30);
    } else {
      voiceBubbleWidth = 250;
    }
    
    return voiceBubbleWidth;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
