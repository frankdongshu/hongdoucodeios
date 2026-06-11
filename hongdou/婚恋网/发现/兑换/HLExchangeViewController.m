//
//  HLExchangeViewController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLExchangeViewController.h"
#import "HLProductListCell.h"
#import "HLExchangeModel.h"
#import "HLProductDetailController.h" // 商品详情
#import "HLExchangeRecordController.h"
#import "HLShoppingInfoView.h"
#import "HLExchangeReusableView.h" // 组头
#import "HLExchangeSwitchModel.h" // 兑换状态Model

@interface HLExchangeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, HLProductListCellDelegate, HLExchangeReusableDeleagte>{
    NSInteger currentPage;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *exchangeArray;

@property (nonatomic, strong) HLExchangeModel *model;
@property (nonatomic, strong) HLUser *userInfo;

@property (nonatomic, strong) UIButton *exchangeBtn;
@property (nonatomic, strong) HLExchangeSwitchModel *switchModel;

@end

@implementation HLExchangeViewController

- (UIButton *)exchangeBtn {
    if (!_exchangeBtn) {
        _exchangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _exchangeBtn.backgroundColor = [UIColor whiteColor];
        _exchangeBtn.frame = CGRectMake(0, 0, kScreenWidth, 40);
        [_exchangeBtn setTitle:@"兑换记录" forState:UIControlStateNormal];
        [_exchangeBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [_exchangeBtn setTitleColor:kRGBA(255, 92, 121, 1) forState:UIControlStateNormal];
        _exchangeBtn.titleLabel.font = kScaleFont(14);
        [_exchangeBtn addTarget:self action:@selector(exchangeClick) forControlEvents:UIControlEventTouchUpInside];
        _exchangeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_exchangeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - _exchangeBtn.imageView.image.size.width, 0, _exchangeBtn.imageView.image.size.width+20)];
        [_exchangeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _exchangeBtn.titleLabel.bounds.size.width, 0, -_exchangeBtn.titleLabel.bounds.size.width+10)];
        
    }
    return _exchangeBtn;
}

// 兑换记录
- (void)exchangeClick {
    
    HLExchangeRecordController *recordVC = [[HLExchangeRecordController alloc] init];
    recordVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recordVC animated:YES];
    
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        //设置滚动方向
        [flowlayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        //左右间距
        flowlayout.minimumInteritemSpacing = 10;
        //上下间距
        flowlayout.minimumLineSpacing = 15;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 , 0 , kScreenWidth, kScreenHeight-kNavigationBarHeight-kTabBarHeight) collectionViewLayout:flowlayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
//        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        
        
        // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.automaticallyChangeAlpha = YES;
        
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        
        // 设置header
        self.collectionView.mj_header = header;
        
        
        // 上拉加载
        MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        self.collectionView.mj_footer = footer;
        
        
        //注册cell
        [_collectionView registerClass:[HLProductListCell class] forCellWithReuseIdentifier:kCellIdentifier_CollectionViewCell];
        
        [_collectionView registerClass:[HLExchangeReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HLExchangeReusableView"];
    }
    return _collectionView;
}

// 组头
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    HLExchangeReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HLExchangeReusableView" forIndexPath:indexPath];
    
    [headerView addSubview:self.exchangeBtn];
    
//    headerView.delegate = self;
//    headerView.statu = self.switchModel.exchange;
//    [headerView.theSwitch setOn:self.switchModel.exchange];

    return headerView;
}

- (void)refreshTableView {
    
    [self requestData];
    
}

// 当然这个设置不能忘记
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    return CGSizeMake(kScreenWidth, 40);
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.exchangeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HLProductListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_CollectionViewCell forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.model = self.exchangeArray[indexPath.row];
    cell.delegate = self;
    cell.buyBtn.tag = indexPath.row;
    
    return cell;
}

- (void)didSelectBuyButtonWithIdx:(NSInteger)productIdx {

    self.model = self.exchangeArray[productIdx];

    if ([self.model.price floatValue] > [self.userInfo.balance floatValue]) {
        [self.view showTostWithMessage:@"您的可用余额不足!"];
    } else {
        HLShoppingInfoView *popView = [[HLShoppingInfoView alloc] initWithParamDic:^(NSDictionary *parmas) {

            [self requsetExchangeListWithParmas:parmas];

        }];

        [popView show];
    }

}

// 提交兑换产品请求
- (void)requsetExchangeListWithParmas:(NSDictionary *)dic {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pid":self.model.productId,
        @"consignee":dic[@"name"],
        @"tel":dic[@"phone"],
        @"address":dic[@"add"]
    };
    
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLExchange_Shopping withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        
        [self requestCurrentUserInfo];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// item 宽/高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    return CGSizeMake((ScreenWidth - 30) / 2, (ScreenWidth - 6) / 2 + 40);
    return CGSizeMake(ScreenWidth-20, (ScreenWidth - 6) / 2 + 100);
}

// 边距设置:整体边距的优先级，始终高于内部边距的优先级
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(15, 10, 15, 10);//分别为上、左、下、右
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HLProductDetailController *detailVC = [[HLProductDetailController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    
    detailVC.model = self.exchangeArray[indexPath.row];
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isLogin) {
        // 个人信息中获取余额
        [self requestCurrentUserInfo];
        
        self.exchangeBtn.hidden = NO;
        self.collectionView.mj_footer.hidden = NO;
    } else {
        [self.exchangeArray removeAllObjects];
        
        [self.collectionView reloadData];
        self.exchangeBtn.hidden = YES;
        self.collectionView.mj_footer.hidden = YES;
    }
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.exchangeArray = [NSMutableArray array];
    
    [self initTableView];
    
    [self.view addSubview:self.collectionView];
    
    // 产品数据
    [self loadNewData];
    
    
    
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = kRGBA(245, 245, 249, 1);
    self.tableView.estimatedRowHeight = 200.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.tableView.mj_footer.hidden = YES;
}

- (void)loadNewData{
    
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        [self.collectionView.mj_header endRefreshing];
        
        return;
    }
    
    currentPage = 1;
    [self.exchangeArray removeAllObjects];
    [self requsetExchangeListWithPege:currentPage];
    
    // 个人信息中获取余额
    [self requestCurrentUserInfo];
    
}
- (void)loadMoreData{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        [self.collectionView.mj_footer endRefreshing];
        
        return;
    }
    
    currentPage ++;
    [self requsetExchangeListWithPege:currentPage];
}


// 请求可兑换产品列表
- (void)requsetExchangeListWithPege:(NSInteger)page {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"page":[NSNumber numberWithInteger:page]
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLShopping_List withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            
            NSMutableArray *dataArray = [HLExchangeModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (dataArray.count > 0) {
                [weakSelf.exchangeArray addObjectsFromArray:dataArray];
                [weakSelf.collectionView.mj_header endRefreshing];
                [weakSelf.collectionView.mj_footer endRefreshing];
            } else {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
        }
        else if ([code isEqualToString:@"202"]) { // 暂无数据
            [weakSelf.collectionView.mj_header endRefreshing];
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
        else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [self setRequestFiledView];
        [weakSelf.collectionView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [self setRequestFiledView];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    
}

// 开关
- (void)requestData {
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLDui_Huan_Activ withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            
            NSLog(@"%@",dictionary[@"data"]);
            
            self.switchModel = [HLExchangeSwitchModel mj_objectWithKeyValues:dictionary[@"data"]];
            
            [weakSelf.collectionView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)setRequestFiledView {
    
    if (self.exchangeArray.count == 0) {
        self.exchangeBtn.hidden = YES;
        [self.exchangeArray removeAllObjects];
        [self.collectionView reloadData];
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    } else {
        self.exchangeBtn.hidden = NO;
    }
    
}

// 请求当前用户的信息获取余额
- (void)requestCurrentUserInfo{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLGET_UserINFO withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.userInfo = [HLUser mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
//        [weakSelf.view showTostWithMessage:@"获取个人信息失败"];
    }];
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

/**
 可选实现，列表显示的时候调用
 */
- (void)listDidAppear {

    [self loadNewData];
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
