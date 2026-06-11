//
//  HLFriendsAlbunTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FriendsAlbumDelegate <NSObject>

- (void)browerPhotoClick:(NSArray *)picArrs withCurrentIndex:(NSInteger)index;

@end

@interface HLFriendsAlbunTableViewCell : UITableViewCell

@property (nonatomic,assign) id <FriendsAlbumDelegate>delegate;

@property (nonatomic, strong) NSArray *photosArray;

@property(nonatomic ,weak) UIViewController      *weakSelf;


@end

NS_ASSUME_NONNULL_END
