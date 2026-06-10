//
//  HXChooseController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/4/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXChooseController.h"
#import "CSHomeTableViewCell.h"
#import "HXChooseModel.h"

@interface HXChooseController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
//@property (nonatomic, strong) NSMutableArray *seleArray;

@property (nonatomic, strong) UIView *noDataView;

@end

@implementation HXChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    
    self.sc_navigationBar.title = @"筛选课程";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
//    [self setSc_NavigationBarAnimateInvalid:YES];
    
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
//    self.seleArray = [NSMutableArray arrayWithArray:[MyLogin getCurrentLoginUser].curriculum];
    
    NSLog(@"seleArray: %@",self.seleArray);
    
    [self addViews];
    [self layoutViews];
    [self getData];
}

#pragma mark - UI
-(void)addViews{
    [self.view addSubview:self.tableView];
}

-(void)layoutViews{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[CSHomeTableViewCell class] forCellReuseIdentifier:@"CSHomeTableViewCell"];
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(10, 16, 8, 8)];
    redView.layer.cornerRadius = 4;
    redView.layer.masksToBounds = YES;
    redView.backgroundColor = REDColor;
    [view addSubview:redView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(redView.frame)+10, 0, 150, 40)];
    titleLab.text = ((HXChooseModel*)self.dataArray[section]).type;
    titleLab.font = kFontSize(17);
    [view addSubview:titleLab];
    
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height ;
    NSInteger rowww = ((HXChooseModel*)self.dataArray[indexPath.section]).data.count / 3;
    if (((HXChooseModel*)self.dataArray[indexPath.section]).data.count % 3 == 0) {
        height = rowww *30 + (rowww - 1)*20;
    }else{
        height = (rowww + 1) *30 + (rowww)*20;

    }
    return  height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSHomeTableViewCell" forIndexPath:indexPath];
    cell.cellType = ChosseKeCheng;
    cell.seleArray = self.seleArray;
    cell.dataMuArray = ((HXChooseModel*)self.dataArray[indexPath.section]).data;
    cell.selectionStyle = 0;
    
    cell.seleBlock = ^(NSInteger cuid, NSString * title) {
        
        if ([self.seleArray containsObject:@(cuid)]) {
            
        }else{
            [self.seleArray removeAllObjects];
            [self.seleArray addObject:@(cuid)];
        }
        [self.tableView reloadData];
        
    };
    
    
    return cell;
}

#pragma mark - data
- (void)getData {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };

    [HTTPSessionManger postDataWithNSString:@"/customer/curriculum" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.dataArray = [HXChooseModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            if (self.dataArray.count > 0) {
                [self.tableView reloadData];
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
