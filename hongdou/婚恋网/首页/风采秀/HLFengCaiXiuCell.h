//
//  HLFengCaiXiuCell.h
//  hongdou
//
//  Created by user on 2022/8/3.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLFengCaiXiuCellDelegate <NSObject>

- (void)likeUpdateList;

@end

@interface HLFengCaiXiuCell : UITableViewCell

@property (nonatomic, assign) id <HLFengCaiXiuCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *addLab;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBg;
@property (weak, nonatomic) IBOutlet UILabel *likeLab;
@property (weak, nonatomic) IBOutlet UIImageView *rankImgV;

@property (strong, nonatomic) NSDictionary *dic;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;

@end

NS_ASSUME_NONNULL_END
