//
//  HLNearbyViewController.m
//  婚恋网
//
//  Created by iMac on 2019/9/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNearbyViewController.h"
#import "HLSquareTableViewCell.h"
#import "CoreLocation/CoreLocation.h"
#import "HLFrienderDetailViewController.h"

@interface HLNearbyViewController ()<CLLocationManagerDelegate>
{
    
    CLLocationManager *locationmanager;//定位服务
    
    NSString *strlatitude;//经度
    
    NSString *strlongitude;//纬度
    
    NSInteger currentPage; // 分页
    
}
@property (nonatomic, strong)NSMutableArray *dataSource;


@end

@implementation HLNearbyViewController

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
    [self initTableView];
    [self loadNewData];
    [self startLocation];
}

//开始定位
- (void)startLocation {
    
    //判断定位功能是否打开
    if ([CLLocationManager locationServicesEnabled]) {
        locationmanager = [[CLLocationManager alloc]init];
        locationmanager.delegate = self;
        [locationmanager requestAlwaysAuthorization];
        [locationmanager requestWhenInUseAuthorization];
        
        //设置寻址精度
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
        locationmanager.distanceFilter = 5.0;
        [locationmanager startUpdatingLocation];
    }
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLSquareTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLSquareTableViewCell"];
    
    self.tableView.mj_footer.hidden = NO;
}

- (void)loadMoreData {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.tableView.mj_footer endRefreshing];
        
        return;
    }
    
    currentPage ++;
    [self requestNearbyWithPege:currentPage];
    
}


- (void)loadNewData{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.tableView.mj_header endRefreshing];
        
        return;
    }
    
    currentPage = 1;
    [self.dataSource removeAllObjects];
    [self requestNearbyWithPege:currentPage];
    
}

- (void)requestNearbyWithPege:(NSInteger)page {
    
    if (self.isLogin) {
        WeakSelf(weakSelf);
        
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"page":[NSNumber numberWithInteger:page]
        };
        
        [HLHTTPSessionManager postDataWithNSString:HLNearby_friends withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"%@",dictionary);
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                NSMutableArray *dataArray = [HLUser mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
                
                if (dataArray.count > 0) {
                    [weakSelf.dataSource addObjectsFromArray:dataArray];
                    [weakSelf.tableView.mj_header endRefreshing];
                    [weakSelf.tableView.mj_footer endRefreshing];
                } else {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                
            } else {
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
    HLSquareTableViewCell *cell = (HLSquareTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLSquareTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.dataSource.count > 0) {
        [cell setUserInfo:self.dataSource[indexPath.row]];
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.userInfo = self.dataSource[indexPath.row];
    HLUser *model = self.dataSource[indexPath.row];
    detailVC.userId = model.userid;
    detailVC.refreshBlock  = ^{
        // 关注了
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

#pragma mark CoreLocation delegate (定位失败)
//定位失败后调用此代理方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //设置提示提醒用户打开定位服务
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"允许定位提示" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 定位成功后则执行此代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    if (!self.isLogin) {
        return;
    }
    if (self.dataSource.count > 0) {
        return;
    }
    
    [locationmanager stopUpdatingHeading];
   
    CLLocation *currentLocation = [locations lastObject];
    //打印当前的经度与纬度
    NSLog(@"经度:%f,纬度:%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLUser_Location withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"lng":@(currentLocation.coordinate.latitude),@"lat":@(currentLocation.coordinate.longitude)} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
//            [self loadNewData];
            
        }else{
//            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }

    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];

    }];
    
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
