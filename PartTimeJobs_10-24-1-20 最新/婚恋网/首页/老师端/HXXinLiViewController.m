//
//  HXXinLiViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/16.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HXXinLiViewController.h"
#import "HDHomeCell.h"
#import "CSHomeModel.h"
#import "HXChooseController.h" // 课程筛选
#import "CSCoachDetailViewController.h" // 详情
#import "HLNewChatViewController.h" // 聊天界面

@interface HXXinLiViewController ()<CSHomeDelegate>

@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *cidString;
@property (nonatomic, strong) UIView *noDataView;

@end

@implementation HXXinLiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTableView];
    
    self.listArray = [NSMutableArray array];
    self.cidString = [NSString string];
    
    [self requestDataWithCid:self.cidString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:@"RELOAD_XIN" object:nil];
    
}

- (void)loadNewData {
    [self requestDataWithCid:self.cidString];
}

//创建tabbleview视图
-(void)initTableView
{
    self.tableViewInsertTop = 0;
    self.tableView.contentInsetTop = 0;
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight -kNavigationBarHeight-kTabBarHeight);
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    //设置预估行高
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HDHomeCell" bundle:nil] forCellReuseIdentifier:@"HDHomeCell"];
    
}

- (UIView *)noDataView {
    if (_noDataView == nil) {
        _noDataView = [[UIView alloc] initWithFrame:self.tableView.frame];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, kScreenWidth, 20)];
        titleLab.text = @"暂无数据";
        titleLab.textColor = HEXColor(@"666666");
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:titleLab];
        
    }
    return _noDataView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"重置" forState:UIControlStateNormal];
    button.titleLabel.font = kFontSize(16);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(kScreenWidth-100, 0, 50, 44);
    [button addTarget:self action:@selector(resetSelector) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"tousu_ico"] forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(kScreenWidth-50, 0, 50, 44);
    [button1 addTarget:self action:@selector(choosePressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button1];
    
    
    return view;
}

// 重置
- (void)resetSelector {
    
    self.cidString = @"";
    
    [self requestDataWithCid:@""];
    
}
// 筛选
- (void)choosePressed {
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    HXChooseController *vc = [[HXChooseController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.seleArray = [NSMutableArray arrayWithArray:@[self.cidString]];
    vc.block = ^(NSString *cid) {
        self.cidString = cid;
        [self requestDataWithCid:cid];
    };
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HDHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDHomeCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate  = self;
    cell.iscell = MainCell;
    cell.indexPath = indexPath;
    
    cell.homeMod = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CSHomeModel *mod = self.listArray[indexPath.row];
    
    [self requestUserDetailWithModel:mod];
    
}

#pragma mark - CSHomeDelegate
- (void)chartButtonClick:(NSIndexPath *)indexPath {
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    CSHomeModel *model = self.listArray[indexPath.row];
    
    [JMSGConversation createSingleConversationWithUsername:model.JIM appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
        if (error == nil) {
            JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
            conversation = resultObject;
            HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
            sendMessageCtl.hidesBottomBarWhenPushed = YES;
            sendMessageCtl.conversation = conversation;
            sendMessageCtl.userName = model.JIM;
            [self.navigationController pushViewController:sendMessageCtl animated:YES];
        } else {
            NSLog(@"%@",error);
            [self.view showTostWithMessage:@"创建会话失败"];
        }
        
    }];
    
}


- (void)requestDataWithCid:(NSString *)cid {
    [self.view showLoading];
    NSDictionary *parmas = @{
        @"cid":cid,
        @"uid":kISNullObject([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid
    };

    [HTTPSessionManger postDataWithNSString:@"/customer/coach" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"===%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            self.listArray = [CSHomeModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            
            if (self.listArray.count > 0) {
                self.tableView.tableFooterView = [[UIView alloc] init];
            } else {
                self.tableView.tableFooterView = self.noDataView;
            }
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
            [self.tableView.mj_header endRefreshing];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
        [self.tableView.mj_header endRefreshing];
    }];
    
}

- (void)requestUserDetailWithModel:(CSHomeModel *)mod {
    
    NSDictionary *parmas = @{
        @"cid":mod.userId
    };
    
    [self.view showLoading];
    [HTTPSessionManger postDataWithNSString:@"/customer/details" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            CSCoachDetailViewController *vc = [[CSCoachDetailViewController alloc] init];
            vc.model = [CSCoachDetailModel mj_objectWithKeyValues:dictionary[@"data"]];
            vc.userMod = mod; // 为了关注
            vc.isApp = HongApp;
            vc.sureBlock = ^{
                [self loadNewData];
            };
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
            
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

- (void)listDidAppear {
    [self loadNewData];
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
