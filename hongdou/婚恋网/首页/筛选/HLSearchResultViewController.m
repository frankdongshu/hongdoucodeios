//
//  HLSearchResultViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/30.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSearchResultViewController.h"
#import "HLResultTableViewCell.h"
#import "HLFrienderDetailViewController.h"
#import "JCHATConversationViewController.h"
#import "HLNewChatViewController.h"

@interface HLSearchResultViewController ()<HLResultDelegate>{
    NSInteger currentPage;
}

@end

@implementation HLSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"筛选";
    self.dataSource = [NSMutableArray array];
    [self initTableView];
//    [self loadNewData];
}
//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight -kNavigationBarHeight);
    self.tableView.estimatedRowHeight = 200.f;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLResultTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLResultTableViewCell"];
    
    [self.tableView.mj_header beginRefreshing];
    
//    self.tableView.mj_footer.hidden = NO;
}

- (void)loadMoreData {
    
    currentPage ++;
    [self requestSearchResultWithPege:currentPage];
    
}


- (void)loadNewData{
    
    currentPage = 1;
    [self.dataSource removeAllObjects];
    [self requestSearchResultWithPege:currentPage];
    
}

- (void)requestSearchResultWithPege:(NSInteger)page {
    
    WeakSelf(weakSelf);
    
    [self.requestDic setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    [HLHTTPSessionManager postDataWithNSString:HLUser_Screen withDictionary:self.requestDic success:^(NSDictionary * _Nonnull dictionary) {
        
        self.tableView.mj_footer.hidden = NO;
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            NSMutableArray *dataArray = [HLUser mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (dataArray.count >= 10) {
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshing];
            } else if (dataArray.count < 10 && dataArray.count != 0) {
                [weakSelf.dataSource addObjectsFromArray:dataArray];
                [weakSelf.tableView.mj_header endRefreshing];
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
        [self setRequestFiledView];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
}

- (void)setRequestFiledView {
    
    if (self.dataSource.count == 0) {
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
//        warnMsg.text = @"下拉可以刷新哦~";
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
    HLResultTableViewCell *cell = (HLResultTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLResultTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.model = self.dataSource[indexPath.row];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.weakSelf = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
//    detailVC.userInfo = self.dataSource[indexPath.row];
    HLUser *model = self.dataSource[indexPath.row];
    detailVC.userId = model.userid;
    detailVC.refreshBlock  = ^{
        HLUser *model = self.dataSource[indexPath.row];
        model.in_follow = YES;
        model.fans = [NSString stringWithFormat:@"%d",[model.fans intValue]+1];
        [self.tableView reloadData];
    };
    detailVC.removeBlock = ^{
        
        [self.dataSource removeObject:self.dataSource[indexPath.row]];
        
        [self.tableView reloadData];
        
    };
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark HLHomeDelegate
-(void)followButtonClick{
    [self loadNewData];
}
- (void)dropdownButtonClick{
    
}
- (void)chartButtonClick:(NSIndexPath *)indexPath{
    //    [self.view showTostWithMessage:@"开发中。。。"];
    [HLHTTPSessionManager postDataWithNSString:HLUser_ExamineType withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            if ([[[dictionary[@"data"] objectForKey:@"type"] stringValue] isEqualToString:@"1"]) {
                
                HLUser *model = self.dataSource[indexPath.row];
                                
                HLChatController *vc = [[HLChatController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.chatDic = @{
                    @"cid":model.userid,
                    @"cname":model.nickname,
                    @"cmobile":model.username,
                    @"chead":model.head
                };
                
                [self.navigationController pushViewController:vc animated:YES];
                
                
                
            }else{
                [self.view showTostWithMessage:@"您的个人资料审核未通过，请修改个人资料后继续使用"];
            }
        }else{
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"操作失败，请重试！"];
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
