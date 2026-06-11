//
//  HLPhotoManageViewController.m
//  婚恋网
//
//  Created by iMac on 2019/7/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPhotoManageViewController.h"
#import "HLPhotoTopTableViewCell.h"
#import "HLPhotoManageTableViewCell.h"
#import "HLReleaseViewController.h"
#import "HLPreviewPhotoViewController.h"

#import "LLPhotoManageCell.h"
#import "HLAuthCenterController.h"
#import "HLOpenYanPinVipController.h"

#import "HLSettingLinkController.h"

@interface HLPhotoManageViewController ()<UITableViewDelegate,UITableViewDataSource,LLPhotoManageCellDeleagte> {
    
    NSInteger currentPage;
    NSInteger theRowInt;
}
@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;
@property (nonatomic, strong) HLAlbumModel *albumModel;

@property (nonatomic, strong) HXBarButtonItem *rightBarItem;

@end

@implementation HLPhotoManageViewController

- (HXBarButtonItem *)rightBarItem {
    if (!_rightBarItem) {
        
        @weakify(self);
        _rightBarItem = [[HXBarButtonItem alloc] initWithTitle:@"购买红豆优品VIP" withColor:[UIColor systemOrangeColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            HLOpenYanPinVipController *vc = [[HLOpenYanPinVipController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _rightBarItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = self.isYanPin?self.rightBarItem:nil;
    
    self.sc_navigationBar.title = self.isYanPin?@"红豆优品":@"动态管理";
    self.albumArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:@"refreshPhotoManage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redHeartClick:) name:@"DT_Guan_Li_Heart" object:nil];
    [self creatTableView];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)redHeartClick:(NSNotification *)notifi {
    
    BOOL likeIs = [notifi.object boolValue];
    
    NSArray *arr = [self.tableView indexPathsForVisibleRows];
    
    for (NSIndexPath *indexPath in arr) {
        
        if (indexPath.section == theRowInt) {
            HLPhotoManageTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            [cell.collectionButtn setSelected:likeIs];
            
            if (likeIs) {
                [cell.collectionButtn setTitle:[NSString stringWithFormat:@"%d",[cell.collectionButtn.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            } else {
                [cell.collectionButtn setTitle:[NSString stringWithFormat:@"%d",[cell.collectionButtn.titleLabel.text intValue]-1] forState:UIControlStateNormal];
            }
            
            cell.albumModel.islikes = cell.collectionButtn.selected;
            cell.albumModel.likes = cell.collectionButtn.titleLabel.text;
        }
        
    }
    
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    //    _tableView.allowsSelection = NO;
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    _tableView.estimatedRowHeight = 120.f;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HLPhotoTopTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPhotoTopTableViewCell"];
//    [_tableView registerNib:[UINib nibWithNibName:@"HLPhotoManageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPhotoManageTableViewCell"];
    
    [_tableView registerClass:[LLPhotoManageCell class] forCellReuseIdentifier:@"LLPhotoManageCell"];
    
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    // 设置header
    self.tableView.mj_header = header;
    
    
    // 上拉加载
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    self.tableView.mj_footer = footer;
    
    
    self.tableView.mj_footer.hidden = YES;
    
    
    
    [self.view addSubview:_tableView];
}

- (void)loadNewData{
    currentPage = 1;
    [self.albumArray removeAllObjects];
    [self requsetAlbumInfoWithPege:currentPage];
    
}
- (void)loadMoreData{
    currentPage ++;
    [self requsetAlbumInfoWithPege:currentPage];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.albumArray.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else {
        HLAlbumModel *model = self.albumArray[section - 1];
        return model.albumArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 25.f)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 30, 25.f)];
    label.textColor = [UIColor colorWithHex:0x995ff8];
    label.font = [UIFont systemFontOfSize:16.f];
    if (section==0) {
        label.text = self.isYanPin?@"发布新信息":@"发布新照片";
    }else{
        HLAlbumModel *model = self.albumArray[section - 1];
        label.text = model.key;

    }
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        HLPhotoTopTableViewCell *cell = (HLPhotoTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLPhotoTopTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.publicPhotoBlock = ^{
            
            if (self.isYanPin) {
                // 判断是否会员
                [self yanPinVIP];
                
            } else {
                HLReleaseViewController *releaseVC = [[HLReleaseViewController alloc] init];
                [self.navigationController pushViewController:releaseVC animated:YES];
            }
            
        };
        
        return cell;
        
    } else {
        
        LLPhotoManageCell *cell = (LLPhotoManageCell *)[tableView dequeueReusableCellWithIdentifier:@"LLPhotoManageCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        HLAlbumModel *model = self.albumArray[indexPath.section - 1];
        cell.albumModel = model.albumArray[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.isYanPin = self.isYanPin;
        
        return cell;
    }
}

// 颜品未认证弹窗
- (void)yanPinPopAlert:(NSString *)message url:(NSString *)url isPush:(BOOL)isPush {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([url isEqualToString:@"/album/ifinabvip"]) {
            
            if (isPush) {
                HLOpenYanPinVipController *vc = [[HLOpenYanPinVipController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        } else {
            HLAuthCenterController *vc = [[HLAuthCenterController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
    
}

#pragma PhotoManageDelegte

- (void)photoButtonClick:(NSInteger)tage withIndexPath:(NSIndexPath *)indexPath andIsLike:(BOOL)islike{
    
    theRowInt = indexPath.section;
    
    HLAlbumModel *model = self.albumArray[indexPath.section - 1];
    HLPreviewPhotoViewController *previewVC = [[HLPreviewPhotoViewController alloc] init];
    previewVC.albumModel = model.albumArray[indexPath.row];
    previewVC.isLike = islike;
    previewVC.isTag = @"动态管理";
    previewVC.scrollIndexPath = [NSIndexPath indexPathForItem:tage inSection:0];
    [self.navigationController pushViewController:previewVC animated:YES];

}

- (void)deleteButtonClickIndexPath:(NSIndexPath *)indexPath andMessage:(NSString *)message {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 删除发布
        [self delFaBuClickWithCurrentIndex:indexPath];
    }];
    
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:action];
    [alertC addAction:cancelAct];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

- (void)colletionButtonClick:(BOOL)isLike {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
}

#pragma mark - - - - - - 接口部分 - - - - - - - -

- (void)requsetAlbumInfoWithPege:(NSInteger)page {
    
    NSString *theURL = [NSString string];
    
    if (self.isYanPin) { // 发布颜品动态的url
        theURL = @"/album/abget";
    } else { // 普通动态url
        theURL = HLAlbum_Info;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"page":[NSNumber numberWithInteger:page]
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:theURL withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@: %@",theURL,dictionary);
        
        self.tableView.mj_footer.hidden = NO;
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"] ) {
            
            NSMutableArray *dataArray = [HLAlbumModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (dataArray.count >= 10) {
                [weakSelf.albumArray addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshing];
            } else if (dataArray.count < 10 && dataArray.count != 0) {
                [weakSelf.albumArray addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
        }
        else if ([[dictionary[@"code"] stringValue] isEqualToString:@"202"]) { // 暂无数据
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else {
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}

// 删除发布
- (void)delFaBuClickWithCurrentIndex:(NSIndexPath *)currentIndex {
    
    NSString *theURL = [NSString string];
    
    if (self.isYanPin) { // 发布颜品动态的url
        theURL = @"/album/abdel";
    } else { // 普通动态url
        theURL = HLAlbum_Del;
    }
    
    WeakSelf(weakSelf);
    HLAlbumModel *model = self.albumArray[currentIndex.section - 1];
    HLAlbumDetails *detailModel = model.albumArray[currentIndex.row];
    [HLHTTPSessionManager postDataWithNSString:theURL withDictionary:@{@"uid":detailModel.uid,@"aid":detailModel.albumId} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            // 通知广场刷新, 顺带本业一起刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"获取相册信息失败"];
    }];
    
}

// 非颜品会员只能发布一条, 并提示开通会员
- (void)yanPinVIP {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/album/ifinabvip" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/album/ifinabvip: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"] ) {
            
            HLReleaseViewController *releaseVC = [[HLReleaseViewController alloc] init];
            releaseVC.isYanPin = self.isYanPin;
            [weakSelf.navigationController pushViewController:releaseVC animated:YES];
               
        } else {
            
            if ([dictionary[@"msg"] isEqualToString:@"您可以发送的信息数量已满"]) { // 不用跳会员界面
                
                [self yanPinPopAlert:dictionary[@"msg"] url:@"/album/ifinabvip" isPush:NO];
            } else {
                
                [self yanPinPopAlert:dictionary[@"msg"] url:@"/album/ifinabvip" isPush:YES];
            }
            
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 跳转设置link界面
- (void)linkButtonClickWithTag:(NSInteger)senderTag oldUrl:(NSString *)oldUrl {
    
    HLSettingLinkController *vc = [[HLSettingLinkController alloc] init];
    
    vc.aid = [NSString stringWithFormat:@"%ld",senderTag];
    vc.oldUrl = oldUrl;
    
    [self.navigationController pushViewController:vc animated:YES];
    
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
