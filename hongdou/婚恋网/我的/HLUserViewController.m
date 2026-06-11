//
//  HLUserViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/1.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLUserViewController.h"
#import "HLUserHeaderView.h"
#import "HLUserCellTableViewCell.h"
#import "HXUserSceondCellTableViewCell.h"
#import "HLUserDetailInfoViewController.h"
#import "HLSettingViewController.h"
#import "HLUserInformationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HLPhotoManageViewController.h"
#import "HLAuthCenterController.h"
#import "HLPrivacyManagerViewController.h"
#import "HLOpenMemberViewController.h"
#import "HLInvitationFriendsViewController.h"
#import "HLNewsFollowsViewController.h"
#import "HLShoppingExchangeController.h" // 商品兑换
#import  "HLAlertOpenVipView.h"
#import "LLAudioRecordeController.h"

#import "LLBlackAndLikeController.h" // 咨询师关注和拉黑列表


#import "CSHomeCityViewController.h" // 城市选择

#import "CSPersonInfoController.h" // 个人信息
#import "CSProjectTypeController.h" // 咨询类型
#import "HDTagViewController.h" // 标签
#import "HLWenDaController.h" // 三观调查
#import "LLStatementController.h"
#import "HLAddressController.h" // 邮寄地址

#import "HLPunchCardController.h" // 签到
#import "HLServicerController.h" // 客服
#import "HLTeacherViewController.h" // 咨询师注册

@interface HLUserViewController ()<HLUserHeaderViewDelegate,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate,GDTRewardedVideoAdDelegate>
{
    NSData *_imgeData;
    UIView *_topView;
}
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userImageArray;/*图标数组*/
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/
@property (nonatomic, strong) NSArray *userInfoArray;/*用户信息数组*/

@property (nonatomic, strong)HLUserHeaderView *headerView;

@property (nonatomic, strong)HLUser *userInfo;

@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;

@end

@implementation HLUserViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isLogin) {
        
        
        
        
        self.userInfo = nil;
        
        [self.tableView reloadData];
        
        self.headerView.nameLabel.text = @"点击登录";
        self.headerView.userIDLabel.text = @"";
        self.headerView.fansLable.text = @"0";
        self.headerView.followLable.text = @"0";
        self.headerView.moneyLable.text = @"0";
        self.headerView.itemCountLab.text = @"";
        self.headerView.haadImageView.image = [UIImage imageNamed:@"icon_head"];
        self.headerView.vipLabel.hidden = YES;
        self.headerView.crownImgV.hidden = YES;
        self.headerView.haadImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.headerView.haadImageView.layer.borderWidth = 2; //边框的宽度
        
        
        return;
    }
    
    // 请求用户信息
    [self requestCurrentUserInfo];
    
}

// 登录完成更新资料
- (void)loginSuccess {
    
    if (self.isLogin) {
        
        // 头像
        [self.headerView.haadImageView sd_setImageWithURL:[NSURL URLWithString:[LoginManager defaultManager].avatar]];
        // 昵称
        self.headerView.nameLabel.text = [LoginManager defaultManager].nickName;
        // userid
        self.headerView.userIDLabel.text = [NSString stringWithFormat:@"ID:%@",[LoginManager defaultManager].userid];
        
        [self requestFriendsUserInfo];
        
        
    }
    
    
}

// 请求交友的信息
- (void)requestFriendsUserInfo{
    
    [HLHTTPSessionManager postDataWithNSString:HLGet_FriendsINFO withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        // 刚注册调了这个接口未填数才会有
        
        // 请求用户信息
        [self requestCurrentUserInfo];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

// 客服
- (void)chatClick {
    
    if (self.isLogin) {
        HLServicerController *vc = [[HLServicerController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
    }
    
}

// 设置
- (void)settingClick {
    
    if (self.isLogin) {
        HLSettingViewController *setVC = [[HLSettingViewController alloc] init];
        setVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setVC animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [HXNavigationController createNavigationBarForViewController:self];
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 44)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navi_setting"] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(130-54, 0, 44, 44);
    [button addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setImage:[UIImage imageNamed:@"service"] forState:UIControlStateNormal];
    
    button1.frame = CGRectMake(130-98, 0, 44, 44);
    [button1 addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button1];
    
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithCustsRigthItem:view style:HXBarButtonItemStylePlain];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginSuccess) name:DismissLoginView object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestCurrentUserInfo) name:UpdateImageOrNickname object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestCurrentUserInfo) name:@"openVIP" object:nil];

    // 解决xib 导航透明的时候 导致 xib view 高度被压缩！⚠️
    self.view.autoresizesSubviews = NO;
    [self creatHederView];
    self.userImageArray =  @[@"memeber",
                             @"image",
                             @"approve",
//                             @"diaocha",
//                             @"biaoqian_h",
//                             @"voice_mine",
                             @"gift",
//                             @"focus",
                             @"privacy",
//                             @"memeber"
    ];
    
    self.userTitleArray = @[@"开通会员",
                            @"动态管理",
                            @"认证中心",
//                            @"三观调查",
//                            @"标签",
//                            @"语音简介",
                            @"邀请有奖",
//                            @"我关注的咨询师",
                            @"隐私管理",
//                            @"咨询师注册"
    ];
    
    self.userInfoArray =  @[@"",@"",@"",@"",@"",@"",@"",@""];
    [self creatTableView];
    
}

- (void)creatHederView{
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, StatusBarHeight+202)];
    
    [_topView az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xF3B2A1],[UIColor colorWithHex:0xEE7998]] locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    self.headerView = [HLUserHeaderView initWithXib:CGRectMake(0, StatusBarHeight, kScreenWidth, 202) delegate:self];
    [_topView addSubview:self.headerView];
    
    [self.view addSubview:_topView];
}
- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame), kScreenWidth, kScreenHeight-202-StatusBarHeight-kTabBarHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HLUserCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLUserCellTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HXUserSceondCellTableViewCell" bundle:nil] forCellReuseIdentifier:@"HXUserSceondCellTableViewCell"];
    [self.view addSubview:_tableView];
}

// 请求当前用户的信息
- (void)requestCurrentUserInfo{
    
    NSDictionary *params = @{
        @"uid":kISNullString([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLGET_UserINFO withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/get %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.userInfo = [HLUser mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            self.headerView.userInfo = weakSelf.userInfo;
            
            self.headerView.nameLabel.text = self.headerView.userInfo.nickname;
            
            if (![[LoginManager defaultManager].balance isEqualToString:weakSelf.userInfo.balance]) {
                [[LoginManager defaultManager] setBalance:weakSelf.userInfo.balance];
            }
            
            
        } else {
            [self.view showError:dictionary[@"msg"]];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
    }];
}

// 是否已经完善信息
- (void)loadRequest{
    if (!self.isLogin) {
        return;
    }
    WeakSelf(weakSelf);
//    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLISPerfect withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
//        [self.view hideLoading];
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            // 1 已经完善  0 需要去完善
            if (![[[dictionary objectForKey:@"data"] objectForKey:@"adopt"] intValue]) {
                [weakSelf pushUserDetailInfo];
            }
        }
    } failure:^(NSError * _Nonnull error) {

    }];

}
// 是否需要先完善个人信息
- (void)pushUserDetailInfo{
    HLUserDetailInfoViewController *userDetailInfoVC = [[HLUserDetailInfoViewController alloc] init];
    userDetailInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userDetailInfoVC animated:YES];
}


#pragma delegate
- (void)pushyUserDetailAction{
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
    } else {
        HLUserInformationViewController *userDetailVC = [[HLUserInformationViewController alloc] init];
        userDetailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userDetailVC animated:YES];
    }
    
    
}

- (void)changeHeaderImage{
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
    } else {
        [self indexPathRowModifyUserIcon];
    }
    
    
}

// 关注我的(粉丝) 界面
- (void)pushFansVC {
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    HLNewsFollowsViewController *vc = [[HLNewsFollowsViewController alloc] init];
    vc.selectInt = 0;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// 我关注的(关注) 界面
- (void)pushFollowVC {
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    HLNewsFollowsViewController *vc = [[HLNewsFollowsViewController alloc] init];
    vc.selectInt = 1;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// 提现界面
- (void)pushCashVC {
    
    
    
}

- (void)changeName {
    
    if (!self.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *userNameTextField = alertController.textFields.firstObject;
        
        if (userNameTextField.text.length < 1) {
            [self.view showTostWithMessage:@"昵称不能为空!"];
        } else {
            [self.view showLoading];
            
            WeakSelf(weakSelf);
            [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:@{@"uid":[LoginManager defaultManager].userid, @"type":@"nickname",@"val":userNameTextField.text} success:^(NSDictionary * _Nonnull dictionary) {
                
                [weakSelf.view hideLoading];
                NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
                if ([code isEqualToString:@"200"] ) {
                    
                    [[LoginManager defaultManager] setNickName:userNameTextField.text];
                    
                    // 请求用户信息
                    [self requestCurrentUserInfo];

                }else
                {
                    [self.view showTostWithMessage:dictionary[@"msg"]];
                }
            } failure:^(NSError * _Nonnull error) {
                [self.view showTostWithMessage:[error localizedDescription]];
            }];
        }
        
    }]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.userInfo.nickname;
        textField.placeholder = @"请输入昵称";
        textField.delegate = self;
    }];
    [self presentViewController:alertController animated:true completion:nil];
    
}


// 昵称限制最高9个字符
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    
    return current.length <= 9;
    
}



#pragma mark tableView代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userTitleArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLUserCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLUserCellTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.row == 0) {
        
        [cell setCellInfo:self.userImageArray[indexPath.row] withTitle:self.userTitleArray[indexPath.row] withContent:[NSString stringWithFormat:@"会员还有%@天到期",kISNullString(self.userInfo.memberdata)?@" - ":self.userInfo.memberdata]];
    }
//    else if (indexPath.row == 6) {
//        HXUserSceondCellTableViewCell *otherCell = [tableView dequeueReusableCellWithIdentifier:@"HXUserSceondCellTableViewCell"];
//        [otherCell setSelectionStyle:UITableViewCellSelectionStyleNone];
//
//        [otherCell setCellInfo:self.userImageArray[indexPath.row] withTitle:self.userTitleArray[indexPath.row] withContent:self.userInfoArray[indexPath.row] withContentImage:@"redbag"];
//
//        return otherCell;
//    }
    else {
        
        [cell setCellInfo:self.userImageArray[indexPath.row] withTitle:self.userTitleArray[indexPath.row] withContent:self.userInfoArray[indexPath.row]];
        
    }
    
    
    return cell;
    
}

// 我的标签
- (void)getMyTagList {
    [MBProgressHUD showLoading];
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/my_label" withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/my_label %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            HDTagViewController *vc = [[HDTagViewController alloc] init];
            vc.dataArray = dictionary[@"data"];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isLogin) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        
        return;
    }
    
    switch (indexPath.row) {
        
        case 0:
        {
            //开通会员
            HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
            openVC.rewardVideoAd = self.rewardVideoAd;
            openVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:openVC animated:YES];
        }
            break;
        case 1:
        {
        
            // 判断是不是 vip 如何是vip 直接进入 如果不是 弹窗
            if (!self.isVip) {
                
                HLAlertOpenVipView *aView = [[HLAlertOpenVipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:@"会员可发布动态。1.5元/月"];
                        aView.SelectBlock = ^{
                            // 跳转购买会员界面
                            [self __pushBuyVipClick];

                        };
                        
                        [aView showSelf];
                
            }else{
                HLPhotoManageViewController *photoVC = [[HLPhotoManageViewController alloc] init];
                photoVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:photoVC animated:YES];
            }
            
            
            
          
            
        }
            break;
        case 2:
        {
            //认证中心
            HLAuthCenterController *authCenterVC = [[HLAuthCenterController alloc] init];
            authCenterVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:authCenterVC animated:YES];
        }
            break;
//        case 3:
//        {
//            // 三观调查
//            HLWenDaController *vc = [[HLWenDaController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//        case 4:
//        {
//            // 标签
//            [self getMyTagList];
//
//        }
//            break;
//        case 5:
//        {
//            // 语音简介
//            LLAudioRecordeController *vc = [[LLAudioRecordeController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//
//        }
//            break;
        case 3:
        {
            //邀请有奖
            HLInvitationFriendsViewController *openVC = [[HLInvitationFriendsViewController alloc] init];
            openVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:openVC animated:YES];
            
        }
            break;
//        case 7:
//        {
//            // 我关注的咨询师
//            LLBlackAndLikeController *vc = [[LLBlackAndLikeController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//
//        }
//            break;
        case 4:
        {
            //隐私管理
            HLPrivacyManagerViewController  *privacyVC = [[HLPrivacyManagerViewController alloc] init];
            privacyVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:privacyVC animated:YES];
        }
            break;
//        case 9:
//        {
//            // 咨询师
//            HLTeacherViewController *vc = [[HLTeacherViewController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
        default:
            break;
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
        return view;
    }
    return [[UIView alloc] init];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return 13;
    }
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] init];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(void)__pushBuyVipClick{
    
    HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
    openVC.rewardVideoAd = self.rewardVideoAd;
    openVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:openVC animated:YES];
}
/**
 *  头像修改选择的路径
 */
- (void)indexPathRowModifyUserIcon{
    
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"修改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertViewController.modalInPopover = YES;
    alertViewController.modalPresentationStyle = UIModalPresentationPopover;
    
    __weak typeof(self) weakSelf = self;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.modalPresentationStyle = 0;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self.view showTostWithMessage:@"应用相机权限受限，请在设置中启用"];
            return;
        }else{
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }
    }];
    [cameraAction setValue:[UIColor colorWithHex:0x8C49FF] forKey:@"titleTextColor"];
    UIAlertAction *photoesAlbum = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self.view showTostWithMessage:@"应用相册权限受限，请在设置中启用"];
            return;
        }else{
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }
    }];
    [photoesAlbum setValue:[UIColor colorWithHex:0x8C49FF] forKey:@"titleTextColor"];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancle setValue:kCellTitleColor forKey:@"titleTextColor"];
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertViewController addAction:cameraAction];
    }
    [alertViewController addAction:photoesAlbum];
    [alertViewController addAction:cancle];
    alertViewController.popoverPresentationController.sourceView = self.view;
    alertViewController.popoverPresentationController.sourceRect = self.view.frame;
    alertViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [self presentViewController:alertViewController animated:YES completion:^{
        [alertViewController tapGesAlert];
    }];
    
}

#pragma mark - ImagePiker delegate
/**
 *  UIImagePickerController图片选择的方法
 *
 *  @param picker 图片选择的容器
 *  @param info   选择图片的内容
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = nil;
        if (picker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }else{
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
//        UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(120, 120)];
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        _imgeData = imageData;
//        newImage = [self circleImage:newImage witghParam:0];
        
        
        
        [self uploadUserHeaderImage];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}
// 上传头像
- (void)uploadUserHeaderImage{
    
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    NSData* imageData = _imgeData;
    if (!_imgeData) {
        [self.view showTostWithMessage:@"请选择头头像"];
    }else{
        
        [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
            
        } success:^(NSDictionary *dictionary) {
            
//            [self.view hideLoading];
            
            NSLog(@"/user/upload %@",dictionary);

            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {

                [self uploadUserInfoVaule:[dictionary objectForKey:@"data"][@"url"]];
            }else
            {
                [self.view showErrorWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError *error) {
            [self.view showTostWithMessage:[error localizedDescription]];
        }];
    }
    
}

// 上传用户基本信息
- (void)uploadUserInfoVaule:(NSString *)vaule{
    
    
//    [self.view showLoading];
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:@{@"uid":[LoginManager defaultManager].userid, @"type":@"head",@"val":vaule} success:^(NSDictionary * _Nonnull dictionary) {
//        [weakSelf.view hideLoading];
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [[LoginManager defaultManager] setAvatar:vaule];
            [weakSelf.headerView.haadImageView sd_setImageWithURL:[NSURL URLWithString:vaule] placeholderImage:[UIImage imageNamed:@"icon_head"]];
        }else
        {
//            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        [self.view showTostWithMessage:dictionary[@"msg"]];
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
}

/**
 *  UIImagePickerController选择完成后调用的方法
 *
 *  @param picker 图片选择的容器
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark image process

/**
 *  上传头像尺寸的大小
 *
 *  @param image   原始图片
 *  @param newSize 图片尺寸大小
 *
 *  @return 裁剪完尺寸后的图片
 */
-(UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

/**
 *  裁剪尺寸后图片圆形的切割
 *
 *  @param image  裁剪后图片
 *  @param inset 距离边的大小
 *
 *  @return 圆形图片
 */
- (UIImage *)circleImage:(UIImage *)image witghParam:(CGFloat)inset{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHex:0xcccccc].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset* 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext ();
    return newImage;
    
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
