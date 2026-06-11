//
//  LLBuyVipCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/17.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLBuyVipModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LLBuyVipCellDelegate <NSObject>

- (void)didSelectBuyButtonWithProductID:(NSString *)productID;

@end

@interface LLBuyVipCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dayLab;
@property (weak, nonatomic) IBOutlet UILabel *priceLab;
@property (weak, nonatomic) IBOutlet UIButton *goBtn;

@property (nonatomic, strong) LLBuyVipModel *theModel;
@property (nonatomic, assign) id <LLBuyVipCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
