//
//  HLTopicHeaderView.h
//  hongdou
//
//  Created by 维康1 on 2020/12/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLTopicHeaderViewDelegate <NSObject>

- (void)tableViewHeaderImgHeightWith:(float)imgHeight;

@end

@interface HLTopicHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *peopleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@property (strong, nonatomic) YYLabel *peopleNumLab;
@property (strong, nonatomic) UILabel *timeLab;
@property (nonatomic,strong) NSTimer *timer; // 定时器


@property (nonatomic, assign) id<HLTopicHeaderViewDelegate>delegate;
+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLTopicHeaderViewDelegate>)delegate;

@property (strong, nonatomic) NSDictionary *contentDic;

@end

NS_ASSUME_NONNULL_END
