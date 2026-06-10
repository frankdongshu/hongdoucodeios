//
//  HLSquareViewController.m
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSquareViewController.h"
//#import "HLFindTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HLPreviewPhotoViewController.h"
#import "HLFindMasonryAutolayoutCell.h"
#import "HLFrienderDetailViewController.h"
#import "CSCoachDetailViewController.h"

@interface HLSquareViewController ()<HLFindMasonryAutolayoutDelegate>
{
    NSInteger currentPage;
    NSInteger theRowInt;
}
@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation HLSquareViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:DismissLoginView object:nil];
    [self initTableView];
    
    [self loadNewData];
}

- (void)redHeartClick:(NSNotification *)notifi {
    
    BOOL likeIs = [notifi.object boolValue];
    
    NSArray *arr = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in arr) {
        
        if (indexPath.row == theRowInt) {
            HLFindMasonryAutolayoutCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
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
//    self.tableView.estimatedRowHeight = 200.f;
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView registerNib:[UINib nibWithNibName:@"HLFindTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFindTableViewCell"];
    [self.tableView registerClass:[HLFindMasonryAutolayoutCell class] forCellReuseIdentifier:@"HLFindMasonryAutolayoutCell"];
    self.tableView.mj_footer.hidden = NO;
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
    
    [HLHTTPSessionManager postDataWithNSString:HLAlbum_Square withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"广场列表: %@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSMutableArray *dataArray = [HLAlbumDetails mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (dataArray.count > 0) {
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshing];
            } else {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
        }
        else if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"202"]) { // 暂无数据
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            [weakSelf.tableView.mj_header endRefreshing];
        }
        else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];
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
#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLFindMasonryAutolayoutCell *cell = (HLFindMasonryAutolayoutCell*)[tableView dequeueReusableCellWithIdentifier:@"HLFindMasonryAutolayoutCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.weakSelf = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - 给cell赋值
- (void)configureCell:(HLFindMasonryAutolayoutCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    // 采用计算frame模式还是自动布局模式，默认为NO，自动布局模式
//    cell.fd_enforceFrameLayout = YES;
    HLAlbumDetails *model = self.dataSource[indexPath.row];
    cell.albumModel = model;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    return UITableViewAutomaticDimension;
    return [self.tableView fd_heightForCellWithIdentifier:@"HLFindMasonryAutolayoutCell" cacheByIndexPath:indexPath configuration:^(HLFindMasonryAutolayoutCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
//    detailVC.idx = indexPath;
//    detailVC.hidesBottomBarWhenPushed = YES;
//    HLAlbumDetails *model = self.dataSource[indexPath.row];
//    detailVC.userId = model.uid;
//    detailVC.refreshBlock  = ^{
//        NSLog(@"++++++++++++++");
//    };
//    detailVC.removeBlock = ^{
//
//        // 根据拉黑用户ID, 遍历数组中该iD的所有数据并集体删除
//        NSIndexSet *indexSet =
//            [self.dataSource indexesOfObjectsPassingTest:^BOOL(HLAlbumDetails *  _Nonnull var, NSUInteger idx, BOOL * _Nonnull stop) {
//                return [var.uid isEqualToString:model.uid];
//            }];
//        [self.dataSource removeObjectsAtIndexes:indexSet];
//
//        [self.tableView reloadData];
//
//    };
//    [self.navigationController pushViewController:detailVC animated:YES];
    
    
//    [self requestUserDetailWithModel:self.dataSource[indexPath.row]];
    
}

- (void)requestUserDetailWithModel:(HLAlbumDetails *)mod {
    [self.view showLoading];
    
    NSDictionary *parmas = @{
        @"cid":mod.uid
    };
    
    [HTTPSessionManger postDataWithNSString:@"/customer/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            CSCoachDetailViewController *vc = [[CSCoachDetailViewController alloc] init];
            vc.model = [CSCoachDetailModel mj_objectWithKeyValues:dictionary[@"data"]];
            vc.isApp = XinLiApp;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
    
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

- (void)colletionButtonClick{
//    [self loadNewData];
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
