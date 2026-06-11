//
//  HLCenterView.h
//  婚恋网
//
//  Created by iMac on 2019/3/24.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HLCenterViewDeleagte <NSObject>

- (void)verityButtonClick;
- (void)sureButtonClick;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLCenterView : UIView

@property (nonatomic,assign) id <HLCenterViewDeleagte,UITextFieldDelegate>delegate;


@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTF;
@property (weak, nonatomic) IBOutlet UITextField *verityTF;


@property (weak, nonatomic) IBOutlet UIButton *verityBtn;

@property (weak, nonatomic) IBOutlet UIButton *sureButton;

+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLCenterViewDeleagte,UITextFieldDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
