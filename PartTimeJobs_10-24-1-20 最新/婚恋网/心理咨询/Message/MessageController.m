//
//  MessageController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/4.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "MessageController.h"
#import "HLMessageTableViewCell.h"
#import "HLNewChatViewController.h"

@interface MessageController ()<UITableViewDelegate, UITableViewDataSource, JMessageDelegate>

@property (nonatomic, strong) UIView *navTitleView;

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *conversationArr;
@property (nonatomic, strong) UIView *noDataView;

@end

@implementation MessageController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getConversation];
}

- (void)removePersonClick:(NSNotification *)notifi {
    
    NSString *mobile = notifi.object;
    
    [JMSGConversation deleteSingleConversationWithUsername:mobile appKey:JPushAPPKEY];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePersonClick:) name:@"RemoveRedUser" object:nil];
    
    self.sc_navigationBar.titleView = self.navTitleView;
    
    self.conversationArr = [NSMutableArray array];
    
    [self.view addSubview:self.myTableView];
    
    [JMessage addDelegate:self withConversation:nil];
    
}

// 接受到信息, 获取会话列表
- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error{
    [self getConversation];
}

- (UITableView *)myTableView {
    if (_myTableView == nil) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight) style:UITableViewStylePlain];
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        
        [_myTableView registerNib:[UINib nibWithNibName:@"HLMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLMessageTableViewCell"];
        
        _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getConversation)];
        
//        [_myTableView.mj_header beginRefreshing];
        
    }
    return _myTableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLMessageTableViewCell *cell = (HLMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLMessageTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setCellDataWithConversation:self.conversationArr[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HLNewChatViewController *sendMessageCtl = [[HLNewChatViewController alloc] init];
    sendMessageCtl.isXinLiVC = YES;
    sendMessageCtl.hidesBottomBarWhenPushed = YES;
    JMSGConversation *conversation = [_conversationArr objectAtIndex:indexPath.row];
    sendMessageCtl.conversation = conversation;
    JMSGUser *userInfo =  conversation.target;
    sendMessageCtl.userName = userInfo.username;
    // 创建会话
    [JMSGConversation createSingleConversationWithUsername:userInfo.username completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            [self.navigationController pushViewController:sendMessageCtl animated:YES];
        } else {
            [self.view showTostWithMessage:@"创建会话失败"];
        }
    }];
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JMSGConversation *con = self.conversationArr[indexPath.row];
    
    NSString *ext = [con getExtraValueForKey:@"ext"];
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        JMSGConversation *conversation = [self.conversationArr objectAtIndex:indexPath.row];
        
        if (conversation.conversationType == kJMSGConversationTypeSingle) {
            [JMSGConversation deleteSingleConversationWithUsername:((JMSGUser *)conversation.target).username appKey:JPushAPPKEY
             ];
        } else {
            [JMSGConversation deleteGroupConversationWithGroupId:((JMSGGroup *)conversation.target).gid];
        }
        
        [self.conversationArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[ext isEqualToString:@"1"]?@"取消置顶":@"置顶" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        
        if ([ext isEqualToString:@"1"]) {
            [con setExtraValue:@"0" forKey:@"ext"];
        } else {
            [con setExtraValue:@"1" forKey:@"ext"];
        }
        
        
//        [self.conversationArr exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];//改变某个cell所在的位置
//
//        [self.tableView reloadData];
        
        [self getConversation];
        
        
    }];
    
    topRowAction.backgroundColor = kRGBA(199, 199, 204, 1);

    
    return @[deleteRowAction,topRowAction];
}

#pragma mark – setter&&getter

- (UIView *)navTitleView {
    if (_navTitleView == nil) {
        _navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, _navTitleView.height)];
        titleLab.text = @"消息";
        [_navTitleView addSubview:titleLab];
    }
    return _navTitleView;
}

- (UIView *)noDataView {
    if (_noDataView == nil) {
        _noDataView = [[UIView alloc] initWithFrame:self.myTableView.frame];
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, kScreenWidth, 20)];
        titleLab.text = @"暂无会话";
        titleLab.textColor = HEXColor(@"666666");
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:titleLab];
        
    }
    return _noDataView;
}

// 获取会话列表
- (void)getConversation {
    
    [JMSGConversation allConversations:^(id resultObject, NSError *error) {
        if (!error) { // 成功
            
            NSLog(@"resultObject: %@",resultObject);
            
            self.conversationArr = [self sortArray:resultObject];
            [self.myTableView reloadData];
            
            [self.myTableView.mj_header endRefreshing];
            
            if (self.conversationArr.count > 0) {
                self.myTableView.tableFooterView = [[UIView alloc] init];
            } else {
                self.myTableView.tableFooterView = self.noDataView;
            }
            
            
        } else { // 失败
            
            NSLog(@"error: %@",error);
            [self.myTableView.mj_header endRefreshing];
            
        }
    }];
    
}

- (NSMutableArray *)sortArray:(NSMutableArray *)arr {
    
    NSMutableArray *sortArray = [NSMutableArray array];
    
    for (JMSGConversation *con in arr) {
        
        NSString *str = [con getExtraValueForKey:@"ext"];
        if ([str isEqualToString:@"1"]) {
            [sortArray insertObject:con atIndex:0];
        } else {
            [sortArray addObject:con];
        }
    }
    
    return sortArray;
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
