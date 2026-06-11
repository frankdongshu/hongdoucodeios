//
//  LLFindJiaJiaoController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/13.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLFindJiaJiaoController.h"
#import "LLFindJiaJiaoCell.h"
#import "LLFindJiaJiaoDetailViewController.h"

@interface LLFindJiaJiaoController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LLFindJiaJiaoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTableView];
    
    self.dataArray = [NSMutableArray new];
    
    [self loadNewData];
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"LLFindJiaJiaoCell" bundle:nil] forCellReuseIdentifier:@"LLFindJiaJiaoCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLFindJiaJiaoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLFindJiaJiaoCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    LLFaBuModel * model = self.dataArray[indexPath.row];
    [self requestUserDetailWithModel:model];
    
}
- (void)requestUserDetailWithModel:(LLFaBuModel *)mod {
    [self.view showLoading];

    NSDictionary *parmas = @{
        @"cid": [NSString stringWithFormat:@"%ld",(long)mod.iid],
        @"uid": [LoginManager defaultManager].userid
    };
//http://www.jiajiao211.net/index.php/api/mind/details?uid={用户id}&token={用户token}&cid={老师id}
    [HLHTTPSessionManager getDataWithNSString:@"/mind/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"=== %@",dictionary);
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            LLFindJiaJiaoDetailViewController *vc = [[LLFindJiaJiaoDetailViewController alloc] init];
            vc.model = [CSCoachDetailModel mj_objectWithKeyValues:dictionary[@"data"]];
            vc.isApp = XinLiApp;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        [self setRequestFiledView];
        } failure:^(NSError * _Nonnull error) {
            [self.view showErrorWithMessage:[error localizedDescription]];
            [self.tableView.mj_header endRefreshing];
        }];
    
    
    
//    [HTTPSessionManger postDataWithNSString:@"/customer/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
//
//        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
//            [self.view hideLoading];
//
//            CSCoachDetailViewController *vc = [[CSCoachDetailViewController alloc] init];
//            vc.model = [CSCoachDetailModel mj_objectWithKeyValues:dictionary[@"data"]];
//            vc.isApp = XinLiApp;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//
//        } else {
//            [self.view showTostWithMessage:dictionary[@"msg"]];
//        }
//
//
//    } failure:^(NSError * _Nonnull error) {
//        [self.view showTostWithMessage:[error localizedDescription]];
//    }];


}
- (void)loadNewData {
    
    if (!self.isLogin) {
        [self.dataArray removeAllObjects];
        [self setRequestFiledView];
        
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };

//http://www.jiajiao211.net/index.php/api/mind/coach?uid={用户id}&token={用户token}
    [HLHTTPSessionManager getDataWithNSString:@"/mind/coach" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"=== %@",dictionary);

        self.dataArray = [LLFaBuModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
        [self setRequestFiledView];
        } failure:^(NSError * _Nonnull error) {
            [self.view showErrorWithMessage:[error localizedDescription]];
            [self.tableView.mj_header endRefreshing];
        }];
    
//    [HLHTTPSessionManager postDataWithNSString:@"/issue/issuelist" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
//
//        NSLog(@"=== %@",dictionary);
//
//        self.dataArray = [LLFaBuModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
//
//        [self.tableView reloadData];
//
//        [self.tableView.mj_header endRefreshing];
//
//        [self setRequestFiledView];
//
//
//    } failure:^(NSError * _Nonnull error) {
//        [self.view showErrorWithMessage:[error localizedDescription]];
//        [self.tableView.mj_header endRefreshing];
//    }];
    
    
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
