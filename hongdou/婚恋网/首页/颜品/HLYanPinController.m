//
//  HLYanPinController.m
//  hongdou
//
//  Created by 维康1 on 2021/3/9.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLYanPinController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HLPreviewPhotoViewController.h"
#import "HLYanPinListCell.h"
#import "HLFrienderDetailViewController.h"

#import "HLWebYanPinController.h"
#import "HLPhotoManageViewController.h"

@interface HLYanPinController ()<HLYanPinListCellDelegate>
{
    NSInteger currentPage;
    NSInteger theRowInt;
}

@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation HLYanPinController

- (void)dongTaiClick:(NSNotification *)notifi {
    
    NSDictionary *dic = notifi.object;
    
    NSInteger idx = [dic[@"idx"] integerValue];
    BOOL isLike = [dic[@"isLike"] boolValue];
    
    HLAlbumDetails *model = self.dataSource[idx];
    model.islikes = isLike;
    if (isLike) {
        model.likes = [NSString stringWithFormat:@"%d",[model.likes intValue]+1];
    } else {
        model.likes = [NSString stringWithFormat:@"%d",[model.likes intValue]-1];
    }
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.dataSource = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:@"refreshPhotoManage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redHeartClick:) name:@"Red_Heart" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dongTaiClick:) name:@"DongTaiLike" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginVCdissmissClick) name:DismissLoginView object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:@"squareReloadList" object:nil];
    
    [self initTableView];
    
    [self.tableView.mj_header beginRefreshing];
    
    [self createButton];
}

// 浮动按钮
- (void)createButton{

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setImage:[UIImage imageNamed:@"topic_fudong"] forState:UIControlStateNormal];

    [button addTarget:self action:@selector(fuDongClick) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];
    
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
            
    }];

}

- (void)fuDongClick {
    
    HLPhotoManageViewController *vc = [[HLPhotoManageViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.isYanPin = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)loginVCdissmissClick {
    
    if (self.isLogin) {
        [self loadNewData];
    }
    
}

- (void)redHeartClick:(NSNotification *)notifi {
    
    BOOL likeIs = [notifi.object boolValue];
    
    NSArray *arr = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in arr) {
        
        if (indexPath.row == theRowInt) {
            HLYanPinListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [cell.isLikeButton setSelected:likeIs];
            
            if (likeIs) {
                [cell.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[cell.isLikeButton.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            } else {
                [cell.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[cell.isLikeButton.titleLabel.text intValue]-1] forState:UIControlStateNormal];
            }
            
            cell.albumModel.islikes = cell.isLikeButton.selected;
            cell.albumModel.likes = cell.isLikeButton.titleLabel.text;
        }
        
    }
    
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    
    self.tableView.estimatedRowHeight = 200.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView registerNib:[UINib nibWithNibName:@"HLFindTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFindTableViewCell"];
    [self.tableView registerClass:[HLYanPinListCell class] forCellReuseIdentifier:@"HLYanPinListCell"];
//    self.tableView.mj_footer.hidden = NO;
}

- (void)loadMoreData {
    
    currentPage ++;
    [self requesNearbyWithPege:currentPage];
    
}


- (void)loadNewData{
    
    currentPage = 1;
    [self.dataSource removeAllObjects];
    [self requesNearbyWithPege:currentPage];
    
}



- (void)requesNearbyWithPege:(NSInteger)page {
    
    NSDictionary *params = @{
        @"visitor":@"yes",
        @"page":[NSNumber numberWithInteger:page]
    };
    
    
    if (self.isLogin) {
        
        params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"page":[NSNumber numberWithInteger:page]
        };
        
    }
    
    WeakSelf(weakSelf);
    
    
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/absquare" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        
        NSLog(@"=1=1=1=%@",dictionary);
        
        self.tableView.mj_footer.hidden = NO;
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSMutableArray *dataArray = [HLAlbumDetails mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (dataArray.count >= 10) {
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshing];
            } else if (dataArray.count < 10 && dataArray.count != 0) {
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
        }
        else if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"202"]) { // 暂无数据
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
        [self setRequestFiledView];
        [weakSelf.tableView.mj_header endRefreshing];

    }];
}
-(void)setRequestFiledView
{
    if (self.dataSource.count == 0) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
//        warnMsg.text = @"下拉可以刷新哦~";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        [blankBg addSubview:warnMsg];
        [self.tableView setTableHeaderView:blankBg];
        [self.tableView.mj_header endRefreshing];
    }else
    {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }
}

// 跳转webView
- (void)webViewControllerWithUrl:(NSString *)url {
    HLWebYanPinController *vc = [[HLWebYanPinController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.url = url;
    [self.navigationController pushViewController:vc animated:YES];
    
}


#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLYanPinListCell *cell = (HLYanPinListCell*)[tableView dequeueReusableCellWithIdentifier:@"HLYanPinListCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.weakSelf = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - 给cell赋值
- (void)configureCell:(HLYanPinListCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    // 采用计算frame模式还是自动布局模式，默认为NO，自动布局模式
//    cell.fd_enforceFrameLayout = YES;
    HLAlbumDetails *model = self.dataSource[indexPath.row];
    cell.albumModel = model;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.tableView fd_heightForCellWithIdentifier:@"HLYanPinListCell" cacheByIndexPath:indexPath configuration:^(HLYanPinListCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLAlbumDetails *model = self.dataSource[indexPath.row];
    
    if (!model.isvip) { // 判断对方是否开通颜品VIP
        
        [self.view showTostWithMessage:@"暂无法查看"];
        
        return;
    }
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.idx = indexPath;
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.userId = model.uid;
    detailVC.nickName = model.nickname;
    detailVC.refreshBlock  = ^{
        NSLog(@"++++++++++++++");
    };
    detailVC.removeBlock = ^{
        
        // 根据拉黑用户ID, 遍历数组中该iD的所有数据并集体删除
        NSIndexSet *indexSet =
            [self.dataSource indexesOfObjectsPassingTest:^BOOL(HLAlbumDetails *  _Nonnull var, NSUInteger idx, BOOL * _Nonnull stop) {
                return [var.uid isEqualToString:model.uid];
            }];
        [self.dataSource removeObjectsAtIndexes:indexSet];
        
        [self.tableView reloadData];
        
    };
    [self.navigationController pushViewController:detailVC animated:YES];
    
}
#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

#pragma cellDelegate

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike {
    
    theRowInt = indexPath.row;
    
    HLPreviewPhotoViewController *previewVC = [[HLPreviewPhotoViewController alloc] init];
    previewVC.albumModel = self.dataSource[indexPath.row];
    previewVC.isLike = islike;
    previewVC.isTag = @"广场";
    previewVC.scrollIndexPath = [NSIndexPath indexPathForItem:tage inSection:0];
    previewVC.hidesBottomBarWhenPushed = YES;
//    HXNavigationController *nvc = [[HXNavigationController alloc]initWithRootViewController:loginVC];
    [self.navigationController pushViewController:previewVC animated:YES];
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
