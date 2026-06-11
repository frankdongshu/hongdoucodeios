//
//  HLHomeViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLHomeViewController.h"
#import "JXCategoryTitleVerticalZoomView.h"
//#import "HXRecommendViewController.h"
//#import "HLNearbyViewController.h"
//#import "HLBeanSelectionViewController.h"
#import "HXXinLiViewController.h" // 心理咨询
#import "HLLoginViewController.h"
#import "HLUserDetailInfoViewController.h"
#import "HLSearchViewController.h"
#import "XinLiViewController.h" // 心理咨询TabBarController
#import "CSHomeCityViewController.h" // 城市选择
#import "CSUserInfoViewController.h" // 信息填写
#import "CSPersonInfoController.h" // 个人信息
#import "CSProjectTypeController.h" // 咨询类型

#import "HLCitySelectorViewController.h" // 居住地

#import "LLFindJiaJiaoController.h" // 找家教

@interface HLHomeViewController ()<JXCategoryViewDelegate,JXCategoryListContainerViewDelegate,JMessageDelegate>
{
    BOOL ifNeedUpdatePrefect;
}
@property (nonatomic, strong) JXCategoryTitleVerticalZoomView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
//@property (nonatomic, strong) HXRecommendViewController *recommendViewController;
//@property (nonatomic, strong) HLNearbyViewController *nearbyViewController;
//@property (nonatomic, strong) HLBeanSelectionViewController *beanSelectionViewController;
@property (nonatomic, strong) HXXinLiViewController *xinLiViewController;
@property (nonatomic, strong) LLFindJiaJiaoController *findViewController;

@property (nonatomic, strong) HXBarButtonItem *rightBarItem; 

@end

@implementation HLHomeViewController

-(void)loadView
{
    [super loadView];
    
    ifNeedUpdatePrefect = YES;
    @weakify(self);
    self.rightBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_shaixuan"] style:HXBarButtonItemStylePlain handler:^(id sender) {

        @strongify(self);
        
        if (!self.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
            
        } else {
            HLSearchViewController *searchVC = [[HLSearchViewController alloc] init];
            searchVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:searchVC animated:YES];
        }
        
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [HXNavigationController createNavigationBarForViewController:self];
    [self createNavigationView];
   
//    self.sc_navigationBar.rightBarButtonItem =  self.rightBarItem;
    
    [JMessage addDelegate:self withConversation:nil];

//
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changNeedUpdate) name:SHOWLOGIN object:nil];
//
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushUserDetailInfo) name:ShowDetailInfoView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isPerfectInfo) name:@"isPerfectInfo" object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.isLogin) {
        
        if ([MyLogin userHadLogin]) { // 心理咨询
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            
            if (kISNullObject(u.city)) { // 城市选择
                CSHomeCityViewController *vc = [[CSHomeCityViewController alloc]init];
                vc.cityType = CityNo;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                if (kISNullObject(u.sex)) { // 信息填写
                    CSUserInfoViewController *vc = [[CSUserInfoViewController alloc]init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    if (kISNullObject(u.intelligence) ||
                        kISNullObject(u.education) ||
                        kISNullObject(u.school) ||
                        kISNullObject(u.major) ||
                        kISNullObject(u.descr) ||
                        kISNullObject(u.teaching) ||
                        kISNullObject(u.cost_low)
                        ) {
                        
                        CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
                        vc.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    } else {
                        
                        if (kISNullObject([MyLogin getCurrentLoginUser].curriculum)) {
                            CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
                            vc.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:vc animated:YES];
                        } else {
                            
                            XinLiViewController *vc = [[XinLiViewController alloc] init];
                            vc.modalPresentationStyle = 0;
                            [self presentViewController:vc animated:NO completion:nil];
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
        
    } else {
        
        if (ifNeedUpdatePrefect) {
            ifNeedUpdatePrefect = NO;
            [self loadRequest];
        }
        [self loginJpush];

    }
    
}

- (void)getConversation{
    
    if (self.isLogin) {
        // 获取所有的会话信息
        [JMSGConversation allConversations:^(id resultObject, NSError *error) {
            if (error == nil) {
                NSArray *conversationArr = resultObject;
                
                int unreadNumber = 0;
                
                for (JMSGConversation *con in conversationArr) {
                    
                    unreadNumber = unreadNumber+ [con.unreadCount intValue];
                }
                
                if (unreadNumber <= 0) {
                    [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
                    [JMessage setBadge:0];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0; //角标清零
                } else {
                    [self.tabBarController.tabBar showBadgeOnItemIndex:3];
                    [JMessage setBadge:unreadNumber];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = unreadNumber; //角标清零
                }
                
            } else {
                
            }
        }];
    }
    
}

- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error{
    [self.tabBarController.tabBar showBadgeOnItemIndex:3];
}

// 是否完善信息
- (void)isPerfectInfo {
    if (ifNeedUpdatePrefect) {
        ifNeedUpdatePrefect = NO;
        [self loadRequest];
    }
    [self loginJpush];
    
}

- (void)changNeedUpdate{
    ifNeedUpdatePrefect = YES;
}
- (void)loginJpush{
    [JMSGUser loginWithUsername:[LoginManager defaultManager].account password:@"91110113" completionHandler:^(id resultObject, NSError *error) {
        if (error == nil) {
            NSLog(@"登录信息___%@",resultObject);
            
            [self getConversation];
            
        }else{
//            [self.view showTostWithMessage:@"会话登录失败"];
        }
    }];
}
// 是否已经完善信息
- (void)loadRequest{
    if (!self.isLogin) {
        return;
    }
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLISPerfect withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            // 1 已经完善  0 需要去完善
            if (![[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) {
                [weakSelf pushUserDetailInfo];
            }
        }
    } failure:^(NSError * _Nonnull error) {

    }];

}
// 是否需要先完善个人信息
- (void)pushUserDetailInfo{
//    HLUserDetailInfoViewController *userDetailInfoVC = [[HLUserDetailInfoViewController alloc] init];
//    userDetailInfoVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:userDetailInfoVC animated:YES];
    
    //居住地
    HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
    citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
        [self requestUploadDataWithCityId:model.cityID];
    };
    citySelectVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:citySelectVC animated:YES];
    
}

- (void)requestUploadDataWithCityId:(NSString *)cityId {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"habitation":cityId
    };
    
    [kAppDelegate.window showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserEVPI withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [kAppDelegate.window hideLoading];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateImageOrNickname object:nil];
            // 通知相对界面需要刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [kAppDelegate.window showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showErrorWithMessage:error.localizedDescription];
    }];
    
}

- (void)createNavigationView{
    self.categoryView = [[JXCategoryTitleVerticalZoomView alloc] init];
    self.categoryView.frame = CGRectMake(0, kStatusBarHeight, kScreenWidth, kNavigationBarHeight - kStatusBarHeight);
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.titles = @[@"推荐",@"找家教"];
    self.categoryView.delegate = self;
    self.categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    self.categoryView.titleLabelVerticalOffset = 0;
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.titleSelectedColor = [UIColor colorWithHex:0x3F4658];
    self.categoryView.contentEdgeInsetLeft = 30;
    self.categoryView.cellSpacing = 40;
    self.categoryView.maxVerticalCellSpacing = 30;
    self.categoryView.minVerticalCellSpacing = 20;
    self.categoryView.maxVerticalFontScale = 1.5;
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
        return self.xinLiViewController;
    } else {
        return self.findViewController;
    }
}
//返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}

#pragma mark 懒加载
//- (HXRecommendViewController *)recommendViewController{
//    if (!_recommendViewController) {
//        _recommendViewController = [[HXRecommendViewController alloc] init];
//        [self addChildViewController:_recommendViewController];
//    }
//    return _recommendViewController;
//}
//- (HLNearbyViewController *)nearbyViewController{
//    if (!_nearbyViewController) {
//        _nearbyViewController = [[HLNearbyViewController alloc] init];
//        [self addChildViewController:_nearbyViewController];
//    }
//    return _nearbyViewController;
//}
//- (HLBeanSelectionViewController *)beanSelectionViewController{
//    if (!_beanSelectionViewController) {
//        _beanSelectionViewController = [[HLBeanSelectionViewController alloc] init];
//        [self addChildViewController:_beanSelectionViewController];
//    }
//    return _beanSelectionViewController;
//}

- (HXXinLiViewController *)xinLiViewController {
    if (!_xinLiViewController) {
        _xinLiViewController = [[HXXinLiViewController alloc] init];
        [self addChildViewController:_xinLiViewController];
    }
    return _xinLiViewController;
}

- (LLFindJiaJiaoController *)findViewController {
    if (!_findViewController) {
        _findViewController = [[LLFindJiaJiaoController alloc] init];
        [self addChildViewController:_findViewController];
    }
    return _findViewController;
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
