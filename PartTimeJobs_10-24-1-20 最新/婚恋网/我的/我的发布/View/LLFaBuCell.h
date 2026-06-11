//
//  LLFaBuCell.h
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LLFaBuModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LLFaBuCellDelegate <NSObject>

- (void)removeClickWithIdx:(NSInteger)idx;


@end

@interface LLFaBuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *keChengLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UILabel *biaoQianLab;
@property (weak, nonatomic) IBOutlet UILabel *miaoShuLab;
@property (weak, nonatomic) IBOutlet UILabel *shiJianLab;

@property (nonatomic, assign) id<LLFaBuCellDelegate>delegate;


@property (nonatomic, strong) LLFaBuModel *model;

@end

NS_ASSUME_NONNULL_END
