//
//  XBZKeyBoardGreetListView.h
//  hongdou
//
//  Created by iMac on 2019/11/8.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XBZKeyBoardGreetListViewDelegate <NSObject>

// 问候句 选择
- (void)chatGreetDidSelectItemWithTitle:(NSString *)title index:(NSInteger)index;

// 跳转语句设置界面
- (void)skipGreetingsStatementVC;

// 跳转开通会员界面
- (void)skipOpenVipVC;

@end

@interface XBZKeyBoardGreetListView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<XBZKeyBoardGreetListViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

NS_ASSUME_NONNULL_END
