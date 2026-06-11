//
//  LLBlackTeatherController.m
//  hongdou
//
//  Created by 李龙 on 2020/4/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLBlackTeatherController.h"
#import "LLTeatherModel.h"
#import "LLTeacherCell.h"

@interface LLBlackTeatherController ()
@property (nonatomic, strong)NSMutableArray *dataSource;
@end

@implementation LLBlackTeatherController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.dataSource = [[NSMutableArray alloc] init];
    [self loadNewData];
    [self initTableView];
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight);
    self.tableView.estimatedRowHeight = 220;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView registerClass:[LLTeacherCell class] forCellReuseIdentifier:@"LLTeacherCell"];
    
    self.tableView.mj_footer.hidden = YES;
}

- (void)loadNewData{
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HTTPSessionManger postDataWithNSString:@"/customer/getblacklist" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~ %@",dictionary);
        
        if ([[NSString stringWithFormat:@"%@",dictionary[@"code"]] isEqualToString:@"200"]) {
            self.dataSource = [LLTeatherModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
        } else {
            // 没数据
//            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        [self setRequestFiledView];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
        [self setRequestFiledView];
        [self.tableView.mj_header endRefreshing];
        
    }];
    
}

-(void)setRequestFiledView
{
    if (self.dataSource.count == 0) {
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
        warnMsg.text = @"下拉可以刷新哦~";
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

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LLTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLTeacherCell"];
    cell.type = BlackPushType;
    cell.infoModel = self.dataSource[indexPath.row];
    cell.row = indexPath.row;
    cell.connectBlock = ^(NSInteger row, BOOL isConnected) {
        [self showCancelFollowAlertWithRow:row];
    };
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)showCancelFollowAlertWithRow:(NSInteger)row {
    
    UIAlertController *alerC = [UIAlertController alertControllerWithTitle:@"确认取消拉黑?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self requestCancelBlackWithRow:row];
    }];
    
    [alerC addAction:cancel];
    [alerC addAction:sure];
    
    [self presentViewController:alerC animated:YES completion:nil];
}

- (void)requestCancelBlackWithRow:(NSInteger)row {

    LLTeatherModel *mod = self.dataSource[row];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
//        @"muid":mod.muid
        @"mobile":[NSString stringWithFormat:@"mind_%@",mod.jg_user]
    };
    
    [HTTPSessionManger postDataWithNSString:@"/customer/delblacklist" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[NSString stringWithFormat:@"%@",dictionary[@"code"]] isEqualToString:@"200"]) {
            
            [self.dataSource removeAllObjects];
            [self loadNewData];
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];

}

#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}



- (UIScrollView *)listScrollView {
    return self.tableView;
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
