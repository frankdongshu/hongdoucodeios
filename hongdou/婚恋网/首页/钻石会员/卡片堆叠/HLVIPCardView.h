//
//  HLVIPCardView.h
//  hongdou
//
//  Created by 维康1 on 2020/9/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLVIPCardViewDelegate <NSObject>

///分享回调
- (void)shareVipClick;

///聊天回调
- (void)chatVipClick;

///关注回调
- (void)followVipClick;

///设置回调
- (void)settingVipClick;

@end

@interface HLVIPCardView : UIView

@property (nonatomic, assign) id<HLVIPCardViewDelegate>delegate;

+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLVIPCardViewDelegate>)delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgView;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property (weak, nonatomic) IBOutlet UILabel *xingZuoLab;
@property (weak, nonatomic) IBOutlet UILabel *xueLiLab;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *listenLab;

@end

NS_ASSUME_NONNULL_END
