//
//  HLNOFollowViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNOFollowViewController.h"
#import "HLPrivacyManageTableViewCell.h"

@interface HLNOFollowViewController ()<HLPrivacyManageDeleagte>
{
    UIAlertView * alert;
    NSIndexPath * currentIndex;
    
}
@property (nonatomic, strong)NSMutableArray *dataSource;


@end

@implementation HLNOFollowViewController

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
    [self.tableView registerNib:[UINib nibWithNibName:@"HLPrivacyManageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPrivacyManageTableViewCell"];
    
    self.tableView.mj_footer.hidden = YES;
}

- (void)loadNewData{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLPrivacy_Shield withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.dataSource = [HLFriendUserModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];

        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];
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
    cell.delegate = self;
    return cell;
}

- (void)deleteButtonClickIndexPath:(NSIndexPath *)indexPath{
    
    currentIndex = indexPath;
    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定移除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 110;
    [alert show];


}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 110){
            
            WeakSelf(weakSelf);
            HLFriendUserModel *model = self.dataSource[currentIndex.row];
            [self.view showLoading];
            [HLHTTPSessionManager postDataWithNSString:HLDelegatePrivacy_Shield withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"sid":model.userid} success:^(NSDictionary * _Nonnull dictionary) {
                [self.view hideLoading];
                NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
                if ([code isEqualToString:@"200"] ) {
                    
                    [self loadNewData];
                }else {
                    [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
                }
            } failure:^(NSError * _Nonnull error) {
                [weakSelf.view showTostWithMessage:@"移除失败，请重新点击移除按钮"];
            }];
        }
    }
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
