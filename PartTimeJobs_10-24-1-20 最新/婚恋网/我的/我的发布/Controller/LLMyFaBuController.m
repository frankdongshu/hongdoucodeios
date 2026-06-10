//
//  LLMyFaBuController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLMyFaBuController.h"
#import "LLFaBuCell.h"
#import "LLWriteFaBuController.h"

@interface LLMyFaBuController ()<UITableViewDelegate, UITableViewDataSource, LLFaBuCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LLMyFaBuController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self requestData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"我的发布";
    
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fabu_ico"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        LLWriteFaBuController *vc = [[LLWriteFaBuController alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    
    [self.view addSubview:self.tableView];
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight -kNavigationBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 220;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        
        _tableView.tableFooterView = [[UIView alloc] init];
        
        [_tableView registerNib:[UINib nibWithNibName:@"LLFaBuCell" bundle:nil] forCellReuseIdentifier:@"LLFaBuCell"];
        
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLFaBuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLFaBuCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    
    cell.deleteBtn.tag = indexPath.row;
    
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - LLFaBuCellDelegate

- (void)removeClickWithIdx:(NSInteger)idx {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:@"确认删除?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *params = @{
            @"uid":[LoginManager defaultManager].userid,
            @"iid":[NSString stringWithFormat:@"%ld",idx]
        };

        [HLHTTPSessionManager postDataWithNSString:@"/issue/del_issue" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"=== %@",dictionary);

            if ([[NSString stringWithFormat:@"%@",dictionary[@"code"]] isEqualToString:@"200"]) {
                
                [self requestData];
                
            } else {
                [self.view showErrorWithMessage:dictionary[@"msg"]];
            }

        } failure:^(NSError * _Nonnull error) {
            [self.view showErrorWithMessage:[error localizedDescription]];
        }];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [action setValue:REDColor forKey:@"titleTextColor"];
    
    [alertC addAction:cancel];
    [alertC addAction:action];
    
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}


- (void)requestData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };

    [HLHTTPSessionManager postDataWithNSString:@"/issue/mylist" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"=== %@",dictionary);

        self.dataArray = [LLFaBuModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
        
        [self.tableView reloadData];
        
        [self setRequestFiledView];

    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
    
}

- (void)setRequestFiledView {
    
    if (self.dataArray.count == 0) {
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
        warnMsg.text = @"暂无数据";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
