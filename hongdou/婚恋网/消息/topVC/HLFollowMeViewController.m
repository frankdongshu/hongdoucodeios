//
//  HLFollowMeViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/24.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFollowMeViewController.h"
#import "HLPrivacyManageTableViewCell.h"
#import "HLFrienderDetailViewController.h"
#import "HLNotVipView.h"
#import "HLOpenMemberViewController.h"

@interface HLFollowMeViewController ()

@property (nonatomic, strong)NSMutableArray *dataSource;

@property (nonatomic, strong)HLNotVipView *notView;

@end

@implementation HLFollowMeViewController

- (HLNotVipView *)notView {
    if (!_notView) {
        _notView = [[HLNotVipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andDataArray:self.dataSource andTitle:@"关注我"];
        
        self.notView.SelectBlock = ^(HLNotVipView *view) {
            HLGoVipViewController *vc = [[HLGoVipViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        
    }
    return _notView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.dataSource = [[NSMutableArray alloc] init];
    [self.tableView.mj_header beginRefreshing];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"HLPrivacyManageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPrivacyManageTableViewCell"];
    
    self.tableView.mj_footer.hidden = YES;
}

- (void)loadNewData{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLFollow_Shields withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.dataSource = [HLFriendUserModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            if (weakSelf.dataSource.count > 0 && ![LoginManager defaultManager].isVip) {
                [self.tableView addSubview:self.notView];
            }
            
        }else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
        [self setRequestFiledView];
        [weakSelf.tableView.mj_header endRefreshing];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLPrivacyManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLPrivacyManageTableViewCell"];
    cell.friendModel = self.dataSource[indexPath.row];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.currentIndex = indexPath;
    cell.deleteBtn.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    HLFriendUserModel *model = self.dataSource[indexPath.row];
    detailVC.userId = model.userid;
    detailVC.detailType = DianZanType;
    detailVC.refreshBlock  = ^{
        [self loadNewData];
    };
    detailVC.removeBlock = ^{
        
    };
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
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
