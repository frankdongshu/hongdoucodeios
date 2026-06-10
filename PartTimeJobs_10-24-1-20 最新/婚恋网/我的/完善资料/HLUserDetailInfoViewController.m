//
//  HLUserDetailInfoViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/29.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLUserDetailInfoViewController.h"
#import "HXuserDetailHeaderTableViewCell.h"
#import "HXUserDetailTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "HLUpdateNicknameViewController.h"
#import "HLListModel.h"
#import "HLCitySelectorViewController.h"
#import "NSObject+BKBlockExecution.h"

#import "HLLoginViewController.h"
#import "HLRegisterViewController.h"

#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface HLUserDetailInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    NSData *_imgeData;
    BOOL ifUpdatePrefect; // 是否更新完信息

}
@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/
@property (nonatomic, strong) NSArray *userHintArray;/*用户提示数组*/


@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic,strong) HLUser *userInfo;

@property (nonatomic, strong) NSMutableDictionary *paramDic; // 修改信息参数参数
@property (nonatomic, strong) NSMutableDictionary *uploadInfoDic; // 上传修改参数

@property (nonatomic, strong) NSArray *keyArry; // 参数key值

// 列表数组
@property (nonatomic, strong) NSMutableArray *home_list;
@property (nonatomic, strong) NSMutableArray *education_list;
@property (nonatomic, strong) NSMutableArray *height_list;
@property (nonatomic, strong) NSMutableArray *income_list;

@property (nonatomic, strong) HXBarButtonItem *leftBarItem;
@property (nonatomic, strong) HXBarButtonItem *rightBarItem;


@end

@implementation HLUserDetailInfoViewController

- (void)loadView {
    [super loadView];
    
    ifUpdatePrefect = NO;
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if (self->ifUpdatePrefect) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.view showTostWithMessage:@"请完善个人信息"];
        }
    }];
    
    self.rightBarItem = [[HXBarButtonItem alloc] initWithTitle:@"退出" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        // 退出登录
        [[LoginManager defaultManager] doLogout];
        
        if ([[[self backViewController] class] isEqual:[HLRegisterViewController class]] || [[[self backViewController] class] isEqual:[HLLoginViewController class]]) {
         
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            
            HLLoginViewController *loginVC = [[HLLoginViewController alloc] init];
            HXNavigationController *nvc = [[HXNavigationController alloc] initWithRootViewController:loginVC];
            nvc.modalPresentationStyle = 0;
            [self presentViewController:nvc animated:YES completion:^{
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }];
            
        }
        
    }];
    
}

- (UIViewController *)backViewController {

    NSInteger myIndex = [self.navigationController.viewControllers indexOfObject:self];
    
    if(myIndex!=0 && myIndex!=NSNotFound) {
        return [self.navigationController.viewControllers objectAtIndex:myIndex-1];
    } else {
        return nil;
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.sc_navigationBar.title = @"完善信息";
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationBar.rightBarButtonItem = self.rightBarItem;
    self.userTitleArray = @[@"昵称",@"性别",@"出生日期",@"居住地",@"输入推荐人推荐码"];
    self.userHintArray =  @[@"",@"(不可更改)",@"(不可更改)",@"",@"",@"",@"",@"(选填)"];

    self.keyArry = @[@"nickname",@"gender",@"birthday",@"habitation",@"recommend"];
    
    self.paramDic = [NSMutableDictionary dictionary];
    self.uploadInfoDic = [NSMutableDictionary dictionary];
    self.education_list = [NSMutableArray array];
    self.height_list = [NSMutableArray array];
    self.income_list = [NSMutableArray array];
    
    self.userInfo = [[HLUser alloc] init];
    [self creatTableView];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //禁用全局滑动手势

    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = NO;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //开启全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = YES;
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    //    _tableView.allowsSelection = NO;
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HXuserDetailHeaderTableViewCell" bundle:nil] forCellReuseIdentifier:@"HXuserDetailHeaderTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HXUserDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"HXUserDetailTableViewCell"];
    [self.view addSubview:_tableView];
}


#pragma delegate
- (void)pushyUserDetailAction{
    
}

#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return [self.userTitleArray count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 120;
    }else{
        return 48.f;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HXuserDetailHeaderTableViewCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"HXuserDetailHeaderTableViewCell"];
//        [headCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        headCell.alterHeadBlock = ^{
            
        };
        return headCell;
    }else{
        HXUserDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HXUserDetailTableViewCell"];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSString *content = self.paramDic[self.keyArry[indexPath.row]];
        if (!content) {
            if (indexPath.row == 0 || indexPath.row ==7) {
                content = @"填写";
            }else{
                content = @"选择";
            }
        }
        [cell setCellTitle:self.userTitleArray[indexPath.row] withprompt:self.userHintArray[indexPath.row] withContent:content];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _currentIndexPath = indexPath;
    if (indexPath.section==0) {
        [self indexPathRowModifyUserIcon];
    }else{
        switch (indexPath.row) {
            case 0:
            {
                [self showInputAlterWithTitle:@"请输入昵称"];
            }
                break;
            case 1:
            {
                //性别
//                [BRStringPickerView showStringPickerWithTitle:@"性别" dataSource:@[@"男", @"女"] defaultSelValue:@"" resultBlock:^(id selectValue) {
//                    [self.paramDic setValue:selectValue forKey:self.keyArry[indexPath.row]];
//                    if ([selectValue isEqualToString:@"男"]) {
//                        [self.uploadInfoDic setValue:@"1" forKey:self.keyArry[indexPath.row]];
//                    }else{
//                        [self.uploadInfoDic setValue:@"2" forKey:self.keyArry[indexPath.row]];
//                    }
//                    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
//                }];
                NSArray *arr = @[@"男", @"女"];
                NSInteger index;
                if (self.paramDic.count > 0) {
                    index = [arr indexOfObject:self.paramDic[self.keyArry[indexPath.row]]];
                }else{
                    index = 0;
                }
//                NSInteger index = [arr indexOfObject:self.paramDic[self.keyArry[indexPath.row]]];
                
                [BRStringPickerView showPickerWithTitle:@"性别" dataSourceArr:@[@"男", @"女"] selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                    
                    [self.paramDic setValue:resultModel.value forKey:self.keyArry[indexPath.row]];
                    if ([resultModel.value isEqualToString:@"男"]) {
                        [self.uploadInfoDic setValue:@"1" forKey:self.keyArry[indexPath.row]];
                    } else {
                        [self.uploadInfoDic setValue:@"2" forKey:self.keyArry[indexPath.row]];
                    }
                    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                    
                }];
            }
                break;
            case 2:
            {
                // 出生日期
            
                NSDate *minDate = [NSDate br_setYear:1929 month:01 day:01];
                NSDate *maxDate = [NSDate br_setYear:2009 month:12 day:31];
                
                NSString *selectDate = self.paramDic[@"birthday"] ? self.paramDic[@"birthday"] : @"1985-01-01";
                
                [BRDatePickerView showDatePickerWithMode:BRDatePickerModeYMD title:@"出生日期" selectValue:selectDate minDate:minDate maxDate:maxDate isAutoSelect:NO resultBlock:^(NSDate * _Nullable selectDate, NSString * _Nullable selectValue) {
                    
                    [self.paramDic setValue:selectValue forKey:self.keyArry[indexPath.row]];
                    
                    
                    [self.uploadInfoDic setValue:selectValue forKey:self.keyArry[indexPath.row]];
                    
                    [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                    
                }];
//                NSDate *minDate = [NSDate br_setYear:1929 month:01 day:01];
//                NSDate *maxDate = [NSDate br_setYear:2009 month:12 day:31];
//                [BRDatePickerView showDatePickerWithTitle:@"出生日期" dateType:BRDatePickerModeYMD defaultSelValue:self.paramDic[@"birthday"] ? self.paramDic[@"birthday"] : @"1985-01-01" minDate:minDate maxDate:maxDate isAutoSelect:NO themeColor:nil resultBlock:^(NSString *selectValue) {
//                    [self.paramDic setValue:selectValue forKey:self.keyArry[indexPath.row]];
//                    NSLog(@"___%@",[NSDate br_getDate:selectValue format:@"yyyy-MM-dd"]);
//                    [self.uploadInfoDic setValue:[NSDate br_getDate:selectValue format:@"yyyy-MM-dd"] forKey:self.keyArry[indexPath.row]];
//
//                    [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
//
//                } cancelBlock:^{
//                    NSLog(@"点击了背景或取消按钮");
//                }];
            }
                break;
            case 3:
            {
                //居住地
                HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
                citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
                    [self.paramDic setValue:model.cityName forKey:self.keyArry[indexPath.row]];
                    [self.uploadInfoDic setValue:model.cityID forKey:self.keyArry[indexPath.row]];
                    [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];

                };
                [self presentViewController:citySelectVC animated:YES completion:nil];
                
            }
                break;
//            case 4:
//            {
//                //学历
//
//                [self requestListWithUrl:HLEducation_List withTitle:@{@"name":@"学历",@"value":@"本科"} withCurrentSelect:self.paramDic[self.keyArry[indexPath.row]]];
//
//            }
//                break;
//            case 5:
//            {
//                // 身高
//                 [self requestListWithUrl:HLHeight_List withTitle:@{@"name":@"身高",@"value":@"170cm"} withCurrentSelect:self.paramDic[self.keyArry[indexPath.row]]];
//
//            }
//                break;
//            case 6:
//            {
//                // 月收入
//                 [self requestListWithUrl:HLIncome_List withTitle:@{@"name":@"月收入",@"value":@"8000以上"} withCurrentSelect:self.paramDic[self.keyArry[indexPath.row]]];
//            }
//                break;
            case 4:
            {
                // 推荐码
                [self showInputAlterWithTitle:@"请输入推荐码"];
            }
            default:
                break;
        }
    }
}

#pragma mark 请求类表信息
// 请求 列表数据
- (void)requestListWithUrl:(NSString *)url withTitle:(NSDictionary *)dic withCurrentSelect:(NSString *)selectTitle{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager getDataWithNSString:url withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            NSMutableArray *listArry = [NSMutableArray array];
            listArry = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            NSMutableDictionary *allDiction = [NSMutableDictionary dictionary];
            NSMutableArray *allVaule  = [NSMutableArray array];
            [listArry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HLListModel *model = obj;
                [allDiction setObject:model.name forKey:model.Id];
                [allVaule addObject:model.name];
            }];
            [BRStringPickerView showMultiPickerWithTitle:dic[@"name"] dataSourceArr:allVaule selectIndexs:kISNullString(selectTitle)?dic[@"value"]:selectTitle resultBlock:^(id selectValue) {
                for (NSString *key in allDiction.allKeys) {
                    if ([allDiction[key] isEqualToString:selectValue]) {
                         [self.uploadInfoDic setValue:key forKey:self.keyArry[weakSelf.currentIndexPath.row]];
                        break;
                    }
                }
               
                [self.paramDic setValue:selectValue forKey:self.keyArry[weakSelf.currentIndexPath.row]];
                [weakSelf.tableView reloadRowAtIndexPath:weakSelf.currentIndexPath withRowAnimation:UITableViewRowAnimationNone];
            }];
//            [BRStringPickerView showStringPickerWithTitle:dic[@"name"] dataSource:allVaule defaultSelValue:kISNullString(selectTitle)?dic[@"value"]:selectTitle resultBlock:^(id selectValue) {
//                for (NSString *key in allDiction.allKeys) {
//                    if ([allDiction[key] isEqualToString:selectValue]) {
//                         [self.uploadInfoDic setValue:key forKey:self.keyArry[weakSelf.currentIndexPath.row]];
//                        break;
//                    }
//                }
//               
//                [self.paramDic setValue:selectValue forKey:self.keyArry[weakSelf.currentIndexPath.row]];
//                [weakSelf.tableView reloadRowAtIndexPath:weakSelf.currentIndexPath withRowAnimation:UITableViewRowAnimationNone];
//            }];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView *view = [UIView new];
        // 确认修改按钮
        UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 8, kScreenWidth - 30 , 44)];
        [updateBtn setTitle:@"确认" forState:UIControlStateNormal];
        [updateBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        updateBtn.layer.cornerRadius = 22.f;
        updateBtn.layer.masksToBounds = YES;
        [updateBtn addTarget:self action:@selector(uploadBaseInfo) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:updateBtn];
        view.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
        return view;
    }
    return [[UIView alloc] init];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 60;
    }
    return 0.01;
}

// 上传基本用户信息
- (void)uploadBaseInfo{
    
    if ([self.uploadInfoDic allKeys].count == 0) {
        [self.view showTostWithMessage:@"请完善个人信息"];
        return;
    }
    if (!self.uploadInfoDic[@"head"]) {
        [self.view showTostWithMessage:@"请完善个人信息"];
        return;
    }
    
    // 获取选取得年份
    NSString *dateString = self.paramDic[self.keyArry[2]];
    NSString *yearString = [dateString substringWithRange:NSMakeRange(0, 4)];
    
    // 获取当前年份
    NSDate *senddate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];
    NSString *thisYearString = [dateformatter stringFromDate:senddate];
    
    if ([thisYearString intValue]-[yearString intValue] < 18) {
        [self.view showTostWithMessage:@"未满18岁不能注册"];
        return;
    }
    
    for (NSString *keys in self.keyArry) {
        if (!self.uploadInfoDic[keys] && ![keys isEqualToString:@"recommend"]) {
            [self.view showTostWithMessage:@"请完善个人信息"];
            return;
        }
    }
    
    [self.uploadInfoDic setValue:[LoginManager defaultManager].userid forKey:@"uid"];
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserEVPI withDictionary:self.uploadInfoDic success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->ifUpdatePrefect = YES;
            
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [MBProgressHUD showSuccess:dictionary[@"msg"] toView:app.window];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateImageOrNickname object:nil];
            // 通知相对界面需要刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:@"修改失败，请重新点击确认按钮！"];

    }];
}


/**
 *  头像修改选择的路径
 */
- (void)indexPathRowModifyUserIcon{
    
    UIView *view = [self.tableView cellForRowAtIndexPath:_currentIndexPath];
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"修改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    alertViewController.modalInPopover = YES;
    alertViewController.modalPresentationStyle = UIModalPresentationPopover;
    
    __weak typeof(self) weakSelf = self;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
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
    alertViewController.popoverPresentationController.sourceView = view;
    alertViewController.popoverPresentationController.sourceRect = view.frame;
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
//       newImage = [self circleImage:newImage witghParam:0];

        
        
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
            //
            [self.view hideLoading];

            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                [self.uploadInfoDic setValue:[dictionary objectForKey:@"data"][@"url"] forKey:@"head"];
                [[LoginManager defaultManager] setAvatar:[dictionary objectForKey:@"data"][@"url"]];
                HXuserDetailHeaderTableViewCell *headerCell = (HXuserDetailHeaderTableViewCell *)[self.tableView cellForRowAtIndexPath:weakSelf.currentIndexPath];
                [headerCell.headerImageView sd_setImageWithURL:[NSURL URLWithString:self.uploadInfoDic[@"head"]] placeholderImage:[UIImage imageNamed:@"icon_head"]];
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
 * 输入弹框弹框
 */
- (void)showInputAlterWithTitle:(NSString *)title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *userNameTextField = alertController.textFields.firstObject;
        NSLog(@"昵称 = %@",userNameTextField.text);
        [self.paramDic setObject:kISNullString(userNameTextField.text) ? @"填写" : userNameTextField.text forKey:self.keyArry[self.currentIndexPath.row]];
        [self.uploadInfoDic setObject:kISNullString(userNameTextField.text) ? @"" : userNameTextField.text forKey:self.keyArry[self.currentIndexPath.row]];
        [self.tableView reloadRowAtIndexPath:self.currentIndexPath withRowAnimation:UITableViewRowAnimationNone];

    }]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = title;
        textField.delegate = self;
        textField.tag = 250;
        
        if (![[NSString stringWithFormat:@"%@",self.paramDic[self.keyArry[self.currentIndexPath.row]]] isEqualToString:@"填写"]) {
            textField.text = self.paramDic[self.keyArry[self.currentIndexPath.row]];
        } else {
            textField.text = @"";
        }
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

// 限制输入字母和数字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 250) {
        // 获取当前文本内
        NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // 限制昵称最多9个字符
        return current.length <= 9;
    }
    
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}


@end
