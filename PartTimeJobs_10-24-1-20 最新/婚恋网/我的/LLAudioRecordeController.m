//
//  LLAudioRecordeController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/31.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLAudioRecordeController.h"
#import <AVFoundation/AVFoundation.h>
#import "SCSiriWaveformView.h"

#import "PIVoiceRecordView.h"
#import "LGAudioPlayer.h"
#import "LGVoiceRecorder.h"

typedef NS_ENUM(NSUInteger, SCSiriWaveformViewInputType) {
    SCSiriWaveformViewInputTypeRecorder,
    SCSiriWaveformViewInputTypePlayer
};

@interface LLAudioRecordeController ()<PIVoiceRecordViewDelegate>{
    CADisplayLink *displaylink;
    
    BOOL isFileUrl;
}

@property (nonatomic, strong) PIVoiceRecordView *voiceRecordView;
@property (nonatomic, strong) LGAudioPlayer *audioPlayer; // 音频播放
@property (nonatomic, strong) LGVoiceRecorder *recorder; // 音频录制
@property (nonatomic, strong) NSTimer *recordTimer; //录音定时器
@property (nonatomic, strong) NSString *localAACUrl; //aac地址
@property (nonatomic, copy) NSString *audioUrl; ///<音频url


@property (nonatomic, strong) SCSiriWaveformView *waveformView;

@property (nonatomic, assign) SCSiriWaveformViewInputType selectedInputType;

@property (nonatomic, strong) UIButton *recorderBtn, *playerBtn;


@end

@implementation LLAudioRecordeController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotification];
    [self destory];
    
}

// 禁用侧滑返回手势
- (void)forbiddenGesture {
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self forbiddenGesture];
    self.automaticallyAdjustsScrollViewInsets = NO;

    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.recorder.isRecording) {
            [self.view showTostWithMessage:@"录制中,不可返回"];
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"语音简介";
    
    isFileUrl = YES; // 默认本地路径
    
    [self initViews];
    
    [self addNotification];
    
    self.waveformView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight-300)];
    
    [self.view addSubview:self.waveformView];
    
    [self.waveformView updateWithLevel:0];
    
    [self.waveformView setWaveColor:[UIColor colorWithHex:0x995ff8]];
    self.waveformView.backgroundColor = [UIColor clearColor];
    [self.waveformView setPrimaryWaveLineWidth:3.0f];
    [self.waveformView setSecondaryWaveLineWidth:1.0];
    
    
    // 获取音频
    [self requestAudio];
}

- (void)initViews
{
    
    
    //录音视图
    self.voiceRecordView = [[PIVoiceRecordView alloc] initWithEnsureTitle:@"保存" frame:CGRectMake(0, kScreenHeight-300, kScreenWidth, 300)];
    self.voiceRecordView.delegate = self;
    [self.view addSubview:self.voiceRecordView];
    
    
}
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopContext) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
//清除
- (void)stopContext
{
    [self stopRecordTimer];
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stopPlaying];
        
    }
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];
        
    }
}
- (void)destory
{
    [self stopRecordTimer];
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stopPlaying];
        
    }
    if (self.recorder.isRecording) {
        [self.recorder stopRecording];
        
    } else {
        [self.recorder reRecording];
    }
    [self.voiceRecordView updateState:PIVoiceRecordViewStateReady seconds:0];
    self.audioPlayer = nil;
    self.recorder = nil;
    
    
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
    [self.voiceRecordView updateState:PIVoiceRecordViewStateRecording seconds:self.recorder.currentTime];
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
        
        if ([self checkMicrophonePermission]) {
            [self.recorder startRecording];
        }
        
        if (!displaylink) {
            displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
            [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
        
    } else {
        //停止录制
        [self.recorder stopRecording];
        
        [displaylink invalidate];
        displaylink = nil;
    }
}


- (BOOL)checkMicrophonePermission{
    
    //    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    //    return permission == AVAudioSessionRecordPermissionGranted;
    __block BOOL bCanRecord = NO;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {// 未询问用户是否授权
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
                [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                    if (granted) {//用户选择允许
                        bCanRecord = YES;
                    } else {//用户选择不允许
                        bCanRecord = NO;
                    }
                }];
            }
        } else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
            bCanRecord = NO;//用户在第一次系统弹窗后选择不允许之后，再次录音的时候会走这里“麦克风权限未授权”
            // 未授权
            NSLog(@"未授权");
            [self popUpMicrophonePermissionAlertView];//弹出自己自定义的窗
            
        } else{
            bCanRecord = YES;
            // 已授权
            NSLog(@"已授权");
            
        }
    }
    return bCanRecord;
}


//弹出自定义开启麦克风权限的提示框
- (void)popUpMicrophonePermissionAlertView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"麦克风权限未开启"message:@"麦克风权限未开启,请进入系统【设置】>【隐私】>【麦克风】中打开开关,开启麦克风功能" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
        //跳入当前App设置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self  presentViewController:alertController animated:YES completion:nil];
    });
}




- (void)updateMeters {
    
    [self.recorder updateMeters];
}

/**
 播放音频
 */
- (void)voiceRecordViewStartReplaying
{

    [self.audioPlayer startPlayWithUrl:self.localAACUrl isLocalFile:isFileUrl];
}


/**
 暂停
 */
- (void)voiceRecordViewPause:(BOOL)pause
{
    [self.audioPlayer pause:pause];
    
    
}


/**
 完成录制
 */
- (void)voiceRecordViewFinishRecording
{
    if (!self.localAACUrl) {
        return;
    }
    
//    if (!self.audioPlayer.isPlaying) {
//
//    } else {
//        [self.view showTostWithMessage:@"播放完成后再操作"];
//    }
    
    
    [self.audioPlayer stopPlaying];
    
    [self uploadAudio];
    
    
}

/**
 重新录制
 */
- (void)voiceRecordViewStartReRecording
{
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
        [self.voiceRecordView stopReplayingAnimation];
        [self.recorder reRecording];
        [self.voiceRecordView updateState:PIVoiceRecordViewStateReady seconds:0];
        
        // 删除音频
        [self deleteAudio];
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
                
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateRecording seconds:0];
                [weakSelf.voiceRecordView startRecordingAnimation];
            } else {
                NSLog(@"未获取到麦克风，请检查麦克风权限是否开启");
            }
        };
        
        //录音失败，时间过短
        _recorder.audioRecordingFail = ^(NSString *reason) {
            [weakSelf stopRecordTimer];
            [weakSelf.voiceRecordView stopRecordingAnimation];
            [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateReady seconds:0];
        };
        
        _recorder.audioFinishRecording = ^(NSString *aacUrl, NSUInteger audioTimeLength) {
            [weakSelf stopRecordTimer];
            [weakSelf.voiceRecordView stopRecordingAnimation];
            if (audioTimeLength<MINRECORDTIME) {
     
                NSLog(@"%@",[NSString stringWithFormat:@"声音不足%d秒，请重录", MINRECORDTIME]);
                weakSelf.localAACUrl = nil;
                weakSelf.audioUrl = nil;
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateReady seconds:0];
                return ;
            }
            weakSelf.localAACUrl = aacUrl;
            [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:MIN(180, audioTimeLength)];
        };
        
        _recorder.audioMetersRecording = ^(CGFloat norVal) {
            NSLog(@"~~%f",norVal);
            [weakSelf.waveformView updateWithLevel:norVal];
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
                    
                    [weakSelf.voiceRecordView startReplayingAnimation:duration];
                    [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:(NSInteger)duration];
                } else {
                    //网络
                    NSLog(@"duration %f",duration);
                    [weakSelf.voiceRecordView startReplayingAnimation:duration];
                    [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:(NSInteger)duration];
                }
                
            } else {
                if (status == AVPlayerItemStatusFailed) {
                    
                    NSLog(@"音频播放失败，请重试");
                }
                if (weakSelf.audioPlayer.isLocalFile) {
                    [weakSelf.voiceRecordView stopReplayingAnimation];
                    [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:weakSelf.recorder.audioTimeLength];
                } else {
                    //网络音频
                    [weakSelf.voiceRecordView stopReplayingAnimation];
                    [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:weakSelf.recorder.audioTimeLength];
                }


            }
            
            
        };
        _audioPlayer.playComplete = ^{
            if (weakSelf.audioPlayer.isLocalFile) {
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateReplaying seconds:0];
                [weakSelf.voiceRecordView stopReplayingAnimation];
                
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:weakSelf.recorder.audioTimeLength];
            } else {
                //网络
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateReplaying seconds:0];
                [weakSelf.voiceRecordView stopReplayingAnimation];
                
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:weakSelf.recorder.audioTimeLength];
                
                weakSelf.voiceRecordView.nextBtn.hidden = YES;
            }
        };
        _audioPlayer.playingBlock = ^(CGFloat currentTime) {
            if (weakSelf.audioPlayer.isLocalFile) {
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateReplaying seconds:currentTime];
            } else {
                //网络
                [weakSelf.voiceRecordView updateState:PIVoiceRecordViewStateReplaying seconds:currentTime];
            }
            
        };
    }
    return _audioPlayer;
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
            
            [self settingAudioWithUrl:dictionary[@"data"][@"url"] sid:dictionary[@"data"][@"vid"]];
            
        } else {
            
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
        
    }];
    
}

// 设置音频
- (void)settingAudioWithUrl:(NSString *)url sid:(NSString *)sid {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"url":url,
        @"sid":sid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/sound" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        self.localAACUrl = url;
        self->isFileUrl = NO;
        
        self.voiceRecordView.nextBtn.hidden = YES;
        
        [self.view showTostWithMessage:dictionary[@"msg"]];
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
        
    }];
}

// 获取音频
- (void)requestAudio {
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_sound" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        NSLog(@"~~~%@",dictionary);
        
        if (!kISNullObject(dictionary[@"data"][@"sound"])) {
            
            self.localAACUrl = dictionary[@"data"][@"sound"];
            self->isFileUrl = NO;
            
            CGFloat f = [self audioDurationFromURL:self.localAACUrl];
            
            NSLog(@"~%f",f);
            
            [self.voiceRecordView updateState:PIVoiceRecordViewStateFinish seconds:f];
            
            
            self.voiceRecordView.nextBtn.hidden = YES;
            self.voiceRecordView.rerecordingBtn.hidden = NO;
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
}

- (NSTimeInterval)audioDurationFromURL:(NSString *)url {
    AVURLAsset *audioAsset = nil;
    NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    if ([url hasPrefix:@"https://"]) {
        audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:dic];
    }else {
        audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:dic];
    }
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}


// 删除音频
- (void)deleteAudio {
    [self.view showLoading];
    NSDictionary *params = @{
        
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/del_sound" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        
        self.voiceRecordView.rerecordingBtn.hidden = YES;
        
        self->isFileUrl = YES;
        
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
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
