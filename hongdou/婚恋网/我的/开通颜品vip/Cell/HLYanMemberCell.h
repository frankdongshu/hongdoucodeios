//
//  HLMemberTableViewCell.h
//  hongdou
//
//  Created by iMac on 2019/11/1.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXBaseTableViewCell.h"
#import "HLMemberModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLYanMemberCellDelegate <NSObject>

-(void)didSelectBuyButtonWithProductID:(NSString *)productID;

@end

@interface HLYanMemberCell : HXBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *payPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orginPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@property (nonatomic, assign) id <HLYanMemberCellDelegate> delegate;

@property (nonatomic, strong) HLMemberModel *memberModel;
@property (strong,nonatomic) NSString * productID;


@end

NS_ASSUME_NONNULL_END
