//
//  HLChatGifPopView.h
//  hongdou
//
//  Created by user on 2022/4/13.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLChatGifPopView : UIView

@property (nonatomic, copy) void(^SelectBlock)(NSString *);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
