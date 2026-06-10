//
//  CoachHeadCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CoachHeadCellDeleagte <NSObject>

- (void)photoImgViewClick:(UITapGestureRecognizer *)tap;

@end

@interface CoachHeadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *cityLab;
@property (weak, nonatomic) IBOutlet UILabel *sexLab;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property (weak, nonatomic) IBOutlet UILabel *geYanLab;

@property (nonatomic,assign) id <CoachHeadCellDeleagte>delegate;

@end

NS_ASSUME_NONNULL_END
