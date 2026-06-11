//
//  HLShowPreviousView.h
//  hongdou
//
//  Created by user on 2022/8/12.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLShowPreviousViewDelegate <NSObject>

- (void)previousListWithId:(NSString *)aid;

@end

@interface HLShowPreviousView : UIView

@property (nonatomic, assign) id <HLShowPreviousViewDelegate>delegate;

@property (nonatomic, copy) void(^SelectBlock)(NSString *);

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
