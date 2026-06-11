//
//  HLWishListController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLWishListController.h"
#import "XXPageTabView.h"
#import "HLFinishWishController.h"
#import "HLAllWishController.h"

@interface HLWishListController ()<XXPageTabViewDelegate>

{
    XXPageTabView *_pageTabView;
}

@end

@implementation HLWishListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"心愿";
    
    
    // 1.全部
    HLAllWishController *title_0VC = [[HLAllWishController alloc] init];
    
    // 2.已完成
    HLFinishWishController *title_1VC = [[HLFinishWishController alloc] init];

    [self addChildViewController:title_0VC];
    [self addChildViewController:title_1VC];
    
    _pageTabView = [[XXPageTabView alloc] initWithChildControllers:self.childViewControllers childTitles:@[@"全部", @"已完成"]];
    _pageTabView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight);
    _pageTabView.tabSize = CGSizeMake(kScreenWidth, 44);
    _pageTabView.tabItemFont = [UIFont systemFontOfSize:15];
    _pageTabView.unSelectedColor = [UIColor blackColor];
    _pageTabView.selectedColor = [UIColor blackColor];
    _pageTabView.bodyBounces = NO;
    _pageTabView.titleStyle = XXPageTabTitleStyleDefault;
    _pageTabView.indicatorStyle = XXPageTabIndicatorStyleDefault;
    _pageTabView.indicatorWidth = 21;
    _pageTabView.delegate = self;
    [self.view addSubview:_pageTabView];
}

#pragma mark - XXPageTabViewDelegate
- (void)pageTabViewDidEndChange {
    NSInteger selectedTabIndex = _pageTabView.selectedTabIndex;
    NSLog(@"点击了index：%zd", selectedTabIndex);

    switch (selectedTabIndex) {
        case 0:
        {
            // 我的好友
        }
            break;
        case 1:
        {
            // 通讯录
        }
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
