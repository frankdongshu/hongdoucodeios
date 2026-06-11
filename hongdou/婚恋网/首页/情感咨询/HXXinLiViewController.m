//
//  HXXinLiViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/16.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXXinLiViewController.h"
#import "HDHomeCell.h"
#import "CSHomeModel.h"
#import "ChooseCityController.h" // 筛选城市
#import "CSCoachDetailViewController.h" // 详情
#import "HLNewChatViewController.h" // 聊天界面

@interface HXXinLiViewController ()<CSHomeDelegate>

@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *cityString;
@property (nonatomic, strong) UIView *noDataView;

@end

@implementation HXXinLiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTableView];
    
    self.listArray = [NSMutableArray array];
    self.cityString = [NSString string];
    
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginUserLoadList) name:DismissLoginView object:nil];
    
}

- (void)loginUserLoadList {
    
    // 回到顶部
    [self.tableView reloadData];
    
    if ([self.tableView numberOfRowsInSection:0]) {
        NSIndexPath *indexPathOne = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPathOne atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    // 请求数据
    [self.tableView.mj_header beginRefreshing];
    
    
}

- (void)loadNewData {
    [self requestDataWithCity:self.cityString];
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    //设置预估行高
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HDHomeCell" bundle:nil] forCellReuseIdentifier:@"HDHomeCell"];
    
}

- (UIView *)noDataView {
    if (_noDataView == nil) {
        _noDataView = [[UIView alloc] initWithFrame:self.tableView.frame];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, kScreenWidth, 20)];
        titleLab.text = @"暂无数据";
        titleLab.textColor = HEXColor(@"666666");
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:titleLab];
        
    }
    return _noDataView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"重置" forState:UIControlStateNormal];
    button.titleLabel.font = kFontSize(16);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(kScreenWidth-100, 0, 50, 44);
    [button addTarget:self action:@selector(resetSelector) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"tousu_ico"] forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(kScreenWidth-50, 0, 50, 44);
    [button1 addTarget:self action:@selector(choosePressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button1];
    
    
    return view;
}

// 重置
- (void)resetSelector {
    
    [self.view showLoadMessageAtCenter];
    
    self.cityString = @"";
    
    [self requestDataWithCity:@""];
    
}
// 筛选
- (void)choosePressed {
    
    ChooseCityController *vc = [[ChooseCityController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.seleArray = [NSMutableArray arrayWithArray:@[self.cityString]];
    vc.block = ^(NSString * city) {
        
        self.cityString = city;
        
        [self requestDataWithCity:city];
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDHomeCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate  = self;
    cell.iscell = MainCell;
    cell.indexPath = indexPath;
    
    cell.homeMod = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CSHomeModel *mod = self.listArray[indexPath.row];
    
    [self requestUserDetailWithModel:mod];
    
}

#pragma mark - CSHomeDelegate
- (void)chartButtonClick:(NSIndexPath *)indexPath {
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    // 自己是咨询师就不能和咨询师聊天了
    [self requestIsTeather:indexPath];
    
}

// 是否是咨询师
- (void)requestIsTeather:(NSIndexPath *)indexPath {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self.view showLoadMessageAtCenter];
    [HLHTTPSessionManager postDataWithNSString:@"/mind/ismind" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        
        NSLog(@"/mind/ismind: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.view showTitle:@"同行不能聊天!"];
            
        } else {
            
            [self.view hide];
            
            CSHomeModel *model = self.listArray[indexPath.row];
            
            
            HLChatController *vc = [[HLChatController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.chatDic = @{
                @"cid":model.userId,
                @"cname":model.nickname,
                @"cmobile":model.username,
                @"chead":model.head
            };
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
    }];
    
}


- (void)requestDataWithCity:(NSString *)city {
    
    NSDictionary *parmas = @{
        @"city":city,
        @"uid":kISNullObject([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/coach" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/coach: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hide];
            
            self.listArray = [CSHomeModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            
            if (self.listArray.count > 0) {
                self.tableView.tableFooterView = [[UIView alloc] init];
            } else {
                self.tableView.tableFooterView = self.noDataView;
            }
            
        } else {
            [self.view showError:dictionary[@"msg"]];
            [self.tableView.mj_header endRefreshing];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
        [self.tableView.mj_header endRefreshing];
    }];
    
}

- (void)requestUserDetailWithModel:(CSHomeModel *)mod {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"cid":mod.userId
    };
    
    [self.view showLoadMessageAtCenter];
    [HLHTTPSessionManager postDataWithNSString:@"/mind/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/mind/details: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hide];
            
            CSCoachDetailViewController *vc = [[CSCoachDetailViewController alloc] init];
            vc.model = [CSCoachDetailModel mj_objectWithKeyValues:dictionary[@"data"]];
            vc.userMod = mod; // 为了关注
            vc.isApp = HongApp;
            vc.sureBlock = ^{
                [self loadNewData];
            };
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
            
        } else {
            [self.view showError:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
    }];
    
    
}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

//- (void)listDidAppear {
//    [self loadNewData];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
