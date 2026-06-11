//
//  HLFrienderDetailViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/16.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFrienderDetailViewController.h"
#import "HLFriendsTopView.h"
#import "HLFriendsAlbunTableViewCell.h"
#import "HLFriendsYinXiangCell.h" // 好友印象
#import "HLFriendsInfoTableViewCell.h"
#import "HLFriendsFactorTableViewCell.h"
#import "HLFriendListenTableViewCell.h"
#import "FKGPopOption.h"
#import "HLComplaintViewController.h"
#import "HLPictruesBroweViewController.h"
#import "HLFriendBaseInfoViewController.h"
//#import "JCHATConversationViewController.h"
#import "HDPreviewPhotoController.h"

#import "HLNewChatViewController.h"
#import "CLAmplifyView.h"


@interface HLFrienderDetailViewController ()<UITableViewDelegate,UITableViewDataSource,HLFriendsTopViewDeleagte,FriendsAlbumDelegate>
{
    BOOL isBlock;
    NSInteger isType; // 移除系列操作
}
@property (nonatomic, strong)HLFriendsTopView *topFriendsView;

@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *followBtn;
@property (nonatomic, strong) UIButton *chatBtn;

@property (nonatomic, strong) HLSoundModel *soundModel;

@end

@implementation HLFrienderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
//    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
//        @strongify(self);
//        [self showPopSelector];
//    }];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 44)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navi_more"] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(130-44, 0, 44, 44);
    [button addTarget:self action:@selector(showPopSelector) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"navi_share"] forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(130-88, 0, 44, 44);
    [button1 addTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button1];
    
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithCustsRigthItem:view style:HXBarButtonItemStylePlain];
    
   
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    isBlock = NO;
    isType = 0;
    self.titleArray = @[@"",@"动态",@"好友印象",@"资料介绍",@"交友条件",@"倾听我心"];
    [self creatTableView];

    [self requestDetail];
    [self getUserAudio];
}

// 分享
- (void)sharePressed {
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    if (isBlock && self.refreshBlock) {
        if (isType != 1) {
            self.refreshBlock();
        } else {
            self.removeBlock();
        }
        
    }
}

- (void)requestDetail{
    
    NSDictionary *dic = @{
        @"sid":kISNullString(self.userId)?@"":self.userId,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username,
        @"visitor":@"yes"
    };
    
    if (self.isLogin) {
        
        dic = @{
            @"uid":[LoginManager defaultManager].userid,
            @"sid":kISNullString(self.userId)?@"":self.userId,
            @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
        };
        
    }
    
    
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLUser_Detailed withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.userInfo = [HLUser mj_objectWithKeyValues:dictionary[@"data"]];
            [self settingBottomViewWithFrame];
            
        }else{
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];
        
    }];
    
}

// 获取目标音频
- (void)getUserAudio {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":kISNullString(self.userId)?@"":self.userId,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/ulist/get_sound" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-->%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.soundModel = [HLSoundModel mj_objectWithKeyValues:dictionary[@"data"]];
            
            [self.tableView reloadData];
            
        } else {
            [self.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
        
    }];
    
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -kStatusBarHeight, kScreenWidth, kScreenHeight - kTabBarHeight +kStatusBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    } 
    [self.tableView registerClass:[HLFriendsTopView class] forCellReuseIdentifier:@"HLFriendsTopView"];
    [self.tableView registerClass:[HLFriendsAlbunTableViewCell class] forCellReuseIdentifier:@"HLFriendsAlbunTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLFriendsYinXiangCell" bundle:nil] forCellReuseIdentifier:@"HLFriendsYinXiangCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLFriendsInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFriendsInfoTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLFriendsFactorTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFriendsFactorTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLFriendListenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFriendListenTableViewCell"];
    [self.view addSubview:_tableView];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kTabBarHeight, kScreenWidth, kTabBarHeight)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    
    self.bottomView.layer.masksToBounds = NO;
    self.bottomView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.bottomView.layer.shadowOffset = CGSizeMake(0,0);
    self.bottomView.layer.shadowOpacity = 0.5;
    self.bottomView.layer.shadowRadius = 5;
    // 单边阴影 顶边
    float shadowPathWidth = self.bottomView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, self.bottomView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    self.bottomView.layer.shadowPath = path.CGPath;
    [self.view addSubview:self.bottomView];
    
    [self settingBottomViewWithFrame];
    
}
// 底部视图根据是否关注, 显示界面内容
- (void)settingBottomViewWithFrame {
    
    [self.bottomView removeAllSubviews];
    
    if (self.userInfo.in_follow) {
        self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, kScreenWidth - 34, 40)];
        [self.chatBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x7994FE],[UIColor colorWithHex:0x9184FD]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_goChat"] forState:UIControlStateNormal];
        [self.chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.layer.cornerRadius = 20.f;
        self.chatBtn.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.chatBtn];
    }else{
        
        self.followBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, kScreenWidth/2 - 25, 40)];
        [self.followBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xFFAE9D],[UIColor colorWithHex:0xFF7098]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.followBtn setImage:[UIImage imageNamed:@"icon_addFollow"] forState:UIControlStateNormal];
        [self.followBtn setTitle:@"关注" forState:UIControlStateNormal];
        [self.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followBtn addTarget:self action:@selector(goFollow) forControlEvents:UIControlEventTouchUpInside];
        self.followBtn.layer.cornerRadius = 20.f;
        self.followBtn.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.followBtn];
        
        self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2 +8, 5, kScreenWidth/2 - 25, 40)];
        [self.chatBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.chatBtn setImage:[UIImage imageNamed:@"icon_goChat"] forState:UIControlStateNormal];
        [self.chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.layer.cornerRadius = 20.f;
        self.chatBtn.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.chatBtn];

    }
    
    
}




#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 200+kNavigationBarHeight;
    }
    if (indexPath.section == 1) {
        return self.userInfo.album.count ? kScreenWidth/3.5 : 10;
    }
    if (indexPath.section == 2) {
        if (self.userInfo.effect.count <= 0) {
            return 0;
        } else {
            return UITableViewAutomaticDimension;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0001f;
    }
    if (section == 2) {
        if (self.userInfo.effect.count <= 0) {
            return 0.0001f;
        } else {
            return 40;
        }
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    header.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 100, 40)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextColor:[UIColor colorWithHex:0x3F4658]];
    label.text = self.titleArray[section];
    
    if (section == 2) {
        if (self.userInfo.effect.count <= 0) {
            label.hidden = YES;
        } else {
            label.hidden = NO;
        }
    }
    
    [header addSubview:label];
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:(CGRect)CGRectMake(kScreenWidth - 38, 0, 35, 40)];
    if (section != 0 && section != 2) {
        [header addSubview:nextBtn];
    }
    nextBtn.tag = section;
    [nextBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    return header;
}

- (void)nextClick:(UIButton *)btn{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    switch (btn.tag -1) {
        case 0:
        {
            if (!self.isLogin) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                return;
            }
            
            // 动态
            HLPictruesBroweViewController *pictureVC = [[HLPictruesBroweViewController alloc] init];
            pictureVC.userInfo = self.userInfo;
            pictureVC.isFriends = YES;
            pictureVC.idx = self.idx;
            [self.navigationController pushViewController:pictureVC animated:YES];
        }
            break;
        case 1:
        {
            // 好友印象
            HLFriendBaseInfoViewController *infoVC = [[HLFriendBaseInfoViewController alloc] init];
            infoVC.userInfo = self.userInfo;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
            break;
        default:
        {
            if (!self.isLogin) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                return;
            }
            
            // 资料介绍
            HLFriendBaseInfoViewController *infoVC = [[HLFriendBaseInfoViewController alloc] init];
            infoVC.userInfo = self.userInfo;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
            break;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        HLFriendsTopView *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsTopView"];
        cell.delegate = self;
        cell.friensModel = self.userInfo;
        cell.soundModel = self.soundModel;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }else if (indexPath.section==1) {
        HLFriendsAlbunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsAlbunTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.delegate = self;
        cell.photosArray = self.userInfo.album;
        cell.weakSelf = self;
        return cell;
    }else if (indexPath.section == 2){ // 好友印象
        HLFriendsYinXiangCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsYinXiangCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.items = self.userInfo.effect;
        
        return cell;
    }else if (indexPath.section == 3){
        HLFriendsInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsInfoTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.dataArray = self.userInfo.data;
        return cell;
    }else if (indexPath.section == 4){
        HLFriendsFactorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsFactorTableViewCell"];
        cell.factorLabel.text = self.userInfo.friends.length ? self.userInfo.friends : @"";
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }else{
        HLFriendListenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendListenTableViewCell"];
        cell.listensLabel.text = [NSString stringWithFormat:@"\n %@\n",self.userInfo.listen.length ? self.userInfo.listen : @""];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    
}

- (void)photoImgViewClick:(UITapGestureRecognizer *)tap {
    
    CLAmplifyView *amplifyView = [[CLAmplifyView alloc] initWithFrame:self.view.bounds andGesture:tap andSuperView:self.view];
    [[UIApplication sharedApplication].keyWindow addSubview:amplifyView];
    
}

- (void)showPopSelector {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    
    CGRect frame = CGRectMake(kScreenWidth - 20 , kStatusBarHeight+22, 20, 20);
    
    FKGPopOption *s = [[FKGPopOption alloc] initWithFrame:self.view.bounds];
    s.option_optionContents = @[@"不感兴趣", @"拉黑", @"拉黑并投诉"];

    [[s option_setupPopOption:^(NSInteger index, NSString *content) {
        if (index == 0) {
            [self noLike];
        }else if (index == 1){
            [self pushBlack];
        }else{
            [self goComplaint];
        }
        
    } whichFrame:frame animate:YES] option_show];
}

// 拉黑
- (void)pushBlack{
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLPull_Black withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"bid":self.userInfo.userid,@"mobile":self.userInfo.nickname.length ? self.userInfo.nickname : @""} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            
            self->isBlock = YES;
            self->isType = 1;
            
            [kAppDelegate.window showSuccessWithMessage:dictionary[@"msg"]];
            
//            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePerson" object:self.userInfo.username];
            if (self.detailType == DianZanType) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
    
    
}

// 不感兴趣
- (void)noLike{
    
    [HLHTTPSessionManager postDataWithNSString:HLGoPrivacy_Shield withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"sid":self.userInfo.userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->isBlock = YES;
            self->isType = 1;
//            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePerson" object:self.userInfo.username];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"操作失败，请重试！"];
    }];
}

// 拉黑并投诉
- (void)goComplaint{
    
    HLComplaintViewController *comPlaintVC = [[HLComplaintViewController alloc] init];
    comPlaintVC.userMobile = self.userInfo.username;
    [self.navigationController pushViewController:comPlaintVC animated:YES];
    
}

// 畅聊
- (void)goChat{
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    
    if (self.isChatting) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [HLHTTPSessionManager postDataWithNSString:HLUser_ExamineType withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                if ([[[dictionary[@"data"] objectForKey:@"type"] stringValue] isEqualToString:@"1"]) {
                    //
                    [JMSGConversation createSingleConversationWithUsername:self.userInfo.username appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
                        if (error == nil) {
                            JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
                            conversation = resultObject;
                            HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
    //                        sendMessageCtl.superViewController = self;
                            sendMessageCtl.conversation = conversation;
                            sendMessageCtl.userName = self.userInfo.username;

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
//                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [self.view showTostWithMessage:@"操作失败，请重试！"];
        }];
    }
}

// 去关注
- (void)goFollow{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    [HLHTTPSessionManager postDataWithNSString:HLGoFollow_Shields withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"fid":self.userInfo.userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->isBlock = YES;
            self.followBtn.hidden = YES;
            self.chatBtn.frame = CGRectMake(17, 5, kScreenWidth - 34, 40);
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
