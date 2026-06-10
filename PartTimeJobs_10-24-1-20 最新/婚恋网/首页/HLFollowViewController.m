//
//  HLFollowViewController.m
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFollowViewController.h"
#import "HLHometableViewCell.h"
#import "HLFindTableViewCell.h"
#import "HLPreviewPhotoViewController.h"
#import "HLFrienderDetailViewController.h"

@interface HLFollowViewController ()<HLFindDelegate>
{
    NSInteger currentPage;
    NSInteger theRowInt;
}
@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation HLFollowViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isLogin) {
        [self.dataSource removeAllObjects];
        self.tableView.mj_footer.hidden = YES;
    } else {
        self.tableView.mj_footer.hidden = NO;
        
        
//        [self loadNewData];
    }
    
    
    [self.tableView reloadData];
}

- (void)removePersonClick:(NSNotification *)notifi {
    
//    NSString *mobile = notifi.object;
    
    [self loadNewData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.dataSource = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redHeartClick:) name:@"Follow_Heart" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:@"RemovePerson" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:DismissLoginView object:nil];
    [self initTableView];
    
    [self loadNewData];
}

- (void)redHeartClick:(NSNotification *)notifi {
    
    BOOL likeIs = [notifi.object boolValue];
    
    NSArray *arr = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in arr) {
        
        if (indexPath.row == theRowInt) {
            
            HLFindTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 200.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HLFindTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFindTableViewCell"];
    
    self.tableView.mj_footer.hidden = NO;
}

- (void)loadMoreData {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.tableView.mj_footer endRefreshing];
        
        return;
    }
    
    currentPage ++;
    [self requesNearbyWithPege:currentPage];
    
}

- (void)loadNewData{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.tableView.mj_header endRefreshing];
        
        return;
    }
    
    currentPage = 1;
    [self.dataSource removeAllObjects];
    [self requesNearbyWithPege:currentPage];
    
}

- (void)requesNearbyWithPege:(NSInteger)page{
    if (self.isLogin) {
        WeakSelf(weakSelf);
        
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"page":[NSNumber numberWithInteger:page]
        };
        
        [HLHTTPSessionManager postDataWithNSString:HLAlbum_Follow withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLFindTableViewCell *cell = (HLFindTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLFindTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.albumModel = self.dataSource[indexPath.row];
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    HLAlbumDetails *model = self.dataSource[indexPath.row];
    detailVC.userId = model.uid;
    detailVC.refreshBlock  = ^{
        NSLog(@"非移除类操作~~~~~~~");
    };
    detailVC.removeBlock = ^{
        
        [self.dataSource removeObject:self.dataSource[indexPath.row]];
        
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

//- (void)colletionButtonClick{
//    [self loadNewData];
//}

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike {
    
    theRowInt = indexPath.row;
    
    HLPreviewPhotoViewController *previewVC = [[HLPreviewPhotoViewController alloc] init];
    previewVC.albumModel = self.dataSource[indexPath.row];
    previewVC.isLike = islike;
    previewVC.isTag = @"关注";
    previewVC.scrollIndexPath = [NSIndexPath indexPathForItem:tage inSection:0];
    previewVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:previewVC animated:YES];
}
@end
