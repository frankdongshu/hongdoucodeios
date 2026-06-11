//
//  HLVVipViewController.m
//  hongdou
//
//  Created by 维康1 on 2020/8/20.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLVVipViewController.h"
#import "HLOpenVVipView.h"
#import "HLVIPCardView.h" // 会员展示
#import "HLPhoneVerityViewController.h"
#import <RPSDK/RPSDK.h>
#import "HLAuthOhterPhoto.h"
#import "HLVipBuyController.h"
#import "HLVipUserCollectionCell.h"
#import "HLFrienderDetailViewController.h"
#import "HLNewChatViewController.h"

#import "HLSettingPopView.h"

#import "GXCardView.h"
#import "GXCardItemDemoCell.h"

@interface HLVVipViewController ()<HLVVipViewDelegate, GXCardViewCellDelegate, GXCardViewDataSource, GXCardViewDelegate, UITableViewDelegate> {
    BOOL _isPassAuth; // 获取认证状态
}

@property (nonatomic, strong) HLOpenVVipView *vvipView;


@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UILabel *warnMsg;

@property (nonatomic, strong) UIImageView *blacImgView;

@property (nonatomic, strong) GXCardView *cardView;
@property (nonatomic, assign) NSInteger cellCount;

@property (nonatomic, strong) UIButton *settingBtn;

@end

@implementation HLVVipViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self isAllAuth];
    
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *blackContainerView = [[UIView alloc] init];
    blackContainerView.clipsToBounds = YES;
    blackContainerView.backgroundColor = kRGBA(38, 37, 44, 1);
    [self.view addSubview:blackContainerView];
    
    [blackContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    // 黑色背景
    self.blacImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vvip_black_bg"]];
    
    [blackContainerView addSubview:self.blacImgView];
    
    [self.blacImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(blackContainerView.mas_top).offset(-kNavBarHeight);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    
    // 展示数据列表View
    [self createVipUserView];
    
    // 开通会员界面
    [self createOpenVVipView];
    
    
}

- (void)createVipUserView {
    
    self.cardView = [[GXCardView alloc] init];
    
    self.cardView.hidden = YES;
    
    self.cardView.dataSource = self;
    self.cardView.delegate = self;
    self.cardView.visibleCount = 3;
    self.cardView.lineSpacing = 15.0;
    self.cardView.interitemSpacing = 10.0;
    self.cardView.maxAngle = 15.0;
    self.cardView.maxRemoveDistance = 100.0;
        
        
    //    self.cardView.isRepeat = YES; // 新加入
        [self.cardView registerNib:[UINib nibWithNibName:NSStringFromClass([GXCardItemDemoCell class]) bundle:nil] forCellReuseIdentifier:@"GXCardViewCell"];
//        [self.cardView reloadData];
    
    
    [self.view addSubview:self.cardView];
    
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(500);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    // 防止设置按钮, 超出到推荐页面
    self.view.clipsToBounds = YES;
    
    self.settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingBtn setImage:[UIImage imageNamed:@"vvip_setting"] forState:UIControlStateNormal];
    self.settingBtn.titleLabel.font = [UIFont fontWithName:@"Medium" size:14];
    [self.settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.settingBtn.backgroundColor = kRGBA(0, 0, 0, .5);
    self.settingBtn.layer.cornerRadius = 18;
    self.settingBtn.hidden = YES;
    [self.settingBtn addTarget:self action:@selector(settingVipClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.settingBtn];
    
    [self.settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(18);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(36);
        make.centerY.equalTo(self.view.mas_centerY).offset(115);
    }];
    
    // 请求数据
    [self requestData];
    
}



//// 无数据占位
//- (UILabel *)warnMsg {
//    if (!_warnMsg) {
//        _warnMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame)/2-15, kScreenWidth, 30)];
//        _warnMsg.text = @"暂无数据";
//        _warnMsg.textColor = [UIColor colorWithWhite:0.5 alpha:1.000];
//        _warnMsg.font = [UIFont systemFontOfSize:16];
//        _warnMsg.textAlignment = NSTextAlignmentCenter;
//    }
//    return _warnMsg;
//}



// 请求数据
- (void)requestData {
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };

    [HLHTTPSessionManager postDataWithNSString:@"/Svip/get" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"!!! : %@",dictionary);

        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.view hideLoading];
            
            self.dataArray = [HLUser mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            
            self.cellCount = self.dataArray.count;
            
            [self.cardView reloadData];
            

        } else {
            
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }


    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:error.localizedDescription];
    }];
    
}

// 分享
- (void)shareVipClickWithUid:(NSString *)uid {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params SSDKSetupShareParamsByText:@"一个简单而真实的恋爱平台！"
                                images:[UIImage imageNamed:@"image_touxiang"]
                                   url:[NSURL URLWithString:@"http://db.hongdou.art/index.php/index/index/invitational.html"]
                                 title:APP_NAME
                        type:SSDKContentTypeAuto];

    [ShareSDK showShareActionSheet:nil //(第一个参数要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，在ipad中要想弹出我们的分享菜单，这个参数必须要传值，可以传自己分享按钮的对象，或者可以创建一个小的view对象去传，传值与否不影响iphone显示)
                     customItems:@[@997,@998]
                     shareParams:params
              sheetConfiguration:nil
                  onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType,NSDictionary *userData,SSDKContentEntity *contentEntity,NSError *error,BOOL end)
             {
    switch (state) {
                 case SSDKResponseStateSuccess:
                         NSLog(@"成功");//成功
                         break;
                 case SSDKResponseStateFail:
                    {
                         NSLog(@"--%@",error.description);//失败
                         break;
                    }
                 case SSDKResponseStateCancel:
                 break;
                 default:
                 break;
             }
    }];
    
}
// 聊天
- (void)chatVipClickWithUserName:(HLUser *)user {
    
//    [JMSGConversation createSingleConversationWithUsername:userName appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
//        if (error == nil) {
//            JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
//            conversation = resultObject;
//            HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
//            sendMessageCtl.hidesBottomBarWhenPushed = YES;
//            sendMessageCtl.conversation = conversation;
//            sendMessageCtl.userName = userName;
//
//            [self.navigationController pushViewController:sendMessageCtl animated:YES];
//        }else{
//            [self.view showTostWithMessage:@"创建会话失败"];
//            return;
//        }
//    }];
    
    
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
            
            [self.cardView reloadDataFormIndex:self.cardView.currentFirstIndex];
            
            
            [btn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
            
        } else {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}


// 设置
- (void)settingVipClick {
    
    [MBProgressHUD showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/Svip/set" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"获取设置: %@",dictionary);
        
        [MBProgressHUD hideLoading];
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            HLSettingPopView *view = [[HLSettingPopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            
            view.dataDic = dictionary[@"data"];
            
            view.SelectBlock = ^{
                [self requestData];
            };
            
            [view showSelf];
            
        }else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 进入详情
- (void)detailVipClickWithUser:(HLUser *)u {
    
    HLFrienderDetailViewController *detailVC = [[HLFrienderDetailViewController alloc] init];
    detailVC.hidesBottomBarWhenPushed = YES;
    detailVC.userInfo = u;
    detailVC.userId = u.userid;

    detailVC.refreshBlock  = ^{

        u.in_follow = YES;
        
        [self.cardView reloadDataFormIndex:self.cardView.currentFirstIndex];

    };

    detailVC.removeBlock = ^{
        
//        [self.cardView reloadData];

    };

    [self.navigationController pushViewController:detailVC animated:YES];
    
}


// 开通会员界面
- (void)createOpenVVipView {
    
    // 监听开通会员成功事件触发
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBuyClick) name:@"BUY_SUCCESS" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isAllAuthAndreloadData) name:DismissLoginView object:nil];
    
    
    _vvipView = [HLOpenVVipView initWithXib:self.view.frame delegate:self];
    _vvipView.backgroundColor = [UIColor clearColor];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headRefresh)];
    
    header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    
    _vvipView.scrollView.mj_header = header;
    
    [self.view addSubview:_vvipView];
    
    
    
    _isPassAuth = NO;
    
    
    // 获取认证状态以及是否开通会员
    [self isAllAuth];
    
}

// 下拉刷新认证状态
- (void)headRefresh {
    
    [self isAllAuth];
    
}

// 重新登录, 重新获取数据及认证状态
- (void)isAllAuthAndreloadData {
    
    if (!self.isLogin) {
        return;
    }
    
    [self isAllAuth];
    
    [self requestData];
    
}

// 购买成功监听事件
- (void)goBuyClick {
    
    [self requestData];
    
    [self.vvipView setHidden:YES];
    
}

// 获取各项认证状态
- (void)isAllAuth {
    
    if (!self.isLogin) {
        return;
    }
    
//    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/Svip/get_attestation" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        [self.vvipView.scrollView.mj_header endRefreshing];
        
//        [MBProgressHUD hideLoading];
        
        NSLog(@"认证结果: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.vvipView.authDic = dictionary[@"data"];
            
            // 首先判断是否已经开通会员, 如果开通直接移除View并跳出
            if ([[dictionary[@"data"][@"sfvhy"] stringValue] isEqualToString:@"1"]) { // 是否开通V会员
                
                self.vvipView.hidden = YES;
                
                [self.cardView setHidden:NO];
                [self.settingBtn setHidden:NO];
                
                
            } else {
                
                self.vvipView.hidden = NO;
                
                [self.cardView setHidden:YES];
                [self.settingBtn setHidden:YES];
                
            }
            
            
            if ([[dictionary[@"data"][@"ptshrz"] stringValue] isEqualToString:@"1"]) { // 平台审核是否通过
                self->_isPassAuth = YES;
            } else {
                self->_isPassAuth = NO;
            }
            
            
            
        } else {
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.vvipView.scrollView.mj_header endRefreshing];
        
    }];
    
}

// 手机号实名认证界面
- (void)shoujirenzheng {
    
    // 手机实名认证
    HLPhoneVerityViewController *phoneVerityVC = [[HLPhoneVerityViewController alloc] init];
    phoneVerityVC.block = ^{
        // 认证成功回调
        [self isAllAuth];
    };
    phoneVerityVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:phoneVerityVC animated:YES];
    
}

// 本人头像认证界面
- (void)benrentouxiang {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":[LoginManager defaultManager].avatar
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/getAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [MBProgressHUD hideLoading];
            
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
                        [self isAllAuth];
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
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 身份证认证界面
- (void)shenfenzheng {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/idAlibabaToken" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [RPSDK startWithVerifyToken:dictionary[@"data"][@"VerifyToken"]
                         viewController:self
                             completion:^(RPResult * _Nonnull result) {
                // 建议接入方调用实人认证服务端接口 DescribeVerifyResult，
                // 来获取最终的认证状态，并以此为准进行业务上的判断和处理。
                NSLog(@"真人身份证认证结果：%@", result);
                switch (result.state) {
                    case RPStatePass:
                        // 认证通过。
                        NSLog(@"真人身份证认证成功");
                        [self isAllAuth];
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
            [MBProgressHUD showMessage:@"获取Token失败" view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

// 学历认证界面
- (void)xulirenzheng {
    
    HLAuthOhterPhoto *vc = [[HLAuthOhterPhoto alloc] init];
    vc.block = ^{
        [self isAllAuth];
    };
    vc.typeString = @"D";
    [self.navigationController pushViewController:vc animated:YES];
    
}

// 下一步
- (void)nextPushClick {
    
    if (self->_isPassAuth) {
        
        HLVipBuyController *vc = [[HLVipBuyController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        
        [MBProgressHUD showMessage:@"请完成所有认证即可下一步" view:nil];
    }
    
}

#pragma mark - GXCardViewDataSource

- (GXCardViewCell *)cardView:(GXCardView *)cardView cellForRowAtIndex:(NSInteger)index {
    GXCardItemDemoCell *cell = [cardView dequeueReusableCellWithIdentifier:@"GXCardViewCell"];
    cell.layer.cornerRadius = 12.0;
    cell.delegate = self;
    
    cell.u = self.dataArray[index];
    
    
    return cell;
}

- (NSInteger)numberOfCountInCardView:(UITableView *)cardView {
    return self.dataArray.count;
}

#pragma mark - GXCardViewDelegate

- (void)cardView:(GXCardView *)cardView didRemoveLastCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index {
    if (!cardView.isRepeat) {
        [cardView reloadDataAnimated:YES];
        
        
        // 刷新数据, 防止关注重复
//        [self requestData];
        
    }
}

//- (void)cardView:(GXCardView *)cardView didRemoveCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index direction:(GXCardCellSwipeDirection)direction {
//    NSLog(@"didRemoveCell forRowAtIndex = %ld, direction = %ld", index, direction);
//
//    if (!cardView.isRepeat && index == 8) {
//        self.cellCount = 15;
//        [cardView reloadMoreDataAnimated:YES];
//    }
//}
//
//- (void)cardView:(GXCardView *)cardView didDisplayCell:(GXCardViewCell *)cell forRowAtIndex:(NSInteger)index {
//    NSLog(@"didDisplayCell forRowAtIndex = %ld", index);
//}

//- (void)cardView:(GXCardView *)cardView didMoveCell:(GXCardViewCell *)cell forMovePoint:(CGPoint)point direction:(GXCardCellSwipeDirection)direction {
//    GXCardItemDemoCell *dcell = (GXCardItemDemoCell*)cell;
//
//    dcell.leftLabel.hidden = !(direction == GXCardCellSwipeDirectionRight);
//    dcell.rightLabel.hidden = !(direction == GXCardCellSwipeDirectionLeft);
//
//    NSLog(@"move point = %@,  direction = %ld", NSStringFromCGPoint(point), direction);
//}


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
