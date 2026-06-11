//
//  CSHomeTableViewCell.h
//  CSPartTimeJobs
//
//  Created by 这是一个笑脸 on 2019/7/18.
//  Copyright © 2019 FangPursuit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    CityType,
    GradeType,
    ChosseType,
    ChosseCity,
    ChosseKeCheng,
    FaBuShouKe,
} CellType;

typedef void(^DidSeleCell)(NSInteger cuid,NSString *title);
@interface CSHomeTableViewCell : UITableViewCell
@property (nonatomic, strong) NSMutableArray *dataMuArray;
@property (nonatomic, assign) CellType cellType;
@property (nonatomic, copy) DidSeleCell seleBlock;

@property (nonatomic, strong) NSArray *seleArray;

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface CSHomeCollectionCell : UICollectionViewCell
@property (nonatomic,strong) UILabel *nameLabel;
-(void)seleCell:(BOOL)sele;

@end

NS_ASSUME_NONNULL_END

