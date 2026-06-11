//
//  HLWishTopCell.h
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HLWishTopCellDelegate <NSObject>

- (void)goExchangeVC;
- (void)refeshData;
- (void)goAddressVC;
- (void)goBuyVC;

@end

@interface HLWishTopCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *shengyuLab;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLab;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSDictionary *dataDic;

@property (nonatomic, assign) id <HLWishTopCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
