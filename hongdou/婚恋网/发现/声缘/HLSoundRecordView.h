//
//  HLSoundRecordView.h
//  hongdou
//
//  Created by 李龙 on 2021/12/13.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PIVoiceRecordViewState)
{
    PIVoiceRecordViewStateReady = 0, ///<准备状态
    PIVoiceRecordViewStateRecording = 1, ///<录制状态
    PIVoiceRecordViewStateReplaying =2, ///<播放状态
    PIVoiceRecordViewStateFinish =3, ///<录制完成状态
    PIVoiceRecordViewStatePause =4, ///暂停播放
};

NS_ASSUME_NONNULL_BEGIN

@protocol HLSoundRecordViewDelegate <NSObject>

@optional;
/**
 改变录制状态

 @param start 开始/结束
 */
- (void)voiceRecordViewRecordAction:(BOOL)start;


/**
 开始录制
 */
- (void)voiceRecordViewStartReplaying;


/**
 暂停
 */
- (void)voiceRecordViewPause:(BOOL)pause;

/**
 停止播放
 */
- (void)voiceStopPlaying;

/// 确定
- (void)voiceConfirmPlayingWithTimeText:(NSInteger)sec;


/**
 完成录制
 */
- (void)voiceRecordViewFinishRecording;


/**
 重新录制
 */
- (void)voiceRecordViewStartReRecording;

@end

@interface HLSoundRecordView : UIView

@property (nonatomic, assign) PIVoiceRecordViewState state;

@property (nonatomic, weak) id<HLSoundRecordViewDelegate>delegate;

- (void)updateState:(PIVoiceRecordViewState)state seconds:(NSUInteger)seconds; //更新录制状态

@end

NS_ASSUME_NONNULL_END
