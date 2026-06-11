//
//  HLMessageListViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLMessageListViewController.h"
#import "HLMessageTopCollectionViewCell.h"
#import "HLNewsFollowsViewController.h"
#import "HLNewsSeenViewController.h"
#import "HLNewsLikeViewController.h" // 点赞
#import "HLNewsChatViewController.h"
#import "HLNewsSystemViewController.h"
#import "HLMessageTableViewCell.h"
//#import "JCHATConversationViewController.h"
#import "HLNewChatViewController.h"
#import "HLChatController.h"


@interface HLMessageListViewController ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,showRecvMsgDelegate,returnUserStatusDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *iamgeArray;

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *conversationArr;// 会话信息数组


@property (nonatomic, strong) NSMutableArray *contactListArr;



@end

@implementation HLMessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [HXNavigationController createNavigationBarForViewController:self];
    self.sc_navigationBar.rightBarButtonItem= [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        
    }];
    self.sc_navigationBar.title = @"消息";
    self.titleArray = @[@"关注",@"我看过",@"点赞"];
    self.iamgeArray = @[@"news_follow",@"news_seen",@"news_call"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestChatList) name:DismissLoginView object:nil];

    [self createTopUI];
    [self creatTableView];
    
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if (err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    
    return dic;
}

// 获取会话列表
- (void)requestChatList {
    
    if (!self.isLogin) {
        
        [self.contactListArr removeAllObjects];
        
        [self setRequestFiledView];
        
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/im/getlist" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/im/getlist: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.contactListArr = [dictionary[@"data"] mutableCopy];
            
            
            // tabBar未读角标
            for (int i=0; i<self.contactListArr.count; i++) {
                
                NSDictionary *dic = self.contactListArr[i];
                
                if (!kISNullObject(dic[@"unread"])) {
                    
                    // 有未读直接显示红点并跳出遍历
                    if (![[dic[@"unread"] stringValue] isEqualToString:@"0"]) {
                        
                        [self.tabBarController.tabBar showBadgeOnItemIndex:3 unNumber:dic[@"unread"]];
                        break;
                    }
                    
                }
                
                if (i == self.contactListArr.count-1) { // 这个条件能成立说明会话列表没有未读
                    [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
                }
                
            }
            
            
            [self.tableView reloadData];
            
            [self.tableView.mj_header endRefreshing];
            
        } else {
            
        }
        
        [self setRequestFiledView];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

- (void)getChatList {
    
    if (self.isLogin) {
        
        [[XMUserManager sharedInstance] setAppAccount:[LoginManager defaultManager].account];
        [[XMUserManager sharedInstance] userLogin];
        
    } else {
        
        [self.contactListArr removeAllObjects];
        
        [self setRequestFiledView];
    }
    
}

- (void)returnUserStatus:(MCUser *)user status:(int)status {
    if (user != nil) {
        
        if (status == Online) { // 在线
            
            [self requestChatList];
            
        } else { // 离线
            NSLog(@" === 登录失败 ===");
        }
        
    }
    return;
}

- (void)showRecvMsg:(MIMCMessage *)packet user:(MCUser *)user {
    
    // 获取会话列表
    [self requestChatList];
    
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (!self.isLogin) {
//        [self.tabBarController setSelectedIndex:0];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        // 角标清零
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        
        [self.conversationArr removeAllObjects];
        [self.tableView reloadData];
        [self setRequestFiledView];
        
        
        return;
    }
    
    XMUserManager *userManager = [XMUserManager sharedInstance];
    userManager.showRecvMsgDelegate = self;
    userManager.returnUserStatusDelegate = self;
    [userManager setAppAccount:[LoginManager defaultManager].account];
    [userManager userLogin];
    
    // 获取会话列表
    [self requestChatList];

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

-(void)setRequestFiledView
{
    if (self.contactListArr.count == 0) {
        //设置空白界面
        UIView *blankBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-120)/2, 100, 120, 100)];
        logoImg.image = [UIImage imageNamed:@"ic_no_events"];
        [blankBg addSubview:logoImg];
        UILabel *warnMsg = [[UILabel alloc]initWithFrame:CGRectMake(30, logoImg.bottom, kScreenWidth-60, 80)];
        warnMsg.numberOfLines = 2;
        warnMsg.text = self.isLogin?@"下拉可以刷新哦~":@"请登录后尝试~";
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

#pragma mark --排序conversation
- (NSMutableArray *)sortConversation:(NSMutableArray *)conversationArr {
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"latestMessage.timestamp" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    
    NSArray *sortedArray = [conversationArr sortedArrayUsingDescriptors:sortDescriptors];
    
    return [NSMutableArray arrayWithArray:sortedArray];

}

-(void)createTopUI{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumLineSpacing = 0;  //行间距
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, 110) collectionViewLayout:flow];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.collectionView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HLMessageTopCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HLMessageTopCollectionViewCell"];    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
}

- (void)upDateClick {
    
    if (self.isLogin) {
        [self requestChatList];
    } else {
        [self.tableView.mj_header endRefreshing];
    }
    
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + 110, kScreenWidth, kScreenHeight - 110 - kTabBarHeight - kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    if (IsIOS9) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(upDateClick)];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    // 马上进入刷新状态
    //[header beginRefreshing];
    
    // 设置header
   _tableView.mj_header = header;
    [_tableView registerNib:[UINib nibWithNibName:@"HLMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLMessageTableViewCell"];
    
    [self.view addSubview:_tableView];
}

#pragma mark --UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLMessageTopCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLMessageTopCollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:self.iamgeArray[indexPath.item]];
    cell.titleLabel.text = self.titleArray[indexPath.item];;
    return cell;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kScreenWidth/3, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    switch (indexPath.item) {
        case 0:
        {
            HLNewsFollowsViewController *followVC = [[HLNewsFollowsViewController alloc] init];
            followVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:followVC animated:YES];
        }
            break;
        case 1:
        {
            HLNewsSeenViewController *seenVC = [[HLNewsSeenViewController alloc] init];
            seenVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:seenVC animated:YES];
        }
            break;
        case 2:
        {
            HLNewsLikeViewController *likeVC = [[HLNewsLikeViewController alloc] init];
            likeVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:likeVC animated:YES];
        }
            break;
        case 3:
        {
            HLNewsChatViewController *chatVC = [[HLNewsChatViewController alloc] init];
            chatVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatVC animated:YES];
        }
            break;
        case 4:
        {
            HLNewsSystemViewController *systemVC = [[HLNewsSystemViewController alloc] init];
            systemVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:systemVC animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma mark tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactListArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001f;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JMSGConversation *con = self.conversationArr[indexPath.row];
    
    NSString *ext = [con getExtraValueForKey:@"ext"];
    
    
    NSDictionary *dic = self.contactListArr[indexPath.row];
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [self deleteChatListWithCid:dic[@"cid"]];
        
        [self.contactListArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    
    // 是否置顶
    NSString *topString = [NSString stringWithFormat:@"%@",dic[@"type"]];
    
    
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[topString isEqualToString:@"1"]?@"取消置顶":@"置顶" handler:^(UITableViewRowAction *_Nonnull action, NSIndexPath *_Nonnull indexPath) {
        
        if ([topString isEqualToString:@"1"]) {
            [self topConversationWithUrl:@"/im/nooplist" Cid:dic[@"cid"]]; // 取消置顶
        } else {
            [self topConversationWithUrl:@"/im/nioplist" Cid:dic[@"cid"]]; // 置顶
        }
        
//        [self.contactListArr exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];//改变某个cell所在的位置
//
//        [self.tableView reloadData];
        
        
        [self.tableView.mj_header beginRefreshing];
        
    }];
    
    topRowAction.backgroundColor = kRGBA(199, 199, 204, 1);

    
//    return @[deleteRowAction,topRowAction];
    return @[];
}

// 置顶会话
- (void)topConversationWithUrl:(NSString *)url Cid:(NSString *)cid {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"cid":cid
    };
    
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"会话置顶: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 删除会话列表
- (void)deleteChatListWithCid:(NSString *)cid {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"cid":cid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/im/dellist" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/im/dellist: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

//先设置Cell可移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLMessageTableViewCell *cell = (HLMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLMessageTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    [cell setCellDataWithConversation:self.conversationArr[indexPath.row]];
    
//    [cell setCellDataWithLastMessage:self.contactListArr[indexPath.row] unReadArr:self.unreadArray];
    
    [cell setSocketCellDataWithLastMessage:self.contactListArr[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HLChatController *vc = [[HLChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.chatDic = self.contactListArr[indexPath.row];
    vc.isList = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
//    HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
//    sendMessageCtl.hidesBottomBarWhenPushed = YES;
////    sendMessageCtl.superViewController = self;
//    JMSGConversation *conversation = [_conversationArr objectAtIndex:indexPath.row];
//    sendMessageCtl.conversation = conversation;
//    JMSGUser *userInfo =  conversation.target;
//    sendMessageCtl.userName = userInfo.username;
//    // 创建会话
//    [JMSGConversation createSingleConversationWithUsername:userInfo.username completionHandler:^(id resultObject, NSError *error) {
//        if (error == nil) {
//            [self.navigationController pushViewController:sendMessageCtl animated:YES];
//        }else{
//            [self.view showTostWithMessage:@"创建会话失败"];
//            return;
//        }
//    }];
//
//    NSLog(@"用户信息_____%@",userInfo);
    
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
