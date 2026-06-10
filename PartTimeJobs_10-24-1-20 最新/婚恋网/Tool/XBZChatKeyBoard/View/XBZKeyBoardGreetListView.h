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

@end

@interface XBZKeyBoardGreetListView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<XBZKeyBoardGreetListViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

NS_ASSUME_NONNULL_END
