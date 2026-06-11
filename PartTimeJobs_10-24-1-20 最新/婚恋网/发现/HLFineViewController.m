//
//  HLFineViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLFineViewController.h"
#import "JXCategoryTitleVerticalZoomView.h"
#import "LLActivityController.h" // 抽奖
#import "HLFollowViewController.h"
#import "HLSquareViewController.h"
#import "HLUserDetailInfoViewController.h"
#import "HLReleaseViewController.h"

@interface HLFineViewController ()
<JXCategoryViewDelegate,JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) JXCategoryTitleVerticalZoomView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) HLSquareViewController *squareViewController;
@property (nonatomic, strong) HLFollowViewController *folloeViewController;
//@property (nonatomic, strong) LLActivityController *activityController;
//@property (nonatomic, strong) HLExchangeViewController *exchangeViewController;

@property (nonatomic, strong) HXBarButtonItem *rightBarItem; 
@end

@implementation HLFineViewController

-(void)loadView
{
    [super loadView];
    
    @weakify(self);
    self.rightBarItem = [[HXBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"navi_camera"] imageWithColor:REDColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        
        if (!self.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
            
        } else {
            HLReleaseViewController *releaseVC = [[HLReleaseViewController alloc] init];
            releaseVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:releaseVC animated:YES];
        }

        
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [HXNavigationController createNavigationBarForViewController:self];
    [self createNavigationView];

    self.sc_navigationBar.rightBarButtonItem =  self.rightBarItem;


}


- (void)createNavigationView{
    self.categoryView = [[JXCategoryTitleVerticalZoomView alloc] init];
    self.categoryView.frame = CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavigationBarHeight - kStatusBarHeight);
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.titles = @[@"广场", @"关注"];
    self.categoryView.delegate = self;
    self.categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    self.categoryView.titleLabelVerticalOffset = 0;
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.titleSelectedColor = [UIColor colorWithHex:0x3F4658];
    self.categoryView.contentEdgeInsetLeft = 30;
    self.categoryView.cellSpacing = 40;
    self.categoryView.maxVerticalCellSpacing = 30;
    self.categoryView.minVerticalCellSpacing = 20;
    self.categoryView.maxVerticalFontScale = 1.4;
    self.categoryView.minVerticalFontScale = 1;
    self.categoryView.maxVerticalContentEdgeInsetLeft = 30;
    self.categoryView.minVerticalContentEdgeInsetLeft = 15;
    [self.sc_navigationBar addSubview:self.categoryView];
    
    //初始化JXCategoryListContainerView
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithDelegate:self];
    self.listContainerView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight - kTabBarHeight);
    self.listContainerView.didAppearPercent = 0.01; //滚动一点就触发加载
    self.listContainerView.defaultSelectedIndex = 0;
    [self.view addSubview:self.listContainerView];
    //关联cotentScrollView，关联之后才可以互相联动！！！
    self.categoryView.contentScrollView = self.listContainerView.scrollView;
}
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView {
    if (!(scrollView.isTracking || scrollView.isDecelerating)) {
        //用户交互引起的滚动才处理
        return;
    }
    if (self.categoryView.isHorizontalZoomTransitionAnimating) {
        //当前cell正在进行动画过渡
        return;
    }
    //用于垂直方向滚动时，视图的frame调整
    if ((self.categoryView.bounds.size.height < kNavigationBarHeight) && scrollView.contentOffset.y < 0) {
        //当前属于缩小状态且往下滑动
        //列表往下移动、categoryView高度增加
        CGRect categoryViewFrame = self.categoryView.frame;
        categoryViewFrame.size.height -= scrollView.contentOffset.y;
        categoryViewFrame.size.height = MIN(kNavigationBarHeight, categoryViewFrame.size.height);
        self.categoryView.frame = categoryViewFrame;
        
        self.listContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.categoryView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.categoryView.frame));
        
        if (self.categoryView.bounds.size.height == kNavigationBarHeight) {
            //从小缩放到最大，将其他列表的contentOffset重置
            for (id<JXCategoryListContentViewDelegate>list in self.listContainerView.validListDict.allValues) {
                if ([list listScrollView] != scrollView) {
                    [[list listScrollView] setContentOffset:CGPointZero animated:NO];
                }
            }
        }
        
        scrollView.contentOffset = CGPointZero;
    }else if (((self.categoryView.bounds.size.height < kNavigationBarHeight) && scrollView.contentOffset.y >= 0 && self.categoryView.bounds.size.height > kNavigationBarHeight) ||
              (self.categoryView.bounds.size.height >= kNavigationBarHeight && scrollView.contentOffset.y >= 0)) {
        //当前属于缩小状态且往上滑动且categoryView的高度大于minCategoryViewHeight 或者 当前最大高度状态且往上滑动
        //列表往上移动、categoryView高度减小
        CGRect categoryViewFrame = self.categoryView.frame;
        categoryViewFrame.size.height -= scrollView.contentOffset.y;
        categoryViewFrame.size.height = MAX(kNavigationBarHeight, categoryViewFrame.size.height);
        self.categoryView.frame = categoryViewFrame;
        
        self.listContainerView.frame = CGRectMake(0, CGRectGetMaxY(self.categoryView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.categoryView.frame));
        
        scrollView.contentOffset = CGPointZero;
    }
    
    //必须调用
    CGFloat percent = (self.categoryView.bounds.size.height - kNavigationBarHeight)/(kNavigationBarHeight - kNavigationBarHeight);
    [self.categoryView listDidScrollWithVerticalHeightPercent:percent];
}

#pragma mark - JXCategoryViewDelegate
//传递didClickSelectedItemAt事件给listContainerView，必须调用！！！
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
    [self.listContainerView didClickSelectedItemAtIndex:index];
}
//传递scrolling事件给listContainerView，必须调用！！！
- (void)categoryView:(JXCategoryBaseView *)categoryView scrollingFromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex ratio:(CGFloat)ratio {
    [self.listContainerView scrollingFromLeftIndex:leftIndex toRightIndex:rightIndex ratio:ratio selectedIndex:categoryView.selectedIndex];
}

#pragma mark - JXCategoryListContainerViewDelegate
//返回遵从`JXCategoryListContentViewDelegate`协议的实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    if (index==0) {
        return self.squareViewController;
    } else {
        return self.folloeViewController;
    }
}
//返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}

#pragma mark 懒加载
- (HLSquareViewController *)squareViewController{
    if (!_squareViewController) {
        _squareViewController = [[HLSquareViewController alloc] init];
        [self addChildViewController:_squareViewController];
    }
    return _squareViewController;
}

- (HLFollowViewController *)folloeViewController{
    if (!_folloeViewController) {
        _folloeViewController = [[HLFollowViewController alloc] init];
        [self addChildViewController:_folloeViewController];
    }
    return _folloeViewController;
}

//- (LLActivityController *)activityController{
//    if (!_activityController) {
//        _activityController = [[LLActivityController alloc] init];
//        [self addChildViewController:_activityController];
//    }
//    return _activityController;
//}
//
//- (HLExchangeViewController *)exchangeViewController{
//    if (!_exchangeViewController) {
//        _exchangeViewController = [[HLExchangeViewController alloc] init];
//        [self addChildViewController:_exchangeViewController];
//    }
//    return _exchangeViewController;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
