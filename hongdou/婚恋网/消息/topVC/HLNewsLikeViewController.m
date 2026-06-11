//
//  HLNewsLikeViewController.m
//  hongdou
//
//  Created by 维康1 on 2020/1/3.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLNewsLikeViewController.h"
#import "HLLikeMeViewController.h" // 喜欢我的
#import "HLMyLikeViewController.h" // 我喜欢的
#import "JXCategoryTitleVerticalZoomView.h"

@interface HLNewsLikeViewController ()<JXCategoryViewDelegate,JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) JXCategoryTitleVerticalZoomView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) HLLikeMeViewController *likeMeViewController;
@property (nonatomic, strong) HLMyLikeViewController *myLikeViewController;

@end

@implementation HLNewsLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self createNavigationView];
}
- (void)createNavigationView{
    
    //初始化JXCategoryListContainerView
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    self.listContainerView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight);
    [self.view addSubview:self.listContainerView];
    
    self.categoryView = [[JXCategoryTitleVerticalZoomView alloc] init];
    self.categoryView.listContainer = self.listContainerView;
    self.categoryView.frame = CGRectMake(kScreenWidth/2 - 95, kStatusBarHeight, 220, kNavigationBarHeight - kStatusBarHeight);
    self.categoryView.averageCellSpacingEnabled = NO;
    self.categoryView.titles = @[@"赞过我的",@"我赞过的"];
    self.categoryView.delegate = self;
    self.categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleCenter;
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
    if (index==0) {
        return self.likeMeViewController;
    }else{
        return self.myLikeViewController;
    }
}
//返回列表的数量
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.categoryView.titles.count;
}


- (HLLikeMeViewController *)likeMeViewController{
    if (!_likeMeViewController) {
        _likeMeViewController = [[HLLikeMeViewController alloc] init];
        [self addChildViewController:_likeMeViewController];
    }
    return _likeMeViewController;
}

- (HLMyLikeViewController *)myLikeViewController{
    if (!_myLikeViewController) {
        _myLikeViewController = [[HLMyLikeViewController alloc] init];
        [self addChildViewController:_myLikeViewController];
    }
    return _myLikeViewController;
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
