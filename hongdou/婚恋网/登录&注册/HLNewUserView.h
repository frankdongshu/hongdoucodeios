//
//  HLNewUserView.h
//  hongdou
//
//  Created by 维康1 on 2021/1/18.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLNewUserViewDeleagte <NSObject>

- (void)sureButtonClick;

@end

@interface HLNewUserView : UIView

@property (nonatomic,assign) id <HLNewUserViewDeleagte>delegate;

+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLNewUserViewDeleagte>)delegate;

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
