//
//  ChooseCityController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "ChooseCityController.h"
#import "CSHomeTableViewCell.h"
#import "CSCityDetailModel.h"

@interface ChooseCityController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//@property (nonatomic, strong) NSMutableArray *seleArray;

@property (nonatomic, strong) UIView *noDataView;

@end

@implementation ChooseCityController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.sc_navigationBar.title = @"筛选城市";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
        
        self.block([self.seleArray firstObject]);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    self.dataArray = [NSMutableArray array];
//    self.seleArray = [NSMutableArray array];
    
    
    [self requestData];
}

#pragma mark - UI
- (void)addViews {
    [self.view addSubview:self.tableView];
}


-(void)layoutViews{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.bottom.equalTo(self.view);
    }];
}

-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[CSHomeTableViewCell class] forCellReuseIdentifier:@"CSHomeTableViewCell"];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-  (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height ;
    
    NSInteger rowww = self.dataArray.count / 3;
    
    if (self.dataArray.count % 3 == 0) {
        height = rowww *30 + (rowww - 1)*20;
    } else {
        height = (rowww + 1) *30 + (rowww)*20;

    }
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSHomeTableViewCell" forIndexPath:indexPath];
    cell.cellType = ChosseCity;
    cell.dataMuArray = self.dataArray;
    cell.seleArray = self.seleArray;
    cell.selectionStyle = 0;
//    if (indexPath.section == 0) {
//        cell.dataMuArray = self.cityModel.major.lists;
//    }else{
//        cell.dataMuArray = (self.cityModel.all[indexPath.section - 1]).lists;
//    }
    
    WeakSelf(ws);
    cell.seleBlock = ^(NSInteger cuid,NSString *title) {
        
        if ([ws.seleArray containsObject:title]) {
            
        } else {
            [ws.seleArray removeAllObjects];
            [ws.seleArray addObject:title];
        }
        [self.tableView reloadData];
    };

    return cell;
}


- (void)requestData {
    
    NSDictionary *parmas = @{};

    [HTTPSessionManger postDataWithNSString:@"/customer/city" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~ %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.dataArray = [CSCityChooseModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            if (self.dataArray.count > 0) {
                [self addViews];
                [self layoutViews];
            } else {
                [self.view addSubview:self.noDataView];
            }
            
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
    
}

- (UIView *)noDataView {
    if (_noDataView == nil) {
        _noDataView = [[UIView alloc] initWithFrame:self.tableView.frame];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2-10, kScreenWidth, 20)];
        titleLab.text = @"暂无数据";
        titleLab.textColor = HEXColor(@"666666");
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:titleLab];
        
    }
    return _noDataView;
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
