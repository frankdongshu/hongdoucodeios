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
#import "HLHerWishController.h"

#import "HLNewChatViewController.h"
#import "CLAmplifyView.h"


#import "MKJTagViewTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import "HLAuthDetailCell.h" // 我的标签
#import "HLPiPeiDuCell.h" // 匹配度
#import "HLConstellationCell.h" // 星座配对
#import "HLConstellationController.h" // 星座CP详情
#import "HLPiPeiDuView.h"

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
@property (nonatomic, strong) UIButton *wishBtn;

@property (nonatomic, strong) HLSoundModel *soundModel;

@property (nonatomic, strong) NSMutableArray *xingQuArray, *geXingArr;

@property (nonatomic, strong) NSMutableArray *authArray; // 他的认证

@property (nonatomic, strong) NSDictionary *piPeiDuDic; // 匹配度
@property (nonatomic, strong) NSDictionary *constellationDic; // 星座配对

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
    
    
    if ([[LoginManager defaultManager].userid isEqualToString:self.userId]) {
        button.hidden = YES;
        button1.frame = CGRectMake(130-44, 0, 44, 44);
    } else {
        button.hidden = NO;
    }
    
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithCustsRigthItem:view style:HXBarButtonItemStylePlain];
    
   
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    isBlock = NO;
    isType = 0;
    self.titleArray = @[@"",@"动态",@"好友印象",@"资料介绍",@"星座CP",@"她的认证",@"交友条件",@"三观匹配度",@"倾听我心",@"个性标签",@"兴趣爱好"];
    [self creatTableView];
    if ([[LoginManager defaultManager].userid isEqualToString:self.userId]) {
        self.tableView.frame = CGRectMake(0, -kStatusBarHeight, kScreenWidth, kScreenHeight +kStatusBarHeight);
    }
    
    
    self.geXingArr = [NSMutableArray array];
    self.xingQuArray = [NSMutableArray array];
    self.authArray = [NSMutableArray array];

    [self requestDetail];
    [self getUserAudio];
    [self authDetail]; // 认证标签
    [self requestUserLabel]; // 获取标签
    [self getPiPeiDu]; // 获取匹配度
    [self getConstellationData]; // 星座配对
}

// 获取标签
- (void)requestUserLabel {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":kISNullObject(self.userId)?@"":self.userId,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/ulist/get_label" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            for (NSDictionary *dic in dictionary[@"data"]) {
                if ([dic[@"type"] isEqualToString:@"个性"]) {
                    [self.geXingArr addObject:dic];
                } else {
                    [self.xingQuArray addObject:dic];
                }
            }
            
            [self.tableView reloadData];
            
        } else {
            [self.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
        
    }];
    
}

// 他的认证
- (void)authDetail {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":kISNullObject(self.userId)?@"":self.userId,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/ulist/get_certification" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-!!!->%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.authArray = dictionary[@"data"];
            
            [self.tableView reloadData];
            
        } else {
            [self.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showErrorWithMessage:[error localizedDescription]];
        
    }];
    
}

// 分享
- (void)sharePressed {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    
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
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"sid":kISNullObject(self.userId)?@"":self.userId,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username,
        @"visitor":@"yes"
    };
    
    if (self.isLogin) {
        
        dic = @{
            @"uid":[LoginManager defaultManager].userid,
            @"sid":kISNullObject(self.userId)?@"":self.userId,
            @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
        };
        
    }
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLUser_Detailed withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            self.userInfo = [HLUser mj_objectWithKeyValues:dictionary[@"data"]];
            [self settingBottomViewWithFrame];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 获取目标音频
- (void)getUserAudio {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":kISNullObject(self.userId)?@"":self.userId,
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
    
    [_tableView registerNib:[UINib nibWithNibName:@"MKJTagViewTableViewCell" bundle:nil] forCellReuseIdentifier:@"MKJTagViewTableViewCell"];
    
    [self.tableView registerClass:[HLAuthDetailCell class] forCellReuseIdentifier:@"HLAuthDetailCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"HLPiPeiDuCell" bundle:nil] forCellReuseIdentifier:@"HLPiPeiDuCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"HLConstellationCell" bundle:nil] forCellReuseIdentifier:@"HLConstellationCell"];
    
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
    
    if ([[LoginManager defaultManager].userid isEqualToString:self.userId]) {
        [self.bottomView removeFromSuperview];
        return;
    }
    
    [self.bottomView removeAllSubviews];
    
    if (self.userInfo.in_follow) {
        
        self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 5, kScreenWidth-180-45, 40)];
        [self.chatBtn setImage:[UIImage imageNamed:@"xiangqing_chat"] forState:UIControlStateNormal];
        [self.chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.layer.cornerRadius = 20.f;
        self.chatBtn.layer.masksToBounds = YES;
        
        self.chatBtn.layer.borderColor = [kRGBA(203, 215, 225, 1) CGColor];
        self.chatBtn.layer.borderWidth = 1;
        
        [self.bottomView addSubview:self.chatBtn];
        
        
        self.wishBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.chatBtn.frame)+15, 5, 180, 40)];
        //todo 根据需求隐藏
        self.wishBtn.hidden = YES;
        [self.wishBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xFFAE9D],[UIColor colorWithHex:0xFF7098]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.wishBtn setImage:[UIImage imageNamed:@"xiangqing_gift"] forState:UIControlStateNormal];
        [self.wishBtn setTitle:@"他的心愿" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:kRGBA(103, 114, 141, 1) forState:UIControlStateNormal];
        [self.wishBtn addTarget:self action:@selector(goWishClick) forControlEvents:UIControlEventTouchUpInside];
        self.wishBtn.layer.cornerRadius = 20.f;
        self.wishBtn.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.wishBtn];
        
        
    }else{
        
        CGFloat btnW = (kScreenWidth-142-60)/2;
        
        self.followBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 5, btnW, 40)];
        [self.followBtn setImage:[UIImage imageNamed:@"xiangqing_guanzhu"] forState:UIControlStateNormal];
        [self.followBtn setTitle:@"关注" forState:UIControlStateNormal];
        [self.followBtn setTitleColor:kRGBA(103, 114, 141, 1) forState:UIControlStateNormal];
        [self.followBtn addTarget:self action:@selector(goFollow) forControlEvents:UIControlEventTouchUpInside];
        self.followBtn.layer.cornerRadius = 20.f;
        self.followBtn.layer.masksToBounds = YES;
        self.followBtn.layer.borderColor = [kRGBA(203, 215, 225, 1) CGColor];
        self.followBtn.layer.borderWidth = 1;
        
        
        [self.bottomView addSubview:self.followBtn];
        
        self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.followBtn.frame)+15, 5, btnW, 40)];
        [self.chatBtn setImage:[UIImage imageNamed:@"xiangqing_chat"] forState:UIControlStateNormal];
        [self.chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:kRGBA(103, 114, 141, 1) forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.layer.cornerRadius = 20.f;
        self.chatBtn.layer.masksToBounds = YES;
        
        self.chatBtn.layer.borderColor = [kRGBA(203, 215, 225, 1) CGColor];
        self.chatBtn.layer.borderWidth = 1;
        [self.bottomView addSubview:self.chatBtn];
        
        
        self.wishBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.chatBtn.frame)+15, 5, 142, 40)];
        //todo 根据需求隐藏
        self.wishBtn.hidden = YES;
        [self.wishBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xFFAE9D],[UIColor colorWithHex:0xFF7098]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.wishBtn setImage:[UIImage imageNamed:@"xiangqing_gift"] forState:UIControlStateNormal];
        [self.wishBtn setTitle:@"他的心愿" forState:UIControlStateNormal];
        [self.wishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.wishBtn addTarget:self action:@selector(goWishClick) forControlEvents:UIControlEventTouchUpInside];
        self.wishBtn.layer.cornerRadius = 20.f;
        self.wishBtn.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.wishBtn];

    }
    
    
}

- (void)goWishClick {
    HLHerWishController *vc = [[HLHerWishController alloc ] init];
    vc.theId = self.userId;
    vc.theName = self.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}




#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 10) { // 兴趣标签行数
        return self.xingQuArray.count;
    }
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 200+kNavigationBarHeight;
    }
    if (indexPath.section == 1) {
        return self.userInfo.album.count ? kScreenWidth/3.5+20 : 0;
    }
    if (indexPath.section == 2) {
        if (self.userInfo.effect.count <= 0) {
            return 0;
        } else {
            return UITableViewAutomaticDimension;
        }
    }
    if (indexPath.section == 5) {
        
        if (self.authArray.count >= 4) {
            return 100;
        } else if (self.authArray.count == 0) {
            return 0;
        } else {
            return 50;
        }
        
    }
    if (indexPath.section == 7) {
        return 0;
    }
    if (indexPath.section == 8) {
        if (self.userInfo.listen.length) {
            return UITableViewAutomaticDimension;
        } else {
            return 0;
        }
    }
    
    if (indexPath.section == 9) { // 个性标签
        
        if (self.geXingArr.count == 0) {
            return 0;
        } else {
            return [tableView fd_heightForCellWithIdentifier:@"MKJTagViewTableViewCell" configuration:^(id cell) {
               
                [self configCell:cell indexpath:indexPath];
            }];
        }
        
    }
    if (indexPath.section == 10) { // 兴趣标签
        
        if (self.xingQuArray.count == 0) {
            return 0;
        } else {
            return [tableView fd_heightForCellWithIdentifier:@"MKJTagViewTableViewCell" configuration:^(id cell) {
               
                [self configCell:cell indexpath:indexPath];
            }];
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.0001f;
    }
    if (section == 1) {
        return self.userInfo.album.count ? 40 : 0.0001f;
    }
    if (section == 2) {
        if (self.userInfo.effect.count <= 0) {
            return 0.0001f;
        } else {
            return 40;
        }
    }
    if (section == 5) {
        
        if (self.authArray.count == 0) {
            return 0.0001f;
        } else {
            return 40;
        }
        
    }
    
    if (section == 7) {
        
        return 0;
        
    }
    
  
    if (section == 8) {
        if (self.userInfo.listen.length) {
            return 40;
        } else {
            return 0.0001f;
        }
    }
    if (section == 9) { // 个性标签
        
        if (self.geXingArr.count <= 0) {
            return 0.0001f;
        } else {
            return 40;
        }
        
    }
    if (section == 10) { // 兴趣标签
        
        if (self.xingQuArray.count <= 0) {
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 200, 40)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextColor:[UIColor colorWithHex:0x3F4658]];
    label.text = self.titleArray[section];
    
    if (section == 1) {
        if (self.userInfo.album.count) {
            label.hidden = NO;
        } else {
            label.hidden = YES;
        }
    }
    if (section == 2) {
        if (self.userInfo.effect.count <= 0) {
            label.hidden = YES;
        } else {
            label.hidden = NO;
        }
    }
    if (section == 4) { // 星座CP
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xing_aixin"]];
        imgV.frame = CGRectMake(kScreenWidth-38-30, 5, 30, 30);
        
        [header addSubview:imgV];
    }
    if (section == 5) { // 他的标签
        if (self.authArray.count <= 0) {
            label.hidden = YES;
        } else {
            label.hidden = NO;
        }
    }
    if (section == 7) { // 他的标签
        label.hidden = YES;
    }
    if (section == 8) { // 倾听我心
        if (self.userInfo.listen.length) {
            label.hidden = NO;
        } else {
            label.hidden = YES;
        }
    }
    if (section == 9) {
        if (self.geXingArr.count <= 0) {
            label.hidden = YES;
        } else {
            label.hidden = NO;
        }
    }
    
    if (section == 10) {
        if (self.xingQuArray.count <= 0) {
            label.hidden = YES;
        } else {
            label.hidden = NO;
        }
    }
    
    [header addSubview:label];
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:(CGRect)CGRectMake(kScreenWidth - 38, 0, 35, 40)];
    if (section != 0 && section != 2 && section != 5 && section != 8 && section != 9 && section != 10) {
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
        case 3:
        {
            // 星座配对
            HLConstellationController *vc = [[HLConstellationController alloc] init];
            vc.dic = self.constellationDic;
            vc.userInfo = self.userInfo;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:  // 答题弹窗
        {
            HLPiPeiDuView *pView = [[HLPiPeiDuView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            
            [pView showSelf];
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
    }
//    else if (indexPath.section == 3){ // 资料介绍
//        HLFriendsInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsInfoTableViewCell"];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.dataArray = self.userInfo.data;
//        return cell;
//    }
    else if (indexPath.section == 4){ // 星座配对
        HLConstellationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLConstellationCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.theDic = self.constellationDic;
        
        return cell;
    }
    else if (indexPath.section == 5){ // 他的认证
        HLAuthDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLAuthDetailCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        cell.authArray = self.authArray;
        
        return cell;
    }
//    else if (indexPath.section == 6){
//        HLFriendsFactorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsFactorTableViewCell"];
//        cell.factorLabel.text = self.userInfo.friends.length ? self.userInfo.friends : @"";
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        return cell;
//    }
    else if (indexPath.section == 7){ // 匹配度
        HLPiPeiDuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLPiPeiDuCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        NSMutableString *str = self.piPeiDuDic[@"matching"];
        int i = [[str substringWithRange:NSMakeRange(0, str.length-1)] intValue];
        
        cell.circleView.progress = i/100;
        
        NSString *subjectStr = kISNullObject(self.piPeiDuDic[@"subject"])?@"-":self.piPeiDuDic[@"subject"];
        
        cell.sameAskLab.text = [NSString stringWithFormat:@"双方都参与过的话题：%@",subjectStr];
        
        NSString *answerStr = kISNullObject(self.piPeiDuDic[@"answer"])?@"-":self.piPeiDuDic[@"answer"];
        
        cell.sameDaAn.text = [NSString stringWithFormat:@"观点相同：%@",answerStr];
        
        cell.detailLab.text = kISNullObject(self.piPeiDuDic[@"evaluate"])?@"":[NSString stringWithFormat:@"\n%@\n",self.piPeiDuDic[@"evaluate"]];
        
        return cell;
    }else if (indexPath.section == 8){
        HLFriendListenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendListenTableViewCell"];
        cell.listensLabel.text = [NSString stringWithFormat:@"\n %@\n",self.userInfo.listen.length ? self.userInfo.listen : @""];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    } else {
        MKJTagViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKJTagViewTableViewCell" forIndexPath:indexPath];
        [self configCell:cell indexpath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return cell;
    }
    
}

- (void)configCell:(MKJTagViewTableViewCell *)cell indexpath:(NSIndexPath *)indexpath
{
    [cell.tagView removeAllTags];
    cell.tagView.preferredMaxLayoutWidth = kScreenWidth;
    cell.tagView.padding = UIEdgeInsetsMake(20, 50, 20, 20);
    cell.tagView.lineSpacing = 15;
    cell.tagView.interitemSpacing = 15;
    cell.tagView.singleLine = NO;
    // 给出两个字段，如果给的是0，那么就是变化的,如果给的不是0，那么就是固定的
//        cell.tagView.regularWidth = 80;
        cell.tagView.regularHeight = 30;
    
    NSString *typeString;
    
    if (self.xingQuArray.count != 0) {
        typeString = self.xingQuArray[indexpath.row][@"type"];
    }
    
    NSArray *arr = [NSArray array];
    
    if (indexpath.section == 3) {
        arr = self.userInfo.data;
        cell.tagView.padding = UIEdgeInsetsMake(10, 20, 10, 20);
        cell.imageView.image = nil;
    }
    else if (indexpath.section == 6) {
        arr = self.userInfo.friends_arr;
        cell.tagView.padding = UIEdgeInsetsMake(10, 20, 10, 20);
        cell.imageView.image = nil;
    }
    
    else if (indexpath.section == 9) {
        if (self.geXingArr.count > 0) {
            arr = self.geXingArr[indexpath.row][@"label"];
            cell.imageView.image = [UIImage imageNamed:@"biaoqian"];
        }
        
    } else {
        arr = self.xingQuArray[indexpath.row][@"label"];
        
        if ([typeString isEqualToString:@"动漫"]) {
            cell.imageView.image = [UIImage imageNamed:@"dongman"];
        } else if ([typeString isEqualToString:@"影视"]) {
            cell.imageView.image = [UIImage imageNamed:@"dianying"];
        } else if ([typeString isEqualToString:@"旅游"]) {
            cell.imageView.image = [UIImage imageNamed:@"lvyou"];
        } else if ([typeString isEqualToString:@"美食"]) {
            cell.imageView.image = [UIImage imageNamed:@"lingshi"];
        } else if ([typeString isEqualToString:@"运动"]) {
            cell.imageView.image = [UIImage imageNamed:@"yundong"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"yinyue"];
        }
        
    }
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKTag *tag = [[SKTag alloc] initWithText:arr[idx]];
        
        tag.font = [UIFont systemFontOfSize:12];
        
        if (indexpath.section == 3 || indexpath.section == 6) {
            tag.textColor = kRGBA(125, 130, 144, 1);
            tag.bgColor = kRGBA(245, 244, 250, 1);
        }
        else if (indexpath.section == 9) {
            if (indexpath.row == 0) { // 个性
                tag.textColor = kRGBA(255, 92, 122, 1);
                tag.bgColor = kRGBA(252, 240, 242, 1);
            }
        }
        if (indexpath.section == 10) {
            if ([typeString isEqualToString:@"动漫"]) {
                tag.textColor = kRGBA(234, 90, 175, 1);
                tag.bgColor = kRGBA(254, 227, 243, 1);
            }
            if ([typeString isEqualToString:@"影视"]) {
                tag.textColor = kRGBA(165, 109, 241, 1);
                tag.bgColor = kRGBA(242, 231, 255, 1);
            }
            if ([typeString isEqualToString:@"旅游"]) {
                tag.textColor = kRGBA(66, 196, 228, 1);
                tag.bgColor = kRGBA(223, 249, 255, 1);
            }
            if ([typeString isEqualToString:@"美食"]) {
                tag.textColor = kRGBA(251, 184, 56, 1);
                tag.bgColor = kRGBA(253, 247, 235, 1);
            }
            if ([typeString isEqualToString:@"运动"]) {
                tag.textColor = kRGBA(92, 179, 99, 1);
                tag.bgColor = kRGBA(236, 254, 237, 1);
            }
            if ([typeString isEqualToString:@"音乐"]) {
                tag.textColor = kRGBA(117, 169, 255, 1);
                tag.bgColor = kRGBA(235, 244, 253, 1);
            }
        }
        
        tag.cornerRadius = 15;
        tag.enable = YES;
        tag.padding = UIEdgeInsetsMake(5, 10, 5, 10);
        [cell.tagView addTag:tag];
    }];
    
}

// 星座配对
- (void)getConstellationData {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":kISNullObject(self.userInfo.userid)?kISNullObject(self.userId)?@"":self.userId:self.userInfo.userid,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
    };
    
    
    [HLHTTPSessionManager postDataWithNSString:@"/ulist/get_constellation" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.constellationDic = dictionary[@"data"];
            
            [self.tableView reloadData];
            
        } else {
            
            // 查看自己会出
//            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}
// 匹配度
- (void)getPiPeiDu {
    
    if (!self.isLogin) {
        return;
    }
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":kISNullObject(self.userInfo.userid)?kISNullObject(self.userId)?@"":self.userId:self.userInfo.userid,
        @"mobile":kISNullObject(self.userInfo.username)?@"":self.userInfo.username
    };
    
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/subject/get_matching" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.piPeiDuDic = dictionary[@"data"];
            
            [self.tableView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:error.localizedDescription];
    }];
    
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
- (void)goChat {
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    if (self.isChatting) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [HLHTTPSessionManager postDataWithNSString:HLUser_ExamineType withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                if ([[[dictionary[@"data"] objectForKey:@"type"] stringValue] isEqualToString:@"1"]) {
                    
//                    [JMSGConversation createSingleConversationWithUsername:self.userInfo.username appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
//                        if (error == nil) {
//                            JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
//                            conversation = resultObject;
//                            HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
//                            sendMessageCtl.conversation = conversation;
//                            sendMessageCtl.userName = self.userInfo.username;
//
//                            [self.navigationController pushViewController:sendMessageCtl animated:YES];
//                        } else {
//                            [self.view showTostWithMessage:@"创建会话失败"];
//                            return;
//                        }
//                    }];
                    
                    
                    HLChatController *vc = [[HLChatController alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    vc.chatDic = @{
                        @"cid":self.userInfo.userid,
                        @"cname":self.userInfo.nickname,
                        @"cmobile":self.userInfo.username,
                        @"chead":self.userInfo.head
                    };
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                } else {
                    [self.view showTostWithMessage:@"您的个人资料审核未通过，请修改个人资料后继续使用"];
                }
                
            } else {
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
            
            self.chatBtn.frame = CGRectMake(15, 5, kScreenWidth-180-45, 40);
            self.wishBtn.frame = CGRectMake(CGRectGetMaxX(self.chatBtn.frame)+15, 5, 180, 40);
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
