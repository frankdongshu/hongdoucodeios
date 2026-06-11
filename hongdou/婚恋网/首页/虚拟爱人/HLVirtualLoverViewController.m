//
//  HLVirtualLoverViewController.m
//  婚恋网
//
//  Created by iMac on 2019/9/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLVirtualLoverViewController.h"
#import "CoreLocation/CoreLocation.h"
#import "HLFrienderDetailViewController.h"
#import "HLWebNoNavigationController.h"
#import "VirtualLoverCell.h"

@interface HLVirtualLoverViewController () {
    
    NSInteger currentPage; // 分页
    
}
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableDictionary *imageHeights;  // 存放图片高度
@property (nonatomic, strong) NSMutableDictionary *imageData;  // 存放图片资源


@end

@implementation HLVirtualLoverViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isLogin) {
        [self.dataSource removeAllObjects];
    }
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:DismissLoginView object:nil];
    self.dataSource = [NSMutableArray array];
    self.imageHeights = [NSMutableDictionary dictionary];  // 存储图片高度
    self.imageData = [NSMutableDictionary dictionary];
    [self initTableView];
    [self.tableView.mj_header beginRefreshing];
    
}


//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 226.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[VirtualLoverCell class] forCellReuseIdentifier:@"VirtualLoverCell"];
    
    //    self.tableView.mj_footer.hidden = NO;
}

- (void)loadMoreData {
    
    //    if (!self.isLogin) {
    //        [self.view showErrorWithMessage:@"请登录后尝试"];
    //        [self.tableView.mj_footer endRefreshing];
    //
    //        return;
    //    }
    
    currentPage ++;
    [self requestNearbyWithPege:currentPage];
    
}


- (void)loadNewData{
    //
    //    if (!self.isLogin) {
    //        [self.view showErrorWithMessage:@"请登录后尝试"];
    //        [self.tableView.mj_header endRefreshing];
    //
    //        return;
    //    }
    
    currentPage = 1;
    [self.dataSource removeAllObjects];
    [self requestNearbyWithPege:currentPage];
    
}

- (void)requestNearbyWithPege:(NSInteger)page {
    
    WeakSelf(weakSelf);
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"page":[NSNumber numberWithInteger:page]
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLAgent_list withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        // 创建信号量，初始值设为 0
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        // 创建并发队列
        dispatch_queue_t downloadQueue = dispatch_queue_create("com.example.downloadQueue", DISPATCH_QUEUE_CONCURRENT);
        
        weakSelf.tableView.mj_footer.hidden = NO;
        
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            NSMutableArray *dataArray = [VirtualLoverModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            
            for (VirtualLoverModel * virtualLoverModel in dataArray) {
                dispatch_async(downloadQueue, ^{
                    NSString *imageURL = virtualLoverModel.poster_img;
                    
                    NSData *cacheData = self.imageData[imageURL];
                    
                    NSData *imageData;
                    if (cacheData) {
                        imageData = cacheData;
                    } else {
                        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                    }
                    
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    if (image) {
                        // 计算图片高度，保持宽度与屏幕宽度一致
                        CGFloat imageWidth = image.size.width;
                        CGFloat imageHeight = image.size.height;
                        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
                        CGFloat scaledHeight = (imageWidth > 0) ? (screenWidth * imageHeight / imageWidth) : 226;
                        
                        // 存储计算后的高度
                        self.imageHeights[imageURL] = @(scaledHeight);
                        self.imageData[imageURL] = imageData;
                    }
                    
                    // 每个任务完成后，通知信号量（信号量值加 1）
                    dispatch_semaphore_signal(semaphore);
                });
            }
            
            
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
            
        } else {
            [self.view showError:dictionary[@"msg"]];
        }
        
        [weakSelf setRequestFiledView];
        // 创建一个任务来等待所有图片下载完成
        dispatch_async(downloadQueue, ^{
            for (int i = 0; i < weakSelf.dataSource.count; i++) {
                // 等待每个图片下载完成
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            
            // 所有图片下载完成后，在主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        });
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
        [self setRequestFiledView];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
}

- (void)setRequestFiledView {
    
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
    } else {
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }
}

#pragma mark - tableDelegaet

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VirtualLoverCell *cell = (VirtualLoverCell*)[tableView dequeueReusableCellWithIdentifier:@"VirtualLoverCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.dataSource.count > 0) {
        
        NSString *imageURL = ((VirtualLoverModel *)self.dataSource[indexPath.row]).poster_img;
        
        // 异步加载图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
            NSData *imageData = self.imageData[imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            
            if (image) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.sexImageView.image = image;
                    
                    // 强制更新 cell 大小
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                });
            }
        });
        
    }
    
    
    
    return cell;
}

// 动态计算 cell 高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= self.dataSource.count) {
        return 0.0f;
    }
    
    NSString *imageURL = ((VirtualLoverModel *)self.dataSource[indexPath.row]).poster_img;
    NSNumber *height = self.imageHeights[imageURL];
    
    return height ? height.floatValue : 226; // 默认高度 226，避免第一次加载时高度为 0
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 未登录
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    VirtualLoverModel *virtualLoverModel = self.dataSource[indexPath.row];
    
    HLWebNoNavigationController *vc = [[HLWebNoNavigationController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.url = virtualLoverModel.url;
    vc.titleString = (virtualLoverModel.name.length)?virtualLoverModel.name : @"智能体";
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

@end
