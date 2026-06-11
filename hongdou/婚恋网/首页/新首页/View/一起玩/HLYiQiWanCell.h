//
//  HLYiQiWanCell.h
//  hongdou
//
//  Created by 李龙 on 2020/7/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKTagView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLYiQiWanCellDelegate <NSObject>

- (void)reloadYiQiPlayWithDataDic:(NSDictionary *)dic;

- (void)pushYiQiWanVipClick;

@end

@interface HLYiQiWanCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SKTagView *tagView;

@property (nonatomic, assign) id <HLYiQiWanCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
