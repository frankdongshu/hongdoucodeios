//
//  HXPullRefreshViewController.h
//  HXNavigationController
//
//  Created by iMac on 16/7/22.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "HXBaseViewController.h"

@protocol HXPullRefreshDelegate <NSObject>

- (void)loadNewData;

- (void)loadMoreData;

@end

@interface HXPullRefreshViewController : HXBaseViewController <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,HXPullRefreshDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) CGFloat tableViewInsertTop;
@property (nonatomic, assign) CGFloat tableViewInsertBottom;

- (void)didReceiveThemeChangeNotification;
@end
