//
//  HomeController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/11.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HomeController.h"
#import "HDHomeCell.h"
#import "CSHomeModel.h"
#import "ChooseCityController.h" // 筛选城市
#import "CSCoachDetailViewController.h" // 详情
#import "LLBugVipController.h" // 开通会员
#import "LLBuyNumberController.h" // 购买联系方式显示次数

@interface HomeController ()<UITableViewDelegate, UITableViewDataSource> {
    BOOL _isFirst;
    int _page; // 分页
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *cityString;
@property (nonatomic, strong) UIView *noDataView;

@end

@implementation HomeController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight)];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kTabBarHeight, 0);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //设置预估行高
        _tableView.estimatedRowHeight = 100.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        // 去掉多余分割线
        _tableView.tableFooterView = [[UIView alloc] init];
        
        [_tableView registerNib:[UINib nibWithNibName:@"HDHomeCell" bundle:nil] forCellReuseIdentifier:@"HDHomeCell"];
        
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        header.automaticallyChangeAlpha = YES;
        
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        
        // 马上进入刷新状态
        [header beginRefreshing];
        
        // 设置header
        self.tableView.mj_header = header;
        
        
        
        MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        
        footer.refreshingTitleHidden = YES;
        
        self.tableView.mj_footer = footer;
        
        self.tableView.mj_footer.hidden = YES;
        
        
        
        
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDHomeCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.iscell = NoneCell;
    
    cell.homeMod = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CSHomeModel *mod = self.listArray[indexPath.row];
    
    [self requestUserDetailWithModel:mod];
    
}

#pragma mark - 创建悬浮的按钮

- (void)createButton{

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setTitle:@"提升排名" forState:UIControlStateNormal];
    [button setImage:[[UIImage imageNamed:@"tuijian_shua"] imageWithColor:REDColor] forState:UIControlStateNormal];
    [button setTitleColor:REDColor forState:UIControlStateNormal];
    button.frame = CGRectMake(kScreenWidth-85, kNavBarHeight+15, 80, 30);

    button.titleLabel.font = [UIFont systemFontOfSize:13];

    [button addTarget:self action:@selector(resignButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];

}

// 提升排名
- (void)resignButton {
    
    NSDictionary *params = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
    };
    
    [self.view showLoading];
    [HTTPSessionManger postDataWithNSString:@"/coach/is_newranking" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        
        
        NSLog(@"/coach/is_newranking: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            // 更新成功, 调用列表
            [self requestDataList];
            
        } else {
            [self getAlertControllerToVipViewWithMessage:@"请购买置顶功能" andType:@"购买置顶"];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:error.localizedDescription];
    }];
    
}

// 弹出提示并前往开通会员界面
- (void)getAlertControllerToVipViewWithMessage:(NSString *)message andType:(NSString *)type {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([type isEqualToString:@"购买置顶"]) {
            LLBugVipController *vc = [[LLBugVipController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            LLBuyNumberController *vc = [[LLBuyNumberController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
    [action setValue:REDColor forKey:@"titleTextColor"];
    
    [alertC addAction:action];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

//- (void)viewWillAppear:(BOOL)animated {
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:@"enterForeground" object:nil];
//
//}


//- (void)viewWillDisappear:(BOOL)animated {
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterForeground" object:nil];
//
//}

- (void)appWillEnterForegroundNotification {
    /**
     第一个参数:需要延迟执行的方法
     第二个参数:要传入的参数(id类型)
     第三个参数:延迟的时间
    */
    [self performSelector:@selector(requestIsSeeDays) withObject:nil afterDelay:0.3];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    [self navRightTwoButton];
    
    [self createButton];
    
    self.listArray = [NSMutableArray array];
    self.cityString = [NSString string];
    
    [self.view addSubview:self.tableView];
    
    [self requestIsSeeDays];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:@"enterForeground" object:nil];
    
}

- (void)navRightTwoButton {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 44)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"重置" forState:UIControlStateNormal];
    button.titleLabel.font = kFontSize(16);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(130-100, 0, 50, 44);
    [button addTarget:self action:@selector(resetSelector) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"tousu_ico"] forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(130-50, 0, 50, 44);
    [button1 addTarget:self action:@selector(choosePressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button1];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithCustsRigthItem:view style:HXBarButtonItemStylePlain];
    
}

// 下拉刷新
- (void)loadNewData {
    
    _page = 1; // 初始值第一页开始
    
    [self.listArray removeAllObjects];
    
    [self requestDataList];
    
}

// 上拉加载
- (void)loadMoreData {
    
    _page ++;
    
    [self requestDataList];
}

// 重置
- (void)resetSelector {
    
    self->_page = 1;
    [self.listArray removeAllObjects];
    
    self.cityString = @"";
    
    [self loginUserLoadList];
    
}

- (void)loginUserLoadList {
    
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

// 筛选
- (void)choosePressed {
    
    ChooseCityController *vc = [[ChooseCityController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.seleArray = [NSMutableArray arrayWithArray:@[self.cityString]];
    vc.block = ^(NSString * city) {
        
        self->_page = 1;
        [self.listArray removeAllObjects];
        
        self.cityString = city;
        
        [self loginUserLoadList];
        
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}

// 咨询师列表
- (void)requestDataList {
    
    NSDictionary *parmas = @{
        @"city":self.cityString,
        @"page":@(self->_page)
    };

    [HTTPSessionManger postDataWithNSString:@"/customer/coach" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/customer/coach: %@",dictionary);
        
        self.tableView.mj_footer.hidden = NO;
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSMutableArray *dataArray = [CSHomeModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            
            if (dataArray.count >= 10) {
                [self.listArray addObjectsFromArray:dataArray];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            } else if (dataArray.count < 10 && dataArray.count != 0) {
                [self.listArray addObjectsFromArray:dataArray];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
        [self setRequestFiledView];
        [self.tableView reloadData];
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
}

-(void)setRequestFiledView
{
    if (self.listArray.count == 0) {
        
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
//        warnMsg.text = @"暂无数据";
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

// 是否有显示联系方式天数
- (void)requestIsSeeDays {
    
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/is_newmember" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/coach/is_newmember: %@",dictionary);
        
        if (![[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self getAlertControllerToVipViewWithMessage:@"请购买联系方式可显功能" andType:@"购买联系方式"];
            
        } else {
            // 已经显示联系方式
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
}

// 进入界面给的提示
- (void)requestTips {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/tips" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (![dictionary[@"data"][@"display"] isEqualToString:@"您的信息还未展示"] && self->_isFirst) {
                return;
            }
            
            self->_isFirst = YES;
            
            UIAlertController *aler = [UIAlertController alertControllerWithTitle:dictionary[@"data"][@"tips"] message:dictionary[@"data"][@"display"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [action setValue:REDColor forKey:@"titleTextColor"];
            
            [aler addAction:action];
            
            [self presentViewController:aler animated:YES completion:nil];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
    
}

- (void)requestUserDetailWithModel:(CSHomeModel *)mod {
    [self.view showLoading];
    
    NSDictionary *parmas = @{
        @"cid":mod.userId
    };
    
    [HTTPSessionManger postDataWithNSString:@"/customer/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        
        NSLog(@"/customer/details: %@",dictionary);
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
