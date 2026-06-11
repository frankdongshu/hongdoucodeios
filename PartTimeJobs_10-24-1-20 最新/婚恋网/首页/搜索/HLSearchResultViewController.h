//
//  HLSearchResultViewController.h
//  hongdou
//
//  Created by iMac on 2019/10/30.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXPullRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLSearchResultViewController : HXPullRefreshViewController

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSDictionary *requestDic;


@end

NS_ASSUME_NONNULL_END
