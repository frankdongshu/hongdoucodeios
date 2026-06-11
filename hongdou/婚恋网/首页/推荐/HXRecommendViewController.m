//
//  HXRecommendViewController.m
//  婚恋网
//
//  Created by iMac on 2019/9/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXRecommendViewController.h"
#import "HLHometableViewCell.h"
#import "HLFrienderDetailViewController.h"
//#import "JCHATConversationViewController.h"
#import "HLNewChatViewController.h"
#import "HDPreviewPhotoController.h"
#import "HXSettingView.h"
#import "HXWelcomeView.h"
#import "HLOpenMemberViewController.h"
#import "HLZuanShiVipCell.h"
#import <RPSDK/RPSDK.h>
#import "HLRecCell.h"

@interface HXRecommendViewController ()<HLHomeDelegate,CLLocationManagerDelegate,HLRecCellDeleagte> {
    int _page; // 分页
    
    NSString *_imgUrl;
    
    CGFloat _imgCellHeight;
    
    // 设置按钮, 记录是否点击只看同城
    int _isSwitch;
    
    CLLocationManager *locationmanager;//定位服务
}

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *settingBtn;

@property (nonatomic, strong) NSString *timeString;

@property (nonatomic, strong) UIView *warnMsgView;
@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;

@end

@implementation HXRecommendViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestHomeImg];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 添加监听
    [self addNotification];
    
    
    self.dataSource = [NSMutableArray array];
    
    [self initTableView];
    [self.tableView.mj_header beginRefreshing];
    
//    // 防止设置按钮, 超出到推荐页面
//    self.view.clipsToBounds = YES;
//
//    self.settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//
//    [self.settingBtn setTitle:@"筛选   " forState:UIControlStateNormal];
//    [self.settingBtn setImage:[UIImage imageNamed:@"vvip_setting"] forState:UIControlStateNormal];
//
//    [self.settingBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleLeft imageTitleSpace:5];
//
//    self.settingBtn.titleLabel.font = [UIFont fontWithName:@"Medium" size:14];
//    [self.settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    self.settingBtn.backgroundColor = kRGBA(0, 0, 0, .5);
//    self.settingBtn.layer.cornerRadius = 18;
//    [self.settingBtn addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
//
//
//    [self.view addSubview:self.settingBtn];
//
//    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//
//        make.right.mas_equalTo(18);
//        make.width.mas_equalTo(100);
//        make.height.mas_equalTo(36);
//        make.centerY.equalTo(self.view.mas_centerY).offset(115);
//    }];
    
    
    if (self.isLogin) {
        // 开启定位
        [self startLocation];
    }
}

// 请求倒计时时间
- (void)requestTime {
    
    if (!self.isLogin) {
        return;
    }
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_display_t" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];

        if ([code isEqualToString:@"200"] ) {
            
            NSLog(@"==>: %@",dictionary);
            
            self.timeString = dictionary[@"data"][@"t"];
            
            [self.tableView reloadData];

        }else {
            [[UIApplication sharedApplication].keyWindow showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow showTostWithMessage:@"修改失败，请重试"];

    }];
}

// 开始定位
- (void)startLocation {
    
    //判断定位功能是否打开
    if ([CLLocationManager locationServicesEnabled]) {
        locationmanager = [[CLLocationManager alloc]init];
        locationmanager.delegate = self;
        [locationmanager requestAlwaysAuthorization];
        [locationmanager requestWhenInUseAuthorization];
        
        // 设置寻址精度
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
        // 变化距离  超过100米 重新定位
        locationmanager.distanceFilter = 100;
        [locationmanager startUpdatingLocation];
    } else {
        NSLog(@"系统定位尚未打开，请到【设置-隐私-定位服务】中手动打开");
    }
    
}

#pragma mark - CLLocationManagerDelegate
// 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([error code] == 1) {
        //没有位置访问权限
    }
    
}

// 定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    [locationmanager stopUpdatingHeading];
   
    CLLocation *currentLocation = [locations lastObject];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"lng":@(currentLocation.coordinate.longitude),
        @"lat":@(currentLocation.coordinate.latitude)
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLUser_Location withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/ulist/location: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];
    }];
    
}

// 定位权限检查
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            NSLog(@"用户还未决定授权");
            // 主动获得授权
            [locationmanager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            // 主动获得授权
            [locationmanager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusDenied:{
            // 此时使用主动获取方法也不能申请定位权限
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
                
                // 提示用户开启权限
                [self alertLocationView];
                
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}

- (void)alertLocationView {
    
    //设置提示提醒用户打开定位服务
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"允许定位提示" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        //跳入当前App设置界面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

// 添加监听
- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLoginClick) name:DismissLoginView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:@"squareReloadList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(welcomeViewShow) name:@"WELCOME_iMG" object:nil];
    
}

- (void)reLoginClick {
    [self loginUserLoadList];
    [self startLocation];
}

// 设置按钮触发
- (void)settingClick {
    
    HXSettingView *view = [[HXSettingView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    view.isSwichOn = self->_isSwitch;
    
    view.SelectBlock = ^(BOOL isSelect) {
        
        self->_isSwitch = isSelect;
        
        self->_page = 1; // 初始值第一页开始
        [self.dataSource removeAllObjects];
        
        [self loginUserLoadList];
        
    };
    
    [view showSelf];
    
    
}

// 展示欢迎界面
- (void)welcomeViewShow {
    
    if (!self.isLogin) {
        return;
    }
    
    HXWelcomeView *view = [[HXWelcomeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    view.SelectBlock = ^(NSString * sign) {
        
        NSLog(@"->>>%@",sign);
        
        if ([sign isEqualToString:@"vip"]) {
            
            HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_WELCOME" object:nil];
        }
    };
    
    [view showSelf];
    
}

- (void)loginUserLoadList {
    
    [self.view showLoadMessageAtCenter];
    
    if (!self.isLogin) {
        [self.view hide];
    }
    
    // 回到顶部
    [self.tableView reloadData];
    
    if ([self.tableView numberOfRowsInSection:0]) {
        NSIndexPath *indexPathOne = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPathOne atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    self.tableView.mj_footer.hidden = YES;
    
    // 请求数据
    [self.tableView.mj_header beginRefreshing];
    
}



//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLHometableViewCell" bundle:nil] forCellReuseIdentifier:@"HLHometableViewCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HLZuanShiVipCell" bundle:nil] forCellReuseIdentifier:@"HLZuanShiVipCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HLRecCell" bundle:nil] forCellReuseIdentifier:@"HLRecCell"];
    
}


- (void)loadNewData{
    
    if (!self.isLogin) {
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        
        self->_isSwitch = 0;
    }
    
    // 不登录不显示
    self.settingBtn.hidden = !self.isLogin;
    
    [self requestTime];
    
    _page = 1; // 初始值第一页开始
    
    [self requestRecommend];
    
}

- (void)loadMoreData {
    
    _page ++;
    
    [self requestRecommend];
}


- (void)requestRecommend {
    
    // 游客登录
    NSDictionary *params = @{
        @"visitor":@"yes",
        @"page":[NSNumber numberWithInt:_page]
    };
    
    if (self.isLogin) {
        params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"page":[NSNumber numberWithInt:_page],
            @"tc":@(self->_isSwitch)
        };
    }
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLTuijian_friends withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        HDLog(@"推荐列表: %@",dictionary);
        
        self.tableView.mj_footer.hidden = NO;
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.view hide];
            
            if (self->_page == 1) {
                [self.dataSource removeAllObjects];
            }
            
            NSMutableArray *dataArray = [HLUser mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (dataArray.count >= 10) {
//                for (int i = 0; i< dataArray.count; i++) {
//                    HLUser * model =dataArray[i];
//                    
//                    NSLog(@"====dataArray===HLUser=%@",model.nickname);
//                    NSLog(@"====dataArray===HLUser=%@",model.head);
//                    NSLog(@"=====dataArray==HLUser=%@",model.userid);
//                }
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                
                if (self->_page == 1) {
                    // 图片的占位
                    [weakSelf.dataSource insertObject:@"" atIndex:0];
                    //同城的占位
                    [weakSelf.dataSource insertObject:@"" atIndex:1];
                }
                
                
//                for (int i = 0; i< weakSelf.dataSource.count; i++) {
//                    HLUser * model =weakSelf.dataSource[i];
//
//                    NSLog(@"=======HLUser=%@",model.nickname);
//                    NSLog(@"=======HLUser=%@",model.head);
//                    NSLog(@"=======HLUser=%@",model.userid);
//                }
                
                
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
            [self.view showTitle:dictionary[@"msg"]];
        }
        
//        [self.dataSource removeAllObjects];
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        
        [self requestHomeImg];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
        [weakSelf.tableView.mj_header endRefreshing];
        [self setRequestFiledView];
        [self requestHomeImg];
    }];
    
}




-(void)setRequestFiledView
{
    if (self.dataSource.count == 0) {
        
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//        blankBg.backgroundColor =  [UIColor redColor];
        self.warnMsgView = blankBg;
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom+50, kScreenWidth-60, 80)];
        
        warnMsg.numberOfLines = 2;
        warnMsg.text = @"点击开始使用";
        warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
        warnMsg.font = [UIFont systemFontOfSize:16];
        warnMsg.textAlignment = NSTextAlignmentCenter;
        warnMsg.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateDataClick)];
        [warnMsg addGestureRecognizer:tap];
        [blankBg addSubview:warnMsg];
//        [self.tableView setTableHeaderView:blankBg];
//        [self.tableView.mj_header endRefreshing];
        [self.view addSubview:blankBg];
        [self.view bringSubviewToFront:blankBg];
    }else
    {
//        [self.view sendSubviewToBack:self.warnMsgView];
        [self.warnMsgView removeFromSuperview];
        self.warnMsgView =nil;
        
//        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
//        view.backgroundColor = [UIColor clearColor];
//        self.tableView.tableHeaderView = view;
    }
}
#pragma mark 点击事件
- (void)updateDataClick{
    
    [self requestRecommend];
    
}
#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return _imgCellHeight;
    }
    if (indexPath.row == 1) {
        if (self.isLogin) {
            return UITableViewAutomaticDimension;
        }
        return 0;
    }
    
    return UITableViewAutomaticDimension;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        HLZuanShiVipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLZuanShiVipCell"];
        cell.selectionStyle = 0;
        
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self->_imgUrl]];
        
        return cell;
    }
    
    if (indexPath.row == 1) {
        HLRecCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLRecCell"];
        cell.selectionStyle = 0;
        
        cell.timeLab.text = [NSString stringWithFormat:@"下波推荐:%@ | ",self.timeString];
        
        cell.delegate = self;
        
        [cell.swicthOn setOn:_isSwitch];
//        if (self.isLogin) {
//            cell.swicthOn.hidden = NO;
//            cell.localLabel.hidden = NO;
//
//        }else{
//            cell.swicthOn.hidden = YES;
//            cell.localLabel.hidden = YES;
//        }
        
        return cell;
    }
    
    HLHometableViewCell *cell = (HLHometableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLHometableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.dataSource.count > 0) {
        cell.model = self.dataSource[indexPath.row];
    }
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.weakSelf = self;
    return cell;
    
}

- (void)updateBtnClick {
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/upd_display" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/upd_display %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self->_page = 1; // 初始值第一页开始
            [self.dataSource removeAllObjects];
            
            [self loginUserLoadList];
            
        } else {
//            [self.view showTitle:dictionary[@"msg"]];
            
            HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
    
}

- (void)refreshTableViewWithSwitch:(UISwitch *)theSwitch {
    
    if (self.isVip) {
    self->_isSwitch = theSwitch.on;
    
    self->_page = 1; // 初始值第一页开始
    [self.dataSource removeAllObjects];
    
    [self loginUserLoadList];
    }else{
        self->_isSwitch = NO;
        [theSwitch setOn:NO];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:@"此功能为VIP专属功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
//            HLGoV ipViewController *vc = [[HLGoVipViewController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
            //开通会员
            HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
            openVC.rewardVideoAd = self.rewardVideoAd;
            openVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:openVC animated:YES];
            
        }];
      
    
        [alertC addAction:action];
        
        [self presentViewController:alertC animated:YES completion:nil];
        
    }
}

// 提示人脸认证图片
- (void)requestHomeImg {
    
    NSDictionary *dic = @{
        @"sign":@"buyVIPiostuijian"
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/notice %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self->_imgUrl = dictionary[@"data"][@"val"];
            
            [[[UIImageView alloc] init] sd_setImageWithURL:[NSURL URLWithString:self->_imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                self->_imgCellHeight = image.size.height/image.size.width*kScreenWidth;
                            
            }];
            
            
            [weakSelf.tableView reloadData];
            
        } else {
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 未登录
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    if (indexPath.row == 0) {
        
//        HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//
        HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
        openVC.rewardVideoAd = self.rewardVideoAd;
        openVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:openVC animated:YES];
        
        
        return;
    }
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.userInfo = self.dataSource[indexPath.row];
    HLUser *model = self.dataSource[indexPath.row];
    if (model) {
        detailVC.userId = model.userid;
    }
    detailVC.refreshBlock  = ^{
        HLUser *model = self.dataSource[indexPath.row];
        model.in_follow = YES;
        model.fans = [NSString stringWithFormat:@"%d",[model.fans intValue]+1];
        [self.tableView reloadData];
    };
    detailVC.removeBlock = ^{
        
        [self.dataSource removeObject:self.dataSource[indexPath.row]];
        
        [self.tableView reloadData];
        
    };
    
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

// 是否认证
- (void)requestAuthStatus {
    
    [MBProgressHUD showLoading];
    
    // 是否人脸认证
    [HLHTTPSessionManager postDataWithNSString:@"/user/certification" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"certification: %@",dictionary);
        
        [MBProgressHUD hideLoading];
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (![[dictionary[@"data"][@"VerifyStatus"] stringValue] isEqualToString:@"1"]) { // 未认证
                
                [self authFace];
                
            } else { // 已认证
                
                [MBProgressHUD showMessage:@"已认证" view:nil];
            }
            
        } else if ([[dictionary[@"code"] stringValue] isEqualToString:@"202"]) {
            // code 202 尚未认证
            [self authFace];
            
        } else {
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD showMessage:@"判断人脸是否认证失败" view:nil];
        
    }];
    
}

// 去人脸认证
- (void)authFace {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":[LoginManager defaultManager].avatar
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/getAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"getAlibabaToken: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [MBProgressHUD hideLoading];
            
            [RPSDK startWithVerifyToken:dictionary[@"data"][@"VerifyToken"]
                         viewController:self
                             completion:^(RPResult * _Nonnull result) {
                // 建议接入方调用实人认证服务端接口 DescribeVerifyResult，
                // 来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                NSLog(@"真人头像认证结果：%@", result);
                switch (result.state) {
                    case RPStatePass:
                        // 认证通过。
                        NSLog(@"真人头像认证成功");
                        break;
                    case RPStateFail:
                        // 认证不通过。
                        break;
                    case RPStateNotVerify:
                        // 未认证。
                        // 通常是用户主动退出或者姓名身份证号实名校验不匹配等原因导致。
                        // 具体原因可通过 result.errorCode 和 result.message 来区分（详见错误码说明）。
                        break;
                }
            }];
            
        } else {
            [MBProgressHUD showMessage:@"获取Token失败" view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

#pragma mark HLHomeDelegate

// 不感兴趣
- (void)closeButtonClick:(NSIndexPath *)indexPath {
    [self.dataSource removeObject:self.dataSource[indexPath.row]];
    
    [self.tableView reloadData];
}

// 聊天前审核
- (void)chartButtonClick:(NSIndexPath *)indexPath {
    
    if (!self.isLogin) { // 未登录
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    [self.view showLoadMessageAtCenter];
    
    [HLHTTPSessionManager postDataWithNSString:HLUser_ExamineType withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/examineType: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",dictionary[@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            if ([[dictionary[@"data"][@"type"] stringValue] isEqualToString:@"1"]) {
                
                [self.view hide];
                
                HLUser *model = self.dataSource[indexPath.row];
                
                HLChatController *vc = [[HLChatController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.chatDic = @{
                    @"cid":model.userid,
                    @"cname":model.nickname,
                    @"cmobile":model.username,
                    @"chead":model.head
                };
                
                [self.navigationController pushViewController:vc animated:YES];
                
               
            } else {
                [self.view showTitle:@"您的个人资料审核未通过，请修改个人资料后继续使用"];
            }
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTitle:@"/user/examineType报错"];
    }];
    
}

// 预览照片
- (void)browerPhotoClick:(NSArray *)picArrs withCurrentIndex:(NSInteger)index{
    
    HDPreviewPhotoController *previewVC = [[HDPreviewPhotoController alloc] init];
    previewVC.hidesBottomBarWhenPushed = YES;
    previewVC.picArray = picArrs;
    previewVC.selectIdx = index;
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
