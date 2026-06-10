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

#import "LLBlackAndLikeController.h" // 咨询师关注和拉黑列表

@interface HLMessageListViewController ()<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,JMessageDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *iamgeArray;

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *conversationArr;// 会话信息数组


@end

@implementation HLMessageListViewController

- (void)removePersonClick:(NSNotification *)notifi {
    
    NSString *mobile = notifi.object;
    
    [JMSGConversation deleteSingleConversationWithUsername:mobile appKey:JPushAPPKEY];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePersonClick:) name:@"RemovePerson" object:nil];
    
    [HXNavigationController createNavigationBarForViewController:self];
    self.sc_navigationBar.rightBarButtonItem= [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
    }];
    self.sc_navigationBar.title = @"消息";
    self.titleArray = @[@"",@"关注",@"",@"系统",@""];
    self.iamgeArray = @[@"",@"news_follow",@"",@"news_system",@""];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getConversation) name:DismissLoginView object:nil];

    [self createTopUI];
    [self creatTableView];
    [self loginJpush];

    [self addDelegate];
}

- (void)addDelegate {
    [JMessage addDelegate:self withConversation:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if (!self.isLogin) {
//        [self.tabBarController setSelectedIndex:0];
//        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        [self.view showErrorWithMessage:@"请登录后尝试"];
        [self.conversationArr removeAllObjects];
        [self.tableView reloadData];
        
        
        return;
    }
    
    
//    for (JMSGConversation *conversation in self.conversationArr) {
//        
//        if ([conversation.unreadCount intValue] == 0) {
//            <#statements#>
//        }
//        
//    }
    
    
    [self getConversation];
    
    

}

- (void)loginJpush{
    [JMSGUser loginWithUsername:[LoginManager defaultManager].account password:@"91110113" completionHandler:^(id resultObject, NSError *error) {
        if (error == nil) {
            NSLog(@"登录信息___%@",resultObject);

            // 获取会话
            [self getConversation];
        }else{
//            [self.view showTostWithMessage:@"获取会话消息失败"];
        }
    }];
}
- (void)getConversation{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        [self.tableView.mj_header endRefreshing];
        
        return;
    }
    
    // 获取所有的会话信息
    WeakSelf(weakSelf);
    [JMSGConversation allConversations:^(id resultObject, NSError *error) {
        if (error == nil) {
            NSLog(@"会话信息___%@",resultObject);
//            weakSelf.conversationArr = [self sortConversation:resultObject];
            
            weakSelf.conversationArr = [self sortArray:resultObject];
            
            int unreadNumber = 0;
            
            for (JMSGConversation *con in weakSelf.conversationArr) {
                
                NSLog(@"~~~~~~%@",[con getExtraValueForKey:@"ext"]);
                
                unreadNumber = unreadNumber+ [con.unreadCount intValue];
            }
            
            if (unreadNumber <= 0) {
                [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
                [JMessage setBadge:0];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0; //角标清零
            } else {
                [self.tabBarController.tabBar showBadgeOnItemIndex:3];
                [JMessage setBadge:unreadNumber];
                [UIApplication sharedApplication].applicationIconBadgeNumber = unreadNumber; //角标清零
            }
            
            [weakSelf.tableView reloadData];
            [self setRequestFiledView];
            [weakSelf.tableView.mj_header endRefreshing];
        } else {
//            [self.view showTostWithMessage:@"获取会话消息失败"];
            [self setRequestFiledView];
            [weakSelf.tableView.mj_header endRefreshing];
        }
    }];
    
//    [JMSGConversation createSingleConversationWithUsername:[LoginManager defaultManager].account appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
//
//    }];
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
    if (self.conversationArr.count == 0) {
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

// 接受到信息, 获取会话列表
- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error{
    [self getConversation];
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

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + 110, kScreenWidth, kScreenHeight - 110 - kTabBarHeight - kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    if (IsIOS9) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getConversation)];
    
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
    return 5;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HLMessageTopCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HLMessageTopCollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:self.iamgeArray[indexPath.item]];
    cell.titleLabel.text = self.titleArray[indexPath.item];;
    return cell;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kScreenWidth/5, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    switch (indexPath.item) {
        case 1:
        {
//            HLNewsFollowsViewController *followVC = [[HLNewsFollowsViewController alloc] init];
//            followVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:followVC animated:YES];
            
            // 我关注的
            LLBlackAndLikeController *vc = [[LLBlackAndLikeController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
//        case 1:
//        {
//            HLNewsSeenViewController *seenVC = [[HLNewsSeenViewController alloc] init];
//            seenVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:seenVC animated:YES];
//        }
//            break;
//        case 2:
//        {
//            HLNewsLikeViewController *likeVC = [[HLNewsLikeViewController alloc] init];
//            likeVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:likeVC animated:YES];
//        }
//            break;
//        case 3:
//        {
//            HLNewsChatViewController *chatVC = [[HLNewsChatViewController alloc] init];
//            chatVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:chatVC animated:YES];
//        }
//            break;
        case 3:
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
    return self.conversationArr.count;
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

//先设置Cell可移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLMessageTableViewCell *cell = (HLMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLMessageTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setCellDataWithConversation:self.conversationArr[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
    sendMessageCtl.hidesBottomBarWhenPushed = YES;
//    sendMessageCtl.superViewController = self;
    JMSGConversation *conversation = [_conversationArr objectAtIndex:indexPath.row];
    sendMessageCtl.conversation = conversation;
    JMSGUser *userInfo =  conversation.target;
    sendMessageCtl.userName = userInfo.username;
    // 创建会话
    [JMSGConversation createSingleConversationWithUsername:userInfo.username completionHandler:^(id resultObject, NSError *error) {
        if (error == nil) {
            [self.navigationController pushViewController:sendMessageCtl animated:YES];
        }else{
            [self.view showTostWithMessage:@"创建会话失败"];
            return;
        }
    }];
    
    NSLog(@"用户信息_____%@",userInfo);
    
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
