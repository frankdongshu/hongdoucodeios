//
//  HLShowAddPhotoView.h
//  hongdou
//
//  Created by user on 2022/8/11.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLShowAddPhotoViewDelegate <NSObject>

- (void)addPhotoClick;

- (void)updateList;

@end

@interface HLShowAddPhotoView : UIView

@property (nonatomic, assign) id <HLShowAddPhotoViewDelegate>delegate;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UIImageView *addImg;

@property (nonatomic, strong) UILabel *lab1, *lab2;

@property (nonatomic, strong) UIButton *delBtn, *selbtn;

@property (nonatomic, strong) NSString *url;

-(void)showSelf;
-(void)removeSelf;

@end

NS_ASSUME_NONNULL_END
