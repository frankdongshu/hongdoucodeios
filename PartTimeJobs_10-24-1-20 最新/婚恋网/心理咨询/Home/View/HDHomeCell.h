//
//  HDHomeCell.h
//  hongdou
//
//  Created by 李龙 on 2020/3/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSHomeModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    NoneCell, // 默认没有聊天,和红心
    MainCell,
} IsCell;

@protocol CSHomeDelegate <NSObject>

- (void)followButtonClick;

- (void)chartButtonClick:(NSIndexPath *_Nullable)indexPath;

@end

@interface HDHomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgV; // 照片
@property (weak, nonatomic) IBOutlet UILabel *nameLab; // 名字
@property (weak, nonatomic) IBOutlet UIImageView *sexImgV; // 性别
@property (weak, nonatomic) IBOutlet UILabel *addLab; // 年龄
@property (weak, nonatomic) IBOutlet UILabel *eduLab; // 学历
@property (weak, nonatomic) IBOutlet UILabel *ageLab; // 年龄
@property (weak, nonatomic) IBOutlet UILabel *ziZhiLab;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (assign, nonatomic) IsCell iscell;

@property (nonatomic,assign) id <CSHomeDelegate>delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) CSHomeModel *homeMod;

@end

NS_ASSUME_NONNULL_END
