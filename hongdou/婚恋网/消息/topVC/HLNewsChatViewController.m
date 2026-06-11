//
//  HLNewsChatViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/24.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNewsChatViewController.h"
#import "HLPrivacyManageTableViewCell.h"
#import "HLFrienderDetailViewController.h"

@interface HLNewsChatViewController ()

@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)UILabel *topLabel;


@end

@implementation HLNewsChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"畅聊";
    [self initTableView];
    [self.tableView.mj_header beginRefreshing];
}
//创建tabbleview视图
-(void)initTableView
{
    
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, 40)];
    self.topLabel.text = [NSString stringWithFormat:@"您总共开通畅聊 %d 人，继续加油！",self.dataSource.count];
    self.topLabel.backgroundColor = [UIColor  colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0];
    self.topLabel.textColor = [UIColor colorWithHex:0x6175F6];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.topLabel];
    
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, kNavigationBarHeight + 40, kScreenWidth, kScreenHeight -kNavigationBarHeight - 40);
    self.tableView.estimatedRowHeight = 220;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLPrivacyManageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPrivacyManageTableViewCell"];
    
    self.tableView.mj_footer.hidden = YES;
}

- (void)loadNewData{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLFriends_Chatting withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.dataSource = [HLFriendUserModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
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
    self.topLabel.text = [NSString stringWithFormat:@"您总共开通畅聊 %d 人，继续加油！",self.dataSource.count];
    if (self.dataSource.count == 0) {
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
    detailVC.refreshBlock  = ^{
        [self loadNewData];
    };
    [self.navigationController pushViewController:detailVC animated:YES];
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
