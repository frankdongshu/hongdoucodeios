//
//  HLFriendsTopView.h
//  hongdou
//
//  Created by iMac on 2019/10/16.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HLFriendsTopViewDeleagte <NSObject>

- (void)photoImgViewClick:(UITapGestureRecognizer *)tap;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HLFriendsTopView : UITableViewCell

@property (nonatomic,strong)HLUser *friensModel;
@property (nonatomic,strong)HLSoundModel *soundModel;

@property (nonatomic,assign) id <HLFriendsTopViewDeleagte>delegate;

@end

NS_ASSUME_NONNULL_END
