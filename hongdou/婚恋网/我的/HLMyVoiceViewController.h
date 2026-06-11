//
//  HLMyVoiceViewController.h
//  婚恋网
//
//  Created by iMac on 2019/7/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^EditVoiceBlock)(NSString *voiceStr);

@interface HLMyVoiceViewController : HXBaseViewController

@property (nonatomic, copy) NSString *myVoiceString;

@property (nonatomic, copy) EditVoiceBlock editVoiceBlock;

@end

NS_ASSUME_NONNULL_END
