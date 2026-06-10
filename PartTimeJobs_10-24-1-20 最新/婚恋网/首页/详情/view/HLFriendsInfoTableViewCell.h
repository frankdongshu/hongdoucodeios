//
//  HLFriendsInfoTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/10/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLFriendsInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backGroundView;

@property (nonatomic, strong) NSArray *dataArray;

@end

NS_ASSUME_NONNULL_END
