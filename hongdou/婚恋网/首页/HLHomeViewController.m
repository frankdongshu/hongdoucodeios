//
//  HLHomeViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLHomeViewController.h"
#import "JXCategoryTitleVerticalZoomView.h"

#import "HXRecommendViewController.h" // 推荐
#import "HLVVipViewController.h" // 钻石会员
#import "HLRealHeadViewController.h" // 真人头像
#import "HLNearbyViewController.h" // 附近
#import "HLVirtualLoverViewController.h"// 虚拟爱人
#import "HLCommunityViewController.h" // 社区
//#import "HLYanPinController.h" // 颜品
#import "HLFengCaiXiuViewController.h" // 风采秀

#import "HLSearchViewController.h" // 筛选
#import "HLUserDetailInfoViewController.h" // 详情


#import "HLLoginViewController.h"


#import "CSHomeCityViewController.h" // 城市选择

#import "CSPersonInfoController.h" // 个人信息
#import "CSProjectTypeController.h" // 咨询类型
#import "HLAlertOpenVipView.h" // 开会员弹窗
#import "HLOpenMemberViewController.h" // 开通会员界面
#import "HLReleaseViewController.h" // 发布界面
#import "HLDreamLoverDesView.h" // 提示框

#import "HLNewUserView.h" // 新用户红包提示框

#import "HLPhotoManageViewController.h"

#import "HLNewHomeController.h"

@interface HLHomeViewController ()<JXCategoryViewDelegate,JXCategoryListContainerViewDelegate,HLNewUserViewDeleagte,showRecvMsgDelegate>
{
    BOOL ifNeedUpdatePrefect;
}
@property (nonatomic, strong) JXCategoryTitleVerticalZoomView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) HLVVipViewController *vvipViewController;
@property (nonatomic, strong) HXRecommendViewController *recommendViewController;
@property (nonatomic, strong) HLVirtualLoverViewController *virtualLoverViewController;
@property (nonatomic, strong) HLRealHeadViewController *realViewController;
@property (nonatomic, strong) HLNearbyViewController *nearbyViewController;
@property (nonatomic, strong) HLCommunityViewController *communityViewController;
@property (nonatomic, strong) HLFengCaiXiuViewController *fengCaiViewController;

@property (nonatomic, strong) HLNewHomeController *homeViewController;

@property (nonatomic, strong) HXBarButtonItem *rightBarItem, *topicRightItem;

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) NSMutableArray *titleVCArray;

@property (nonatomic, strong) UIImageView *imgTopView, *imgBottomView;

@end

@implementation HLHomeViewController

// 颜品发布
- (HXBarButtonItem *)topicRightItem {
    if (!_topicRightItem) {
        
        @weakify(self);
        _topicRightItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_camera"] style:HXBarButtonItemStylePlain handler:^(id sender) {
            
            @strongify(self);
            
            if (!self.isLogin) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                
            } else {
                
                HLPhotoManageViewController *vc = [[HLPhotoManageViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.isYanPin = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }];
    }
    return _topicRightItem;
}

// 筛选
- (HXBarButtonItem *)rightBarItem {
    if (!_rightBarItem) {
        
        @weakify(self);
        _rightBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_shaixuan"] style:HXBarButtonItemStylePlain handler:^(id sender) {

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
    return _rightBarItem;
}


- (void)loadView {
    [super loadView];
    
    ifNeedUpdatePrefect = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [HXNavigationController createNavigationBarForViewController:self];
    
    // 添加监听
    [self addNotification];
    
//    self.titleArray = [NSMutableArray arrayWithArray:@[@"邂逅",@"推荐",@"社区",@"风采秀"]];
//
    if (self.isVip) {
        self.titleArray = [NSMutableArray arrayWithArray:@[@"推荐",@"同城",@"虚拟爱人"]];
        self.titleVCArray = [NSMutableArray arrayWithArray:@[self.recommendViewController,self.nearbyViewController,self.virtualLoverViewController]];
    }else{
        
        self.titleArray = [NSMutableArray arrayWithArray:@[@"推荐",@"虚拟爱人"]];
        self.titleVCArray = [NSMutableArray arrayWithArray:@[self.recommendViewController,self.virtualLoverViewController]];
    }
   
    
//    self.titleVCArray = [NSMutableArray arrayWithArray:@[self.homeViewController,self.recommendViewController,self.communityViewController,self.fengCaiViewController]];
    if (!self.isLogin) {
        [self.titleArray removeObjectsInArray:@[@"邂逅",@"风采秀"]];
        
        [self.titleVCArray removeObjectsInArray:@[self.homeViewController,self.fengCaiViewController]];
    }
    
    [self createNavigationView];
   
    self.sc_navigationBar.rightBarButtonItem = self.isLogin ? self.rightBarItem : nil;
    
    [self requestChatList];
    
    XMUserManager *userManager = [XMUserManager sharedInstance];
    userManager.showRecvMsgDelegate = self;
    [userManager setAppAccount:[LoginManager defaultManager].account];
    [userManager userLogin];
    
    // 刚进来先获取一遍未读数
    [self requestChatList];
    
}

- (void)showRecvMsg:(MIMCMessage *)packet user:(MCUser *)user {
    
    [self requestChatList];
    
}

// 添加监听
- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changNeedUpdate) name:SHOWLOGIN object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushUserDetailInfo) name:ShowDetailInfoView object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectIndexOne) name:DismissLoginView object:nil];
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isPerfectInfo) name:@"isPerfectInfo" object:nil];
    
    
    // 监听首页点击钻石会员
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectZuanShi) name:@"SelectDiamond" object:nil];
    
    // 监听开通会员界面->钻石VIP点击事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectVipZuanShi:) name:@"SelectVIPDiamond" object:nil];
    
    // 新用户送一元提示
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newUserClick:) name:@"NewUserOneDollar" object:nil];
    
    // 首页欢迎图片点击跳转钻石vip界面
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectZuanShi) name:@"HOME_WELCOME" object:nil];
    
}

// 获取会话列表(显示未读角标)
- (void)requestChatList {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/im/getlist" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/im/getlist: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            NSArray *arr = dictionary[@"data"];
            
            
            // tabBar未读角标
            for (int i=0; i<arr.count; i++) {
                
                NSDictionary *dic = arr[i];
                
                if (!kISNullObject(dic[@"unread"])) {
                    
                    // 有未读直接显示红点并跳出遍历
                    if (![[dic[@"unread"] stringValue] isEqualToString:@"0"]) {
                        
                        [self.tabBarController.tabBar showBadgeOnItemIndex:3 unNumber:dic[@"unread"]];
                        break;
                    }
                    
                }
                
                if (i == arr.count-1) { // 这个条件能成立说明会话列表没有未读
                    [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
                }
                
            }
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}


// 跳转提现界面
- (void)sureButtonClick {
    
    
    
}

// 新用户送一元提示
- (void)newUserClick:(NSNotification *)notifi {
    
    HLNewUserView *popView = [HLNewUserView initWithXib:CGRectMake(0, 0, kScreenWidth, kScreenHeight) delegate:self];
    
    [popView showSelf];
    
}

- (void)selectVipZuanShi:(NSNotification *)notifi {
    
    [self.tabBarController setSelectedIndex:0];
    [self selectZuanShi];
    
    [notifi.object popViewControllerAnimated:YES];
}

// 监听首页点击钻石会员
- (void)selectZuanShi {
    [self.categoryView selectItemAtIndex:2];
}

- (void)selectIndexOne {
    
    [self.titleArray removeAllObjects];
    [self.titleVCArray removeAllObjects];
    
    if (self.isLogin) {
        
        [self.tabBarController setSelectedIndex:0];
        
//        [self.titleArray addObjectsFromArray:@[@"邂逅",@"推荐",@"社区",@"风采秀"]];
        
        if (self.isVip) {
            [self.titleArray addObjectsFromArray:@[@"推荐",@"同城",@"虚拟爱人"]];
            [self.titleVCArray addObjectsFromArray:@[self.recommendViewController,self.nearbyViewController,self.virtualLoverViewController]];
            
        }else{
            
            [self.titleArray addObjectsFromArray:@[@"推荐",@"虚拟爱人"]];
            [self.titleVCArray addObjectsFromArray:@[self.recommendViewController,self.virtualLoverViewController]];
            
        }
        
        XMUserManager *userManager = [XMUserManager sharedInstance];
        userManager.showRecvMsgDelegate = self;
        [userManager setAppAccount:[LoginManager defaultManager].account];
        [userManager userLogin];
        
    } else {
        
        [self.titleArray addObjectsFromArray:@[@"推荐",@"社区",@"虚拟爱人"]];
        
        [self.titleVCArray addObjectsFromArray:@[self.recommendViewController,self.communityViewController,self.virtualLoverViewController]];
        
    }
    
    [self.categoryView reloadData];
    
    [self.categoryView selectItemAtIndex:0];
    
}





- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isLogin) {
        
        if (ifNeedUpdatePrefect) {
            ifNeedUpdatePrefect = NO;
            [self loadRequest];
        }
        
    }
    
}

// 是否完善信息
- (void)isPerfectInfo {
    if (ifNeedUpdatePrefect) {
        ifNeedUpdatePrefect = NO;
        [self loadRequest];
    }
    
}

- (void)changNeedUpdate{
    ifNeedUpdatePrefect = YES;
}

// 是否已经完善信息
- (void)loadRequest{
    
    [HLHTTPSessionManager postDataWithNSString:HLISPerfect withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            
            // 1:已完善  0:未完善
            if (![[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) { // 未完善退出自动登录

                [[LoginManager defaultManager] doLogout];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                
            }
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 是否需要先完善个人信息
- (void)pushUserDetailInfo{
    HLUserDetailInfoViewController *userDetailInfoVC = [[HLUserDetailInfoViewController alloc] init];
    userDetailInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userDetailInfoVC animated:YES];
}

// 导航栏视图
- (void)createNavigationView{

    UIImageView *imgView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"show_nav_bg"]];
    imgView3.frame = CGRectMake(0, 0, kScreenWidth, 200);
    [self.view addSubview:imgView3];
    
    //初始化JXCategoryListContainerView
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight - kTabBarHeight);
    
    self.listContainerView.initListPercent = 0.8;
    
    [self.view addSubview:self.listContainerView];
    
    self.categoryView = [[JXCategoryTitleVerticalZoomView alloc] init];
    self.categoryView.listContainer = self.listContainerView;
    self.categoryView.defaultSelectedIndex = 0;
    self.categoryView.frame = CGRectMake(0, kStatusBarHeight, kScreenWidth-70, kNavigationBarHeight - kStatusBarHeight);
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.titles = self.titleArray;
    self.categoryView.delegate = self;
    self.categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleBottom;
    self.categoryView.titleLabelVerticalOffset = -5;
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.titleColor = [UIColor darkGrayColor];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.contentEdgeInsetLeft = 15;    //设置内容左边距
    self.categoryView.titleLabelStrokeWidthEnabled = YES;
    self.categoryView.titleLabelSelectedStrokeWidth = -2;
    
    self.categoryView.selectedAnimationDuration = 0;
    
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
    
    //如果你非要在scrollZoom效果上面加指示器效果，请使用JXCategoryIndicatorScrollZoomLineView自定义类，里面做了一点点特殊处理。
//    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
//    lineView.componentPosition = JXCategoryComponentPosition_Top;
//    lineView.indicatorWidthIncrement = 20;
//    lineView.indicatorColor = [UIColor clearColor];
//
//    self.imgTopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zuanshi"]];
//    self.imgTopView.hidden = YES;
//    [lineView addSubview:self.imgTopView];
//
//    [self.imgTopView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(lineView.mas_top);
//        make.right.equalTo(lineView.mas_right);
//    }];
//
//
//    JXCategoryIndicatorLineView *lineView1 = [[JXCategoryIndicatorLineView alloc] init];
//    lineView1.componentPosition = JXCategoryComponentPosition_Bottom;
//    lineView1.indicatorColor = [UIColor clearColor];
//    lineView1.indicatorWidth = 30;
//    lineView1.verticalMargin = 8;
//
//    self.imgBottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vvip_gundong"]];
//    self.imgBottomView.hidden = YES;
//    [lineView1 addSubview:self.imgBottomView];
//
//    [self.imgBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(lineView1.mas_top);
//        make.centerX.equalTo(lineView1.mas_centerX);
//    }];
//
//    self.categoryView.indicators = @[lineView,lineView1];
    
    
    //关联cotentScrollView，关联之后才可以互相联动！！！
//    self.categoryView.contentScrollView = self.listContainerView.scrollView;
    
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

#pragma mark - JXCategoryListContainerViewDelegate
//返回遵从`JXCategoryListContentViewDelegate`协议的实例
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    
    return self.titleVCArray[index];
}
//返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}

/**
 点击选中或者滚动选中都会调用该方法。适用于只关心选中事件，不关心具体是点击还是滚动选中的。

 @param categoryView categoryView对象
 @param index 选中的index
 */
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    
    if (self.isLogin && index == 4) {
        
        self.sc_navigationBar.rightBarButtonItem = self.rightBarItem;
        
        self.sc_navigationBar.backgroundAlpha = 0;
        self.categoryView.backgroundColor = [UIColor clearColor];
//        self.categoryView.titleSelectedColor = kRGBA(255, 193, 116, 1);
        
//        self.imgTopView.hidden = NO;
//        self.imgBottomView.hidden = NO;
    } else {
        
//        if (index == 3) {
//            self.sc_navigationBar.rightBarButtonItem = self.isLogin ? self.topicRightItem : nil;
//        } else {
            self.sc_navigationBar.rightBarButtonItem = self.isLogin ? self.rightBarItem : nil;
//        }
        
        self.sc_navigationBar.backgroundAlpha = 1;
        self.categoryView.backgroundColor = [UIColor whiteColor];
        self.categoryView.titleSelectedColor = [UIColor blackColor];
        
//        self.imgTopView.hidden = YES;
//        self.imgBottomView.hidden = YES;
    }
    
    [self.categoryView reloadCellAtIndex:index];
    
}

#pragma mark - 首页各个模块

// V会员俱乐部
- (HLVVipViewController *)vvipViewController{
    if (!_vvipViewController) {
        _vvipViewController = [[HLVVipViewController alloc] init];
        [self addChildViewController:_vvipViewController];
    }
    return _vvipViewController;
}

- (HLNewHomeController *)homeViewController {
    if (!_homeViewController) {
        _homeViewController = [[HLNewHomeController alloc] init];
        [self addChildViewController:_homeViewController];
    }
    return _homeViewController;
}

// 推荐
- (HXRecommendViewController *)recommendViewController{
    if (!_recommendViewController) {
        _recommendViewController = [[HXRecommendViewController alloc] init];
        [self addChildViewController:_recommendViewController];
    }
    return _recommendViewController;
}

// 真人头像
- (HLRealHeadViewController *)realViewController {
    if (!_realViewController) {
        _realViewController = [[HLRealHeadViewController alloc] init];
        [self addChildViewController:_realViewController];
    }
    return _realViewController;
}

// 附近
- (HLNearbyViewController *)nearbyViewController{
    if (!_nearbyViewController) {
        _nearbyViewController = [[HLNearbyViewController alloc] init];
        [self addChildViewController:_nearbyViewController];
    }
    return _nearbyViewController;
}

// 虚拟爱人
- (HLVirtualLoverViewController *)virtualLoverViewController{
    if (!_virtualLoverViewController) {
        _virtualLoverViewController = [[HLVirtualLoverViewController alloc] init];
        [self addChildViewController:_virtualLoverViewController];
    }
    return _virtualLoverViewController;
}

// 社区
- (HLCommunityViewController *)communityViewController{
    if (!_communityViewController) {
        _communityViewController = [[HLCommunityViewController alloc] init];
        [self addChildViewController:_communityViewController];
    }
    return _communityViewController;
}

// 风采秀
- (HLFengCaiXiuViewController *)fengCaiViewController{
    if (!_fengCaiViewController) {
        _fengCaiViewController = [[HLFengCaiXiuViewController alloc] init];
        [self addChildViewController:_fengCaiViewController];
    }
    return _fengCaiViewController;
}

// 颜品
//- (HLYanPinController *)yanPinViewController{
//    if (!_yanPinViewController) {
//        _yanPinViewController = [[HLYanPinController alloc] initWithNibName:@"HLYanPinController" bundle:nil];
//        [self addChildViewController:_yanPinViewController];
//    }
//    return _yanPinViewController;
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
