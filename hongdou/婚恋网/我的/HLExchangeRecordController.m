//
//  HLExchangeRecordController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLExchangeRecordController.h"
#import "HLRecordModel.h"
#import "HLRecordCell.h"

@interface HLExchangeRecordController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation HLExchangeRecordController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0 , kNavBarHeight , kScreenWidth, kScreenHeight-kNavBarHeight)];
        _tableView.delegate =self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kRGBA(245, 245, 249, 1);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLRecordCell"];
    if (!cell) {
        cell = [[HLRecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HLRecordCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"兑换记录";
    
    [self.view addSubview:self.tableView];
    
    [self requsetRecordList];
}

// 请求可兑换产品列表
- (void)requsetRecordList {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLRecord_List withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"==== %@ ====",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"]) {
            weakSelf.dataArray = [HLRecordModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
        }
        else if ([code isEqualToString:@"202"]) { // 暂无数据
            
            [self setRequestFiledViewWithMessage:[dictionary objectForKey:@"msg"]];
        }
        else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)setRequestFiledViewWithMessage:(NSString *)message {
    
    //设置空白界面
    UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
    logoImg.image = [UIImage imageNamed:@"ic_no_events"];
    [blankBg addSubview:logoImg];
    UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
    warnMsg.numberOfLines = 2;
    warnMsg.text = message;
    warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
    warnMsg.font = [UIFont systemFontOfSize:16];
    warnMsg.textAlignment = NSTextAlignmentCenter;
    [blankBg addSubview:warnMsg];
    [self.tableView setTableHeaderView:blankBg];
    
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
