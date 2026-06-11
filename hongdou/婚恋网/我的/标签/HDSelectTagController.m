//
//  HDSelectTagController.m
//  hongdou
//
//  Created by 维康1 on 2020/6/15.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HDSelectTagController.h"
#import "HDAddTagController.h"

@interface HDSelectTagController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *selectArray;

@end

@implementation HDSelectTagController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sc_navigationBar.title = @"标签";
    
    self.selectArray = [NSMutableArray arrayWithArray:self.tagArray];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:kHYLColor(255, 92, 121, 1) style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        [self updateTagLabelWithTagArray:self.selectArray];
        
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:self.tableView];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getListWithType:self.typeString];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kHYLColor(251, 251, 253, 1);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-50, 50)];
    lab.text = @"创建我自己的标签";
    lab.textColor = kHYLColor(91, 118, 255, 1);
    lab.font = [UIFont systemFontOfSize:13];
    
    [view addSubview:lab];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    imgView.frame = CGRectMake(kScreenWidth-35, 0, 35, 50);
    imgView.contentMode = UIViewContentModeCenter;
    
    [view addSubview:imgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, kScreenWidth, 50);
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btn];
    
    return view;
}

// 添加视图跳转
- (void)btnClick {
    HDAddTagController *vc = [[HDAddTagController alloc] init];
    vc.typeString = self.typeString;
    vc.selectArray = self.selectArray;
    vc.tagArray = self.tagArray;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    }
    cell.selectionStyle = 0;
    cell.textLabel.text = self.dataArray[indexPath.row][@"label"];
    
    if ([self.selectArray containsObject:cell.textLabel.text]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhengque"]];
    } else {
        cell.accessoryView = nil;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (![self.selectArray containsObject:self.dataArray[indexPath.row][@"label"]]) { // 没有, 添加
        
        [self.selectArray addObject:self.dataArray[indexPath.row][@"label"]];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhengque"]];
        
    } else { // 有, 删除
        
        [self.selectArray removeObject:self.dataArray[indexPath.row][@"label"]];
        
        cell.accessoryView = nil;
        
    }
    
}

// 获取获取类别内标签
- (void)getListWithType:(NSString *)type {
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":type
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/user/precut_label" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            self.dataArray = dictionary[@"data"];
            
            [weakSelf.tableView reloadData];
            
        }else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

// 修改标签
- (void)updateTagLabelWithTagArray:(NSMutableArray *)arr {
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":self.typeString,
        @"label":arr
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/user/addAllLabel" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.tagArray removeAllObjects];
            
            [self.tagArray addObjectsFromArray:self.selectArray];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
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
