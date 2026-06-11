//
//  HLTopicController.m
//  hongdou
//
//  Created by 维康1 on 2020/12/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLTopicController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "HLPreviewPhotoViewController.h"
#import "HLTopicCell.h"
#import "HLFrienderDetailViewController.h"
#import "HLReleaseViewController.h"
#import "HLDreamLoverDesView.h" // 提示弹窗


#import "HLTopicHeaderView.h" // 头视图
#import "HLAddressController.h" // 设置地址界面

@interface HLTopicController ()<HLTopicCellDelegate, HLTopicHeaderViewDelegate>
{
    NSInteger theRowInt;
}
@property (nonatomic, strong)NSMutableArray *dataSource;

// 头视图
@property (nonatomic, strong) HLTopicHeaderView *topicHeaderView;

@end

@implementation HLTopicController

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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestAddress) name:@"HUA_TI_REFRESH_ADD" object:nil];
    
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
       
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
            
    }];

}

// 浮动按钮触发方法
- (void)fuDongClick {
    
    [self weiHaoClickWith:self.topicHeaderView.contentDic[@"data"][@"name"] andHuaTiId:self.topicHeaderView.contentDic[@"data"][@"id"]];
    
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
            HLTopicCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
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



// 创建tabbleview视图
- (void)initTableView {
    
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
//    self.tableView.estimatedRowHeight = 200.f;
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[HLTopicCell class] forCellReuseIdentifier:@"HLTopicCell"];
    
    self.topicHeaderView = [HLTopicHeaderView initWithXib:CGRectMake(0, 0, kScreenWidth, 330) delegate:self] ;
    
//    self.tableView.tableHeaderView = self.topicHeaderView;
}

/// 适应banner图
/// @param imgHeight 网图高度
- (void)tableViewHeaderImgHeightWith:(float)imgHeight {
    
    self.topicHeaderView.frame = CGRectMake(0, 0, kScreenWidth, 180+imgHeight);
    
    self.tableView.tableHeaderView = self.topicHeaderView;
    
}

// 上拉加载
- (void)loadMoreData {
    
}

// 下拉刷新
- (void)loadNewData{
    
    // 话题详情
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/get_toc" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"===%@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (!kISNullObject(dictionary[@"data"])) {
                self.dataSource = [HLAlbumDetails mj_objectArrayWithKeyValuesArray:dictionary[@"data"][@"album"]];
                
                self.topicHeaderView.contentDic = dictionary;
                
                
                [self.tableView reloadData];
            }
            
            
            
        }
        
        [self setRequestFiledView];
        
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
        
        [self.tableView.mj_header endRefreshing];
    }];
    
}

// 查看有无地址
- (void)requestAddress {
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [MBProgressHUD showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_address" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
        } else { // 202 没有设置邮寄地址
            
            [self pushAlertVc];
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

// 询问是否进入添加邮寄地址界面
- (void)pushAlertVc {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"你还没有设置地址,立即前往设置地址或稍后到个人中心设置, 否则视作放弃资格!" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cencel = [UIAlertAction actionWithTitle:@"稍后设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *act = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        HLAddressController *vc = [[HLAddressController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    [alertVC addAction:cencel];
    [alertVC addAction:act];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void)setRequestFiledView {
    
    if (self.dataSource.count == 0) { // 无人参与列表空占位
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
//        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
//        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
//        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, 110, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
        warnMsg.text = @"暂无数据";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        [blankBg addSubview:warnMsg];
        [self.tableView setTableFooterView:blankBg];
        [self.tableView.mj_header endRefreshing];
        
    } else if (kISNullObject(self.topicHeaderView.contentDic[@"data"])) { // 全空占位
        
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
        warnMsg.text = @"暂无数据";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        [blankBg addSubview:warnMsg];
        [self.tableView setTableHeaderView:blankBg];
        [self.tableView.mj_header endRefreshing];
        
    } else {
        
        self.tableView.tableFooterView = [[UIView alloc] init];
        
    }
}
#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLTopicCell *cell = (HLTopicCell*)[tableView dequeueReusableCellWithIdentifier:@"HLTopicCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.weakSelf = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

// 发布界面
- (void)fabuClick:(NSString *)huatiString andHuaTiId:(NSString *)hId {
    
    [self weiHaoClickWith:huatiString andHuaTiId:hId];
    
}

// 提示信息
- (void)weiHaoClickWith:(NSString *)huatiString andHuaTiId:(NSString *)hId {
    
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
                
                HLReleaseViewController *releaseVC = [[HLReleaseViewController alloc] init];
                releaseVC.fabuString = huatiString;
                releaseVC.fabuId = hId;
                releaseVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:releaseVC animated:YES];
                
            };
            
            [dView showSelf];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

#pragma mark - 给cell赋值
- (void)configureCell:(HLTopicCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    // 采用计算frame模式还是自动布局模式，默认为NO，自动布局模式
//    cell.fd_enforceFrameLayout = YES;
    HLAlbumDetails *model = self.dataSource[indexPath.row];
    cell.albumModel = model;
    
    //
    [cell setTopicString:self.topicHeaderView.contentDic[@"data"][@"name"] andTopicId:self.topicHeaderView.contentDic[@"data"][@"id"] andWin:[self.topicHeaderView.contentDic[@"data"][@"win"] integerValue]];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    return UITableViewAutomaticDimension;
    return [self.tableView fd_heightForCellWithIdentifier:@"HLTopicCell" cacheByIndexPath:indexPath configuration:^(HLTopicCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 未登录, 需登录后进入详情页
    if (!self.isLogin) {
        
        NSLog(@"%@",[NSThread currentThread]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    HLAlbumDetails *model = self.dataSource[indexPath.row];
    
    // 同性不进入详情页
    if ([[NSString stringWithFormat:@"%@",[LoginManager defaultManager].gender] isEqualToString:model.gender]) {
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

/// 删除话题
/// @param uid 用户id
/// @param albumId 话题id
- (void)deleteButtonWithUid:(NSString *)uid andAlbumId:(NSString *)albumId {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除吗?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *params = @{
            @"uid":uid,
            @"aid":albumId
        };
        
        [HLHTTPSessionManager postDataWithNSString:HLAlbum_Del withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                // 通知广场刷新, 顺带本业一起刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
                
            } else {
                [self.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [self.view showTostWithMessage:error.localizedDescription];
        }];
        
    }]];
    
        
    // 弹出对话框
    [self presentViewController:alert animated:true completion:nil];
    
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
