//
//  HLRankingCell.h
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLRankingCell : UITableViewCell

@property (nonatomic, strong) UILabel *rankLab;
@property (nonatomic, strong) UIImageView *rankImgV,*imgV;
@property (nonatomic, strong) UILabel *numLab; // 数字排行

@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UILabel *addLab;

@end

NS_ASSUME_NONNULL_END
