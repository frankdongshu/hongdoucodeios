//
//  HLNewChatViewController.h
//  hongdou
//
//  Created by iMac on 2019/11/5.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"
//#import "JCHATToolBar.h"
//#import "JCHATMoreView.h"
#import "JCHATRecordAnimationView.h"
#import "JCHATChatModel.h"
#import "XHVoiceRecordHUD.h"
#import "XHVoiceRecordHelper.h"
//#import "JCHATVoiceTableViewCell.h"
#import "JCHATMessageTableView.h"
#import "JCHATMessageTableViewCell.h"
#import "JCHATPhotoPickerViewController.h"



NS_ASSUME_NONNULL_BEGIN

@interface HLNewChatViewController : HXBaseViewController
// 是否为心理咨询进入
@property (nonatomic, assign) BOOL isXinLiVC;

@property(strong, nonatomic) JMSGConversation *conversation;

@property (copy, nonatomic) NSString *userName;
- (void)setupView;
- (void)prepareImageMessage:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
