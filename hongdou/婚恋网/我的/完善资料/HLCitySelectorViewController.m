//
//  HLCitySelectorViewController.m
//  hongdou
//
//  Created by iMac on 2019/9/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLCitySelectorViewController.h"
#import "HLTopToolsTableViewCell.h"

@interface HLCitySelectorViewController ()<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allCityArray;
@property (nonatomic, strong) NSMutableArray *currentCityArray; // 当前城市
@property (nonatomic, strong) NSMutableArray *citysArray; // 城市列表
@property (nonatomic, strong) NSMutableArray *popularCityArray;//热门城市类表
@property (nonatomic, strong) NSMutableArray *indexArrary; // 索引标签
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation HLCitySelectorViewController

//开始定位
- (void)startLocation {
    
    //判断是否有定位权限
    if ([CLLocationManager locationServicesEnabled]) {
        // 开启定位
        [self.locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"系统定位尚未打开，请到【设置-隐私-定位服务】中手动打开");
    }
    
}

#pragma mark -定位设置
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        // 创建CoreLocation管理对象
        CLLocationManager *locationManager = [[CLLocationManager alloc]init];
        // 定位权限检查
        [locationManager requestWhenInUseAuthorization];
        // 设定定位精准度
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        // 设置代理
        locationManager.delegate = self;
        
        _locationManager = locationManager;
    }
    return _locationManager;
    
}

#pragma mark -代理方法，定位权限检查
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            NSLog(@"用户还未决定授权");
            // 主动获得授权
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            // 主动获得授权
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusDenied:{
            // 此时使用主动获取方法也不能申请定位权限
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
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

#pragma mark -获取位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation * newLocation = [locations lastObject];
    // 判空处理
    if (newLocation.horizontalAccuracy < 0) {
        NSLog(@"定位失败，请检查手机网络以及定位");
        return;
    }
    //停止定位
    [self.locationManager stopUpdatingLocation];
    // 获取定位经纬度
    CLLocationCoordinate2D coor2D = newLocation.coordinate;
    NSLog(@"纬度为:%f, 经度为:%f", coor2D.latitude, coor2D.longitude);
    
    [self uploadLocationWithLatitude:coor2D];
   
}
#pragma mark -定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
     NSLog(@"定位失败,请检查手机网络以及定位");
}

// 请求当前城市
- (void)uploadLocationWithLatitude:(CLLocationCoordinate2D)coor2D {
    
    NSDictionary *params = @{
        @"lon":@(coor2D.longitude),
        @"lat":@(coor2D.latitude)
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager getDataWithNSString:@"/index/get_city" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            NSDictionary *dic = [dictionary objectForKey:@"data"];
            
            if (!kISNullObject(dic)) {
                
                HLCityModel *model = [[HLCityModel alloc] init];
                
                model.cityID = dic[@"id"];
                model.cityName = dic[@"city"];
                
                weakSelf.currentCityArray = [NSMutableArray arrayWithObject:model];
            }
            
            [weakSelf.tableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [HXNavigationController createNavigationBarForViewController:self];

    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    self.sc_navigationBar.title = @"城市列表";
    
    // 获取经纬度
    [self startLocation];
    
    self.allCityArray = [NSMutableArray array];
    self.currentCityArray = [NSMutableArray array];
    self.citysArray = [NSMutableArray array];
    self.popularCityArray = [NSMutableArray array];
    self.indexArrary = [NSMutableArray array];
    [self.view addSubview:self.tableView];
    [self requestHome];
}
// 请求居住地
- (void)requestHome{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager getDataWithNSString:HLCity_list withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            NSDictionary *dic = [dictionary objectForKey:@"data"];
            if (![[dic objectForKey:@"major"] isKindOfClass:[NSNull class]]) {
                weakSelf.popularCityArray = [HLCityModel  mj_objectArrayWithKeyValuesArray:[dic[@"major"] objectForKey:@"lists"]];
            }
            [weakSelf.indexArrary addObject:@" "];
            [weakSelf.indexArrary addObject:@" "];
            if (![[dic objectForKey:@"all"] isKindOfClass:[NSNull class]]) {
                weakSelf.allCityArray = [HLAllCityModel  mj_objectArrayWithKeyValuesArray:[dic objectForKey:@"all"]];
                [weakSelf.allCityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    HLAllCityModel *model = obj;
                    [weakSelf.indexArrary addObject:model.title];
                }];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark -- tableview

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight) style:UITableViewStylePlain];
        _tableView.sectionIndexColor = [UIColor colorWithRed:0/255.0f green:132/255.0f blue:255/255.0f alpha:1];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[HLTopToolsTableViewCell class] forCellReuseIdentifier:@"HLTopToolsTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

#pragma mark -- UITableViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexArrary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section==0 || section==1) {
        return 1;
    }
    HLAllCityModel *allModel =  self.allCityArray[section-2];
    return allModel.cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.section == 0) {
        HLTopToolsTableViewCell * topCell = [[HLTopToolsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HLTopToolsTableViewCell"];
        [topCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        topCell.dataArry = self.currentCityArray;
        topCell.selectCityBlock = ^(HLCityModel * _Nonnull model) {
            NSLog(@"选择的城市是:%@",model.cityName);
            if (self.selectorCityBlock) {
                self.selectorCityBlock(model);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        };
        return topCell;
        
    }
    else if (indexPath.section == 1) {
        HLTopToolsTableViewCell * topCell = [[HLTopToolsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HLTopToolsTableViewCell"];
        [topCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        topCell.dataArry = self.popularCityArray;
        topCell.selectCityBlock = ^(HLCityModel * _Nonnull model) {
            NSLog(@"选择的城市是:%@",model.cityName);
            if (self.selectorCityBlock) {
                self.selectorCityBlock(model);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        };
        return topCell;
        
    }else{
        HLAllCityModel *allModel =  self.allCityArray[indexPath.section-2];
        NSArray *cityArray  = allModel.cityArray;
        HLCityModel *cityModel = cityArray[indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.text = cityModel.cityName;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        return cell;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"当前城市";
    }
    if (section == 1) {
        return @"热门城市";
    }
    return self.indexArrary[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArrary;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section>1) {
        HLAllCityModel *allModel =  self.allCityArray[indexPath.section-2];
        NSArray *cityArray  = allModel.cityArray;
        HLCityModel *cityModel = cityArray[indexPath.row];
        NSLog(@"选择的城市是:%@  id：%@",cityModel.cityName,cityModel.cityID);
        if (self.selectorCityBlock) {
            self.selectorCityBlock(cityModel);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    if (indexPath.section == 0) {
        if (self.currentCityArray.count>0) {
//            height = [self calculateCellHeightWithCount:self.currentCityArray.count];
            
            height = 56;
        }
    }
    if (indexPath.section == 1) {
        if (self.popularCityArray.count>0) {
            height = [self calculateCellHeightWithCount:self.popularCityArray.count];
        }
    }
    return height;
}
- (CGFloat)calculateCellHeightWithCount:(NSInteger)count {
    NSInteger tempCount = count / 3;
    if ((count % 3) > 0) {
        tempCount += 1;
    }
    return tempCount * 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  {
    CGFloat height = 30;
    if (section == 0) {
        if (self.currentCityArray.count==0) {
            height = 0;
        }
    }
    if (section == 1) {
        if (self.popularCityArray.count==0) {
            height = 0;
        }
    }
    return height;
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
