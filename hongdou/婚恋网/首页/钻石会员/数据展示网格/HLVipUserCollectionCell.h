//
//  HLVipUserCollectionCell.h
//  hongdou
//
//  Created by 维康1 on 2020/8/21.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HLVipUserCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *heightLab;
@property (weak, nonatomic) IBOutlet UILabel *addLab;
@property (weak, nonatomic) IBOutlet UILabel *schoolLab;

@end

NS_ASSUME_NONNULL_END
