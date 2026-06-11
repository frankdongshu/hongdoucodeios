//
//  LLActivityCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/19.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLActivityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
@property (weak, nonatomic) IBOutlet UILabel *explainLab;
@property (weak, nonatomic) IBOutlet UILabel *awardNumLab;

- (void)setActivityInfo:(LLActivityModel *)actModel withCurrentIndex:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
