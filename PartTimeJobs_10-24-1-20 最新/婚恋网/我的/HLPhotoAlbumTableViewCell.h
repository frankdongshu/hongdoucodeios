//
//  HLPhotoAlbumTableViewCell.h
//  婚恋网
//
//  Created by iMac on 2019/5/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLPhotoAlbumDeleagte <NSObject>

- (void)photoDeleteClick:(NSString *)sender;
- (void)photoAddClick:(NSString *)sender;

@end

@interface HLPhotoAlbumTableViewCell : UITableViewCell

@property (nonatomic,assign) id <HLPhotoAlbumDeleagte>delegate;


@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fristImageView;

@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;

@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;

@property (nonatomic, strong) HLUser *userModel;


@end

NS_ASSUME_NONNULL_END
