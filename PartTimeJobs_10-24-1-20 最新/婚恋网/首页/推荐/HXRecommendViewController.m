//
//  HXRecommendViewController.m
//  婚恋网
//
//  Created by iMac on 2019/9/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HXRecommendViewController.h"
#import "HLHometableViewCell.h"
#import "HLFrienderDetailViewController.h"
//#import "JCHATConversationViewController.h"
#import "HLNewChatViewController.h"
#import "HDPreviewPhotoController.h"


@interface HXRecommendViewController ()<HLHomeDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;


@end

@implementation HXRecommendViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)removePersonClick:(NSNotification *)notifi {
    
//    NSString *mobile = notifi.object;
    
    [self loadNewData];
    
}

#pragma mark - 创建悬浮的按钮

- (void)createButton{

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setTitle:@"换一批" forState:UIControlStateNormal];
    
    [button setImage:[[UIImage imageNamed:@"tuijian_shua"] imageWithColor:kRGBA(255, 125, 149, 1)] forState:UIControlStateNormal];
    [button setTitleColor:kRGBA(255, 125, 149, 1) forState:UIControlStateNormal];
    button.frame = CGRectMake(kScreenWidth-85, 50, 80, 30);

    button.titleLabel.font = [UIFont systemFontOfSize:13];

    [button addTarget:self action:@selector(resignButton) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button];

}

// 换一批
- (void)resignButton {
    
    if (!self.isLogin) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLUpdate_friends withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            // 更新成功, 调用推荐列表
            [self requestRecommend];
            
        } else {
            
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"请求失败"];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.dataSource = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadNewData) name:DismissLoginView object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removePersonClick:) name:@"RemovePerson" object:nil];
    
    [self initTableView];
    [self loadNewData];
    [self createButton];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"HLHometableViewCell" bundle:nil] forCellReuseIdentifier:@"HLHometableViewCell"];
    
}


- (void)loadNewData{
    
    if (!self.isLogin) {
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
    }
    
    [self requestRecommend];
    
}


- (void)requestRecommend {
    
    // 游客登录
    NSDictionary *params = @{
        @"visitor":@"yes"
    };
    
    
    if (self.isLogin) {
        
        params = @{
            @"uid":[LoginManager defaultManager].userid
        };
        
    }
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLTuijian_friends withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.dataSource = [HLUser mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
        } else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:[error localizedDescription]];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLHometableViewCell *cell = (HLHometableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLHometableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (self.dataSource.count > 0) {
        cell.model = self.dataSource[indexPath.row];
    }
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.weakSelf = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.userInfo = self.dataSource[indexPath.row];
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


#pragma mark - JXCategoryListContentViewDelegate

- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.tableView;
}

#pragma mark HLHomeDelegate

//-(void)followButtonClick{
//    // 点完红心刷新数据, 导致数据跳动
//    [self loadNewData];
//}

// 不感兴趣
- (void)closeButtonClick:(NSIndexPath *)indexPath {
    [self.dataSource removeObject:self.dataSource[indexPath.row]];
    
    [self.tableView reloadData];
}

- (void)chartButtonClick:(NSIndexPath *)indexPath{
//    [self.view showTostWithMessage:@"开发中。。。"];
    [HLHTTPSessionManager postDataWithNSString:HLUser_ExamineType withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            if ([[[dictionary[@"data"] objectForKey:@"type"] stringValue] isEqualToString:@"1"]) {
                //
                HLUser *model = self.dataSource[indexPath.row];
                [JMSGConversation createSingleConversationWithUsername:model.username appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
                    if (error == nil) {
                        
                        JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
                        conversation = resultObject;
                        HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
                        sendMessageCtl.hidesBottomBarWhenPushed = YES;
//                        sendMessageCtl.superViewController = self;
                        sendMessageCtl.conversation = conversation;
                        HLUser *model  = self.dataSource[indexPath.row];
                        sendMessageCtl.userName = model.username;
                        [self.navigationController pushViewController:sendMessageCtl animated:YES];
                    }else{
                        [self.view showTostWithMessage:@"创建会话失败"];
                        return;
                    }
                }];
               
            }else{
                [self.view showTostWithMessage:@"用户资料待审核"];
            }
        }else{
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"操作失败，请重试！"];
    }];
}

// 预览照片
- (void)browerPhotoClick:(NSArray *)picArrs withCurrentIndex:(NSInteger)index{
    
    HDPreviewPhotoController *previewVC = [[HDPreviewPhotoController alloc] init];
    previewVC.hidesBottomBarWhenPushed = YES;
    previewVC.picArray = picArrs;
    previewVC.selectIdx = index;
    [self.navigationController pushViewController:previewVC animated:YES];
    
    
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
