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

#import "HLPrivacyManagerViewController.h"
#import "HLOpenMemberViewController.h"

#import "HLNewsFollowsViewController.h"

#import "HLCitySelectorViewController.h"

#import "LLAudioRecordeController.h"

#import "LLBlackAndLikeController.h" // 咨询师关注和拉黑列表

#import "XinLiViewController.h" // 心理咨询TabBarController
#import "CSHomeCityViewController.h" // 城市选择
#import "CSUserInfoViewController.h" // 信息填写
#import "CSPersonInfoController.h" // 个人信息
#import "CSProjectTypeController.h" // 咨询类型
#import "LLMyFaBuController.h" // 我的发布

@interface HLUserViewController ()<HLUserHeaderViewDelegate,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>
{
    NSData *_imgeData;
    UIImageView *_topView;
}
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userImageArray;/*图标数组*/
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/
@property (nonatomic, strong) NSArray *userInfoArray;/*用户信息数组*/

@property (nonatomic, strong)HLUserHeaderView *headerView;

@property (nonatomic, strong)HLUser *userInfo;

@end

@implementation HLUserViewController

//
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if (!self.isLogin) {
        
        if ([MyLogin userHadLogin]) { // 心理咨询
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            
            if (kISNullObject(u.city)) { // 城市选择
                CSHomeCityViewController *vc = [[CSHomeCityViewController alloc]init];
                vc.cityType = CityNo;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                if (kISNullObject(u.sex)) { // 信息填写
                    CSUserInfoViewController *vc = [[CSUserInfoViewController alloc]init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    if (
                        kISNullObject(u.intelligence) ||
                        kISNullObject(u.education) ||
                        kISNullObject(u.school) ||
                        kISNullObject(u.major) ||
                        kISNullObject(u.descr) ||
                        kISNullObject(u.teaching) ||
                        kISNullObject(u.cost_low)
                        ) {
                        
                        CSPersonInfoController *vc = [[CSPersonInfoController alloc] init];
                        vc.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    } else {
                        
                        if (kISNullObject([MyLogin getCurrentLoginUser].curriculum)) {
                            CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
                            vc.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:vc animated:YES];
                        } else {
                            
                            XinLiViewController *vc = [[XinLiViewController alloc] init];
                            vc.modalPresentationStyle = 0;
                            [self presentViewController:vc animated:NO completion:nil];
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
        
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
    
    [self loadRequest];
    
    // 请求用户信息
    [self requestCurrentUserInfo];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [HXNavigationController createNavigationBarForViewController:self];
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    @weakify(self);
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_setting"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.isLogin) {
            HLSettingViewController *setVC = [[HLSettingViewController alloc] init];
            setVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:setVC animated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        }
        
        
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestCurrentUserInfo) name:DismissLoginView object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestCurrentUserInfo) name:UpdateImageOrNickname object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestCurrentUserInfo) name:@"openVIP" object:nil];

    // 解决xib 导航透明的时候 导致 xib view 高度被压缩！⚠️
    self.view.autoresizesSubviews = NO;
    [self creatHederView];
    self.userImageArray =  @[@[@"memeber",@"focus",@"fabu_ico"]];
    //,@"focus",@"call",@"image",@"privacy",@"invite"
    self.userTitleArray = @[@[@"开通会员",@"关注/拉黑",@"我的发布"]];
    self.userInfoArray =  @[@[@"",@"",@""]];
    [self creatTableView];
    
    // 请求用户信息
//    [self requestCurrentUserInfo];
    
}
- (void)creatHederView{
    
    _topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, StatusBarHeight+202)];
    _topView.userInteractionEnabled = YES;
    _topView.image = [UIImage imageNamed:@"mine_bg"];
    _topView.contentMode = UIViewContentModeScaleAspectFill;
    
//    [_topView az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xF3B2A1],[UIColor colorWithHex:0xEE7998]] locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    self.headerView = [HLUserHeaderView initWithXib:CGRectMake(0, StatusBarHeight, kScreenWidth, 202) delegate:self];
    [_topView addSubview:self.headerView];
    
    [self.view addSubview:_topView];
}
- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame), kScreenWidth, kScreenHeight-202-kTabBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
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
        
        NSLog(@"====== %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.userInfo = [HLUser mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            
            [[LoginManager defaultManager] setMemberdata:weakSelf.userInfo.memberdata];
            
            self.headerView.userInfo = weakSelf.userInfo;
            
            self.headerView.nameLabel.text = self.headerView.userInfo.nickname;
            
        }else {
//            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"获取个人信息失败"];
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
//    HLUserDetailInfoViewController *userDetailInfoVC = [[HLUserDetailInfoViewController alloc] init];
//    userDetailInfoVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:userDetailInfoVC animated:YES];
    
    //居住地
    HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
    citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
        [self requestUploadDataWithCityId:model.cityID];
    };
    citySelectVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:citySelectVC animated:YES];
        
}

- (void)requestUploadDataWithCityId:(NSString *)cityId {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"habitation":cityId
    };
    
    [kAppDelegate.window showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserEVPI withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [kAppDelegate.window hideLoading];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateImageOrNickname object:nil];
            // 通知相对界面需要刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [kAppDelegate.window showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showErrorWithMessage:error.localizedDescription];
    }];
    
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
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        
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
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        
        return;
    }
    
    HLNewsFollowsViewController *vc = [[HLNewsFollowsViewController alloc] init];
    vc.selectInt = 1;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
                    
                    // 请求用户信息
                    [self requestCurrentUserInfo];

                }else
                {
                    [self.view showTostWithMessage:dictionary[@"msg"]];
                }
            } failure:^(NSError * _Nonnull error) {
                if (error.code == NSURLErrorBadServerResponse) {
                    [self.view showTostWithMessage:@"修改失败，请稍后再试！"];
                }else
                {
                    [self.view showTostWithMessage:@"修改失败，请检查网络！"];
                }
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.userInfoArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *arr = self.userTitleArray[section];
    
    return arr.count;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLUserCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLUserCellTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.section==0) {
        if (indexPath.row == 0) {
            [cell setCellInfo:self.userImageArray[0][indexPath.row] withTitle:self.userTitleArray[0][indexPath.row] withContent:[NSString stringWithFormat:@"会员还有%@天到期",kISNullString(self.userInfo.memberdata)?@" - ":self.userInfo.memberdata]];
        }else{
            [cell setCellInfo:self.userImageArray[0][indexPath.row] withTitle:self.userTitleArray[0][indexPath.row] withContent:self.userInfoArray[0][indexPath.row]];
        }
        return cell;
    }else{
        [cell setCellInfo:self.userImageArray[1][indexPath.row] withTitle:self.userTitleArray[1][indexPath.row] withContent:self.userInfoArray[1][indexPath.row]];
        return cell;
    }
    //    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.isLogin) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        
        return;
    }
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                {
                    //开通会员
                    HLOpenMemberViewController *openVC = [[HLOpenMemberViewController alloc] init];
                    openVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:openVC animated:YES];
                }
                break;
            case 1:
            {
//                //认证中心
//                HLAuthCenterController *authCenterVC = [[HLAuthCenterController alloc] init];
//                authCenterVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:authCenterVC animated:YES];
                
                // 我关注的咨询师
                LLBlackAndLikeController *vc = [[LLBlackAndLikeController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
                {
                    // 我的发布
                    LLMyFaBuController *vc = [[LLMyFaBuController alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
            {
                
            }
                break;
            case 1:
            {
                //隐私管理
                HLPrivacyManagerViewController  *privacyVC = [[HLPrivacyManagerViewController alloc] init];
                privacyVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:privacyVC animated:YES];
                
            }
                break;
            
            case 2:
            {
                // 测试个人完善信息
                HLUserDetailInfoViewController *detailVC = [[HLUserDetailInfoViewController alloc] init];
                detailVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailVC animated:YES];
            }
                break;
            default:
                break;
        }
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
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //
            [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
            
        } success:^(NSDictionary *dictionary) {
            
//            [self.view hideLoading];
            
            NSLog(@"=====头像: %@",dictionary);

            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {

                [self uploadUserInfoVaule:[dictionary objectForKey:@"data"][@"url"]];
            }else
            {
                [self.view showErrorWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError *error) {
            if (error.code == NSURLErrorBadServerResponse) {
                [self.view showErrorWithMessage:@"上传失败，请稍后再试！"];
            }else
            {
                [self.view showErrorWithMessage:@"上传失败，请检查网络！"];
            }
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
        if (error.code == NSURLErrorBadServerResponse) {
            [self.view showTostWithMessage:@"头像修改失败，请稍后再试！"];
        }else
        {
            [self.view showTostWithMessage:@"修改失败，请检查网络！"];
        }
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
