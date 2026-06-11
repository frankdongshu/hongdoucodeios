//
//  HLFineViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLFineViewController.h"
#import "JXCategoryTitleVerticalZoomView.h"
#import "HLExchangeViewController.h" // 兑换
#import "LLActivityController.h" // 抽奖
#import "HLFollowViewController.h"
#import "HLYanPinController.h" // 红豆优品
#import "HLFindSoundController.h" // 声缘
#import "HLWishController.h"
#import "HLSquareViewController.h"
#import "HLUserDetailInfoViewController.h"
#import "HLReleaseViewController.h"
#import "HLTopicController.h" // 有奖话题
#import "HLDreamLoverDesView.h" // 提示框
#import "HLUploadSoundController.h" // 发布声缘
#import "HLShortVideoController.h"
#import "HXXinLiViewController.h" // 情感咨询
#import "HLAlertOpenVipView.h" // 开会员弹窗
#import "HLOpenMemberViewController.h"

@interface HLFineViewController ()
<JXCategoryViewDelegate,JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) JXCategoryTitleVerticalZoomView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) HLSquareViewController *squareViewController;
@property (nonatomic, strong) HLFollowViewController *folloeViewController;
@property (nonatomic, strong) HLYanPinController *yanPinViewController; // 红豆优品
@property (nonatomic, strong) HLFindSoundController *soundViewController; // 声缘
@property (nonatomic, strong) HLWishController *wishController; // 心愿
@property (nonatomic, strong) HLShortVideoController *shortVideoController;
@property (nonatomic, strong) LLActivityController *activityController;
@property (nonatomic, strong) HLExchangeViewController *exchangeViewController;
@property (nonatomic, strong) HLTopicController *topicViewController;
@property (nonatomic, strong) HXXinLiViewController *xinLiViewController;

@property (nonatomic, strong) HXBarButtonItem *rightBarItem, *topicRightItem;

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *titleVCArray;
@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;

@end

@implementation HLFineViewController

- (HXBarButtonItem *)topicRightItem {
    if (!_topicRightItem) {
        
        @weakify(self);
        _topicRightItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sheng_mai"] style:HXBarButtonItemStylePlain handler:^(id sender) {
            
            @strongify(self);
            
            if (!self.isLogin) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                
            } else {
                
                HLUploadSoundController *vc = [[HLUploadSoundController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            
        }];
    }
    return _topicRightItem;
}

// 提示信息
- (void)weiHaoClick {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"sign":@"toc",
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [MBProgressHUD hideLoading];
            
            HLDreamLoverDesView *dView = [[HLDreamLoverDesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:dictionary[@"data"][@"val"]];
            
            dView.SelectBlock = ^{
                
            };
            
            dView.CloseBlock = ^{
                
                [self requestTopicList];
                
            };
            
            [dView showSelf];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 话题列表(获取当期话题)
- (void)requestTopicList {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/toclikes" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            HLReleaseViewController *releaseVC = [[HLReleaseViewController alloc] init];
            
            NSArray *arr = dictionary[@"data"][@"now"];
            releaseVC.fabuString = [NSString stringWithFormat:@"#%@#",[arr firstObject][@"name"]];
            releaseVC.fabuId = [arr firstObject][@"id"];
            
            releaseVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:releaseVC animated:YES];
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

/**
 点击选中或者滚动选中都会调用该方法。适用于只关心选中事件，不关心具体是点击还是滚动选中的。

 @param categoryView categoryView对象
 @param index 选中的index
 */
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    
    if (index == 3) {
        self.sc_navigationBar.rightBarButtonItem = self.topicRightItem;
    } else {
        self.sc_navigationBar.rightBarButtonItem = self.rightBarItem;
    }
    
    [self.categoryView reloadCellAtIndex:index];
    
}

-(void)loadView
{
    [super loadView];
    
    @weakify(self);
    self.rightBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_camera"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        
        if (!self.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
            
//            HLAlertOpenVipView *aView = [[HLAlertOpenVipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:@"点击确定成为VIP会员可发布动态低至1.5元/月"];
//            WeakSelf(self);
//                    aView.SelectBlock = ^{
//                        // 跳转购买会员界面
//                        [self pushBuyVipClick];
//                    };
//
//                    [aView showSelf];
            
        } else {
            
            // 判断是不是 vip 如何是vip 直接进入 如果不是 弹窗
            if (!self.isVip) {
                
                HLAlertOpenVipView *aView = [[HLAlertOpenVipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:@"会员可发布动态。1.5元/月"];
                        aView.SelectBlock = ^{
                            // 跳转购买会员界面
                            [self __pushBuyVipClick];

                        };
                        
                        [aView showSelf];
                
            }else{
                HLReleaseViewController *releaseVC = [[HLReleaseViewController alloc] init];
                releaseVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:releaseVC animated:YES];
            }
            
        }

        
    }];
    
}

-(void)__pushBuyVipClick{
    
    HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
    openVC.rewardVideoAd = self.rewardVideoAd;
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    [HXNavigationController createNavigationBarForViewController:self];
    
    // 添加监听
    [self addNotification];
    
//    self.titleArray = [NSMutableArray arrayWithArray:@[@"广场",@"关注",@"红豆优品",@"声缘",@"心愿",@"小视频"]];
    //todo 根据需求修改隐藏
    self.titleArray = [NSMutableArray arrayWithArray:@[@"广场",@"关注"]];
    self.titleVCArray = [NSMutableArray arrayWithArray:@[self.squareViewController,self.folloeViewController,self.yanPinViewController,self.soundViewController,self.wishController,self.shortVideoController]];
//
//    self.titleVCArray = [NSMutableArray arrayWithArray:@[self.squareViewController,self.folloeViewController]];
//
    if (!self.isLogin) {
        
        [self.titleArray removeObjectsInArray:@[@"关注",@"红豆优品",@"声缘",@"心愿",@"小视频"]];
        [self.titleVCArray removeObjectsInArray:@[self.folloeViewController, self.yanPinViewController, self.soundViewController,self.wishController,self.shortVideoController]];
    }
    
    [self createNavigationView];

    self.sc_navigationBar.rightBarButtonItem =  self.rightBarItem;
    

}

// 添加监听
- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeLoginVC) name:DismissLoginView object:nil];
    
    
}

- (void)closeLoginVC {
    
    [self.titleArray removeAllObjects];
    [self.titleVCArray removeAllObjects];
    
    if (self.isLogin) {
        [self.tabBarController setSelectedIndex:0];
        
//        [self.titleArray addObjectsFromArray:@[@"广场", @"关注", @"红豆优品", @"声缘",@"心愿",@"小视频"]];
        //todo 根据需求修改隐藏
        [self.titleArray addObjectsFromArray:@[@"广场", @"关注"]];
        
//        [self.titleVCArray addObjectsFromArray:@[self.squareViewController,self.folloeViewController,self.yanPinViewController,self.soundViewController,self.wishController,self.shortVideoController]];
        [self.titleVCArray addObjectsFromArray:@[self.squareViewController,self.folloeViewController]];
        
    } else {
        
        [self.titleArray addObjectsFromArray:@[@"广场"]];
        
        [self.titleVCArray addObjectsFromArray:@[self.squareViewController]];
    }
    
    [self.categoryView reloadData];
    
    
    [self.categoryView selectItemAtIndex:0];
    
}


- (void)createNavigationView{
    
    //初始化JXCategoryListContainerView
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight - kTabBarHeight);
    [self.view addSubview:self.listContainerView];
    
    self.categoryView = [[JXCategoryTitleVerticalZoomView alloc] init];
    self.categoryView.listContainer = self.listContainerView;
    self.categoryView.frame = CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavigationBarHeight - kStatusBarHeight);
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.titles = self.titleArray;
    self.categoryView.delegate = self;
    self.categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    self.categoryView.titleLabelVerticalOffset = -5;
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.titleColor = [UIColor darkGrayColor];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.contentEdgeInsetLeft = 15;    //设置内容左边距
    //推荐配置方案
    self.categoryView.maxVerticalCellSpacing = 20;
    self.categoryView.minVerticalCellSpacing = 10;
    self.categoryView.maxVerticalFontScale = 1.3;
    self.categoryView.minVerticalFontScale = 1.3;
    //你可以试试下面的配置方案
    /*
    self.categoryView.maxVerticalCellSpacing = 20;
    self.categoryView.minVerticalCellSpacing = 20;
    self.categoryView.maxVerticalFontScale = 2;
    self.categoryView.minVerticalFontScale = 1;
     */
    [self.sc_navigationBar addSubview:self.categoryView];
    
}
- (void)listScrollViewDidScroll:(UIScrollView *)scrollView {
    if (!(scrollView.isTracking || scrollView.isDecelerating)) {
        //用户交互引起的滚动才处理
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
//            for (id<JXCategoryListContentViewDelegate>list in self.listContainerView.validListDict.allValues) {
//                if ([list listScrollView] != scrollView) {
//                    [[list listScrollView] setContentOffset:CGPointZero animated:NO];
//                }
//            }
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
    
    return self.titleVCArray[index];
    
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

// 红豆优品
- (HLYanPinController *)yanPinViewController{
    if (!_yanPinViewController) {
        _yanPinViewController = [[HLYanPinController alloc] initWithNibName:@"HLYanPinController" bundle:nil];
        [self addChildViewController:_yanPinViewController];
    }
    return _yanPinViewController;
}

// 声缘
- (HLFindSoundController *)soundViewController {
    if (!_soundViewController) {
        _soundViewController = [[HLFindSoundController alloc] init];
        [self addChildViewController:_soundViewController];
    }
    return _soundViewController;
}

- (HLWishController *)wishController {
    if (!_wishController) {
        _wishController = [[HLWishController alloc] init];
        [self addChildViewController:_wishController];
    }
    return _wishController;
}

- (HLShortVideoController *)shortVideoController {
    if (!_shortVideoController) {
        _shortVideoController = [[HLShortVideoController alloc] init];
        [self addChildViewController:_shortVideoController];
    }
    return _shortVideoController;
}


- (LLActivityController *)activityController{
    if (!_activityController) {
        _activityController = [[LLActivityController alloc] init];
        [self addChildViewController:_activityController];
    }
    return _activityController;
}

- (HLExchangeViewController *)exchangeViewController{
    if (!_exchangeViewController) {
        _exchangeViewController = [[HLExchangeViewController alloc] init];
        [self addChildViewController:_exchangeViewController];
    }
    return _exchangeViewController;
}

// 有奖话题
- (HLTopicController *)topicViewController{
    if (!_topicViewController) {
        _topicViewController = [[HLTopicController alloc] init];
        [self addChildViewController:_topicViewController];
    }
    return _topicViewController;
}

// 情感咨询
- (HXXinLiViewController *)xinLiViewController {
    if (!_xinLiViewController) {
        _xinLiViewController = [[HXXinLiViewController alloc] init];
        [self addChildViewController:_xinLiViewController];
    }
    return _xinLiViewController;
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
