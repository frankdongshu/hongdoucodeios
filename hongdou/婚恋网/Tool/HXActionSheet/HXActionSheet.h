//
//  HXActionSheet.h
//  HXActionSheet
//
//  Created by iMac on 16/6/1.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//
#import <UIKit/UIKit.h>

@class HXActionSheet;

@protocol HXActionSheetDelegate <NSObject>

@optional

// Called when a button is clicked.
- (void)hxActionSheet:(HXActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)hxAtionSheetCancel:(HXActionSheet *)actionSheet;

@end

@interface HXActionSheet : UIView

@property (nonatomic,assign) id<HXActionSheetDelegate>delegate;

- (void)show;
- (void)showInView:(UIView *)view;

- (id)initWithTitle:(NSString *)title delegate:(id<HXActionSheetDelegate>)delegate otherButtons:(NSArray *)buttons cancelButton:(NSString *)cancelButton;

- (void)dismissWithAnimate:(BOOL)animate;
@end