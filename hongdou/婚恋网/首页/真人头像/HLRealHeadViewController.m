//
//  HLRealHeadViewController.m
//  hongdou
//
//  Created by 维康1 on 2021/8/25.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLRealHeadViewController.h"
#import "HLHometableViewCell.h"
#import "HLFrienderDetailViewController.h"
#import "HDPreviewPhotoController.h"
#import "HLRealHeadSelectView.h"

#import "HLRealHeadCell.h"

#import <RPSDK/RPSDK.h>
#import "HDPreviewPhotoController.h"

@interface HLRealHeadViewController ()<HLRealHeadCellDelegate> {
    int _page; // 分页
    
    // 设置按钮, 记录是否点击只看同城
    int _isSwitch;
}

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *settingBtn;

@end

@implementation HLRealHeadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray array];
    
    [self initTableView];
    [self.tableView.mj_header beginRefreshing];
    
    
    // 防止设置按钮, 超出页面
    self.view.clipsToBounds = YES;
    
    self.settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.settingBtn setTitle:@"筛选   " forState:UIControlStateNormal];
    [self.settingBtn setImage:[UIImage imageNamed:@"vvip_setting"] forState:UIControlStateNormal];
    
    [self.settingBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    
    self.settingBtn.titleLabel.font = [UIFont fontWithName:@"Medium" size:14];
    [self.settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.settingBtn.backgroundColor = kRGBA(0, 0, 0, .5);
    self.settingBtn.layer.cornerRadius = 18;
    [self.settingBtn addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.settingBtn];
    
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(18);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(36);
        make.centerY.equalTo(self.view.mas_centerY).offset(115);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginUserLoadList) name:DismissLoginView object:nil];
}

// 设置按钮触发
- (void)settingClick {
    
    [self.view showLoadMessageAtCenter];
    
    // 是否人脸认证
    [HLHTTPSessionManager postDataWithNSString:@"/user/certification" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"certification: %@",dictionary);
        
        [self.view hide];
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (![[dictionary[@"data"][@"VerifyStatus"] stringValue] isEqualToString:@"1"]) { // 未认证
                
                [self getAlertControllerToVipViewWithMessage];
                
            } else { // 已认证
                
                [self requestSwichStatus];
                
            }
            
        } else if ([[dictionary[@"code"] stringValue] isEqualToString:@"202"]) {
            // code 202 尚未认证
            [self getAlertControllerToVipViewWithMessage];
            
        } else {
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showError:@"判断人脸是否认证失败"];
        
    }];
    
}

// 弹出提示并前往开通会员界面
- (void)getAlertControllerToVipViewWithMessage {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未进行人脸认证,请认证后进行设置" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self authFace];
    }];
    
    [action setValue:REDColor forKey:@"titleTextColor"];
    
    [alertC addAction:cancel];
    [alertC addAction:action];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

// 去人脸认证
- (void)authFace {
    
    [self.view showLoadMessageAtCenter];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":[LoginManager defaultManager].avatar
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/getAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"getAlibabaToken: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.view hide];
            
            [RPSDK startWithVerifyToken:dictionary[@"data"][@"VerifyToken"]
                         viewController:self
                             completion:^(RPResult * _Nonnull result) {
                // 建议接入方调用实人认证服务端接口 DescribeVerifyResult，
                // 来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                NSLog(@"真人头像认证结果：%@", result);
                switch (result.state) {
                    case RPStatePass:
                        // 认证通过。
                        NSLog(@"真人头像认证成功");
                        break;
                    case RPStateFail:
                        // 认证不通过。
                        break;
                    case RPStateNotVerify:
                        // 未认证。
                        // 通常是用户主动退出或者姓名身份证号实名校验不匹配等原因导致。
                        // 具体原因可通过 result.errorCode 和 result.message 来区分（详见错误码说明）。
                        break;
                }
            }];
            
        } else {
            [self.view showError:@"获取Token失败"];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
    }];
    
}


// 获取设置开启状态
- (void)requestSwichStatus {
    
    [self.view showLoadMessageAtCenter];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/set" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/set: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.view hide];
            
            HLRealHeadSelectView *view = [[HLRealHeadSelectView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            
            view.params = params;
            view.isSwichOn = self->_isSwitch;
            
            view.SelectBlock = ^(BOOL isSelect) { // 设置是否只看同城
                
                self->_isSwitch = isSelect;
                
                self->_page = 1; // 初始值第一页开始
                [self.dataSource removeAllObjects];
                
                [self loginUserLoadList];
                
            };
            
            
            [view showSelf];
            
            
        } else {
            [self.view showError:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:@"获取开启状态失败"];
    }];
    
}


- (void)loginUserLoadList {
    
    // 回到顶部
    [self.tableView reloadData];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    self.tableView.mj_footer.hidden = YES;
    
    // 请求数据
    [self.tableView.mj_header beginRefreshing];
    
}

//创建tabbleview视图
- (void)initTableView {
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vvip_black_bg"]];
    imgView.frame = self.view.frame;
    
    [self.view addSubview:imgView];
    
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(20, 0, kScreenWidth-40, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLRealHeadCell" bundle:nil] forCellReuseIdentifier:@"HLRealHeadCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    header.stateLabel.textColor = [UIColor whiteColor];
    header.loadingView.color = [UIColor whiteColor];
    
    // 设置header
    self.tableView.mj_header = header;
    
    
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    footer.refreshingTitleHidden = YES;
    
    footer.stateLabel.textColor = [UIColor whiteColor];
    footer.loadingView.color = [UIColor whiteColor];
    
    self.tableView.mj_footer = footer;
    
    self.tableView.mj_footer.hidden = YES;
    
}

- (void)loadNewData{
    
    if (!self.isLogin) {
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        
        self->_isSwitch = 0;
    }
    
    // 不登录不显示
    self.settingBtn.hidden = !self.isLogin;
    
    _page = 1; // 初始值第一页开始
    [self.dataSource removeAllObjects];
    [self requestData];
    
}

- (void)loadMoreData {
    
    _page ++;
    
    [self requestData];
}

// 请求数据
- (void)requestData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"page":@(_page),
        @"tc":@(self->_isSwitch)
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/ulist/get_hce" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/ulist/get_hce: %@",dictionary);
        
        self.tableView.mj_footer.hidden = NO;
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.view hide];
            
            NSMutableArray *dataArray = [HLUser mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
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
            [self.view showError:dictionary[@"msg"]];
        }
        
        [self setRequestFiledView];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
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
//        warnMsg.text = @"暂无数据";
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLRealHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLRealHeadCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    cell.u = self.dataSource[indexPath.section];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 未登录
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.userInfo = self.dataSource[indexPath.section];
    HLUser *model = self.dataSource[indexPath.section];
    detailVC.userId = model.userid;
    detailVC.refreshBlock  = ^{
        HLUser *model = self.dataSource[indexPath.section];
        model.in_follow = YES;
        model.fans = [NSString stringWithFormat:@"%d",[model.fans intValue]+1];
        [self.tableView reloadData];
    };
    detailVC.removeBlock = ^{
        
        [self.dataSource removeObject:self.dataSource[indexPath.section]];
        
        [self.tableView reloadData];
        
    };
    
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - HLRealHeadCellDelegate

// 分享
- (void)shareVipClickWithPicArr:(NSArray *)picArray {
    
    HDPreviewPhotoController *previewVC = [[HDPreviewPhotoController alloc] init];
    previewVC.hidesBottomBarWhenPushed = YES;
    previewVC.picArray = picArray;
    previewVC.selectIdx = 0;
    [self.navigationController pushViewController:previewVC animated:YES];
    
}

// 聊天
- (void)chatVipClickWithUserName:(HLUser *)user {
    
    HLChatController *vc = [[HLChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.chatDic = @{
        @"cid":user.userid,
        @"cname":user.nickname,
        @"cmobile":user.username,
        @"chead":user.head
    };
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)followVipClickWithFollowBtn:(UIButton *)sender andUser:(HLUser *)u {
    
    if (sender.selected) {
        [self requestCollectionUrl:HLCancelFollow_Shields andUser:u followBtn:sender];
    }else{
        [self requestCollectionUrl:HLGoFollow_Shields andUser:u followBtn:sender];
    }
    
}

// 请求关注/取消关注接口
- (void)requestCollectionUrl:(NSString *)url andUser:(HLUser *)u followBtn:(UIButton *)btn {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *parmas = @{
        @"uid":kISNullString([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid,
        @"fid":u.userid
    };
    
    
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [MBProgressHUD hideLoading];
            
            btn.selected = !btn.selected;
            
            u.in_follow = btn.selected;
            
            
            [btn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
            
        } else {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
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
