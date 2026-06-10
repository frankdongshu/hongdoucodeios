//
//  LLFindJiaJiaoCell.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLFaBuModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLFindJiaJiaoCell : UITableViewCell

@property (nonatomic, strong) LLFaBuModel *model;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *tagLab;
@property (weak, nonatomic) IBOutlet UILabel *descLab;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;


@end

NS_ASSUME_NONNULL_END
