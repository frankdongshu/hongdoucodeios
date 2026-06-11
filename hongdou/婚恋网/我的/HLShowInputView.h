//
//  HLShowInputView.h
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SubmissBlock)(NSString *str);

@interface HLShowInputView : UIView

@property (copy, nonatomic) SubmissBlock submissBlock;

//快速创建
+(instancetype)popInputView;
//弹出
-(void)show;

@end

NS_ASSUME_NONNULL_END
