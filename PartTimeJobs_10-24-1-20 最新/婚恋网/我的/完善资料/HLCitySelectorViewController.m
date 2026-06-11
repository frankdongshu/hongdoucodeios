//
//  HLCitySelectorViewController.m
//  hongdou
//
//  Created by iMac on 2019/9/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLCitySelectorViewController.h"
#import "HLTopToolsTableViewCell.h"

@interface HLCitySelectorViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allCityArray;
@property (nonatomic, strong) NSMutableArray *citysArray; // 城市列表
@property (nonatomic, strong) NSMutableArray *popularCityArray;//热门城市类表
@property (nonatomic, strong) NSMutableArray *indexArrary; // 索引标签

@end

@implementation HLCitySelectorViewController

// 注册时进入
- (void)registeredBack {
    
    // 退出登录
    [[LoginManager defaultManager] doLogout];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

// 修改时进入
- (void)updateBack {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [HXNavigationController createNavigationBarForViewController:self];

    self.sc_navigationBar.title = @"选择城市";
    
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        if (self.backType == RegisterBack) {
            [self registeredBack];
        } else {
            [self updateBack];
        }
        
    }];
    
    
    self.allCityArray = [NSMutableArray array];
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
    
    if (section==0) {
        return 1;
    }
    HLAllCityModel *allModel =  self.allCityArray[section-1];
    return allModel.cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.section == 0) {
        HLTopToolsTableViewCell * topCell = [[HLTopToolsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HLTopToolsTableViewCell"];
        [topCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        topCell.dataArry = self.popularCityArray;
        topCell.selectCityBlock = ^(HLCityModel * _Nonnull model) {
            NSLog(@"选择的城市是:%@",model.cityName);
            if (self.selectorCityBlock) {
                self.selectorCityBlock(model);
                if (self.backType == UpdateBack) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            }
        };
        return topCell;
        
    }else{
        HLAllCityModel *allModel =  self.allCityArray[indexPath.section-1];
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
        return @"热门城市";
    }
    return self.indexArrary[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexArrary;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section>0) {
        HLAllCityModel *allModel =  self.allCityArray[indexPath.section-1];
        NSArray *cityArray  = allModel.cityArray;
        HLCityModel *cityModel = cityArray[indexPath.row];
        NSLog(@"选择的城市是:%@  id：%@",cityModel.cityName,cityModel.cityID);
        if (self.selectorCityBlock) {
            self.selectorCityBlock(cityModel);
            if (self.backType == UpdateBack) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    if (indexPath.section == 0) {
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
