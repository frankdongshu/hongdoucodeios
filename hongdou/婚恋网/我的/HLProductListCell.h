//
//  HLProductListCell.h
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_CollectionViewCell @"HLProductListCell"

@class HLExchangeModel;

NS_ASSUME_NONNULL_BEGIN

@protocol HLProductListCellDelegate <NSObject>

- (void)didSelectBuyButtonWithIdx:(NSInteger)productIdx;

@end

@interface HLProductListCell : UICollectionViewCell

@property (nonatomic, assign) id <HLProductListCellDelegate> delegate;

@property (nonatomic, strong) HLExchangeModel *model;

@property (nonatomic, strong) UIButton *buyBtn;

@end

NS_ASSUME_NONNULL_END
