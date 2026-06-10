//
//  CSPersonInfoController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSPersonInfoController.h"
#import "EducationView.h" // 最高学历
#import "AptitudeView.h" // 教学经验
#import "IdentityView.h" // 教师身份
#import "CSEditNameViewController.h" // 编辑界面
#import "CSDescriptionController.h" // 个人介绍编辑界面
#import "CSHeaderViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "MultipleImgCell.h" // 底部多图上传Cell
#import "CSProjectTypeController.h" // 咨询项目类型
#import "CSHomeCityViewController.h" // 城市列表
#import "LLTeachingMethodController.h" // 授课方式
#import "LLTeachingPriceController.h" // 课时费设置

@interface CSPersonInfoController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) EducationView *eduView;

@end

@implementation CSPersonInfoController

// 禁用侧滑返回手势
- (void)forbiddenGesture {
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self forbiddenGesture];
    
    self.sc_navigationBar.title = @"个人信息";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.login == LoginYes) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [JMSGUser logout:^(id resultObject, NSError *error) {
                if (!error) {
                    NSLog(@"resultObject: %@",resultObject);
                } else {
                    NSLog(@"error: %@",error);
                }
            }];
            [MyLogin logOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }];
    
    if (self.login == LoginNo) {
        self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"下一步" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            
            [self requestIsMust];
            
//            MyLogin *u = [MyLogin getCurrentLoginUser];
//
//            if (kISNullObject(u.head) ||
//                kISNullObject(u.education) ||
//                kISNullObject(u.school) ||
//                kISNullObject(u.major) ||
//                kISNullObject(u.papers) ||
//                (kISNullObject(u.wx) && kISNullObject(u.qq) && kISNullObject(u.contact))) {
//                [self.view showTostWithMessage:@"请完善资料"];
//            } else {
//                CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
            
        }];
    }
    
    self.titleArray = @[@"头像占位",@"昵称",@"性别",@"出生日期",@"教师身份",@"教学经验",@"最高学历",@"毕业院校",@"专业",@"所在城市",@"自我介绍",@"授课区域",@"授课方式",@"授课费用",@"联系方式",@"微信:",@"QQ:",@"电话:",@"占位"];
    
    [self.view addSubview:self.tableView];
    
    // 去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

#pragma mark - tableView 初始化
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 95;
    }
    if (indexPath.row == self.titleArray.count-1) {
        return 380;
    }
    return 44;
}

#pragma mark - cellForRowAtIndexPath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        CSHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSHeaderViewCell"];
        
        if (!cell) {
            NSArray * nib = [[NSBundle mainBundle] loadNibNamed:@"CSHeaderViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *headString = kISNullObject([MyLogin getCurrentLoginUser].head)?@"":[MyLogin getCurrentLoginUser].head;
        
        [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:headString] placeholderImage:[UIImage imageNamed:@"cer_person_no"]];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
        
        return cell;
    }
    else if (indexPath.row == self.titleArray.count-1) {
        
        MultipleImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultipleImageCell"];
        
        if (!cell) {
            cell = [[MultipleImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MultipleImageCell"];
        }
        
        cell.pictures = [MyLogin getCurrentLoginUser].papers;
        
        // 选择图片控制器
        cell.block = ^(UIViewController *vc) {
            [self presentViewController:vc animated:YES completion:nil];
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuse"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = kFontSize(15);
        cell.detailTextLabel.font = kFontSize(14);
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        cell.textLabel.text = self.titleArray[indexPath.row];
        switch (indexPath.row) {
            case 1: // 昵称
                cell.detailTextLabel.text = [MyLogin getCurrentLoginUser].nickname;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].nickname)?[UIColor darkGrayColor]:REDColor;
                break;
            case 2: // 性别
                cell.detailTextLabel.text = [MyLogin getCurrentLoginUser].sex;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].sex)?[UIColor darkGrayColor]:REDColor;
                break;
            case 3: // 出生日期
                cell.detailTextLabel.text = [MyLogin getCurrentLoginUser].birthday;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].birthday)?[UIColor darkGrayColor]:REDColor;
                break;
            case 4: // 教师身份
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].identity)?@"未选择":[MyLogin getCurrentLoginUser].identity;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].identity)?[UIColor darkGrayColor]:REDColor;
                break;
            case 5: // 教学经验
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].intelligence)?@"未选择":[MyLogin getCurrentLoginUser].intelligence;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].intelligence)?[UIColor darkGrayColor]:REDColor;
                break;
            case 6: // 最高学历
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].education)?@"未选择":[MyLogin getCurrentLoginUser].education;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].education)?[UIColor darkGrayColor]:REDColor;
                break;
            case 7: // 毕业院校
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].school)?@"请填写院校":[MyLogin getCurrentLoginUser].school;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].school)?[UIColor darkGrayColor]:REDColor;
                break;
            case 8: // 专业
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].major)?@"请填写专业":[MyLogin getCurrentLoginUser].major;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].major)?[UIColor darkGrayColor]:REDColor;
                break;
            case 9: // 所在城市
                cell.detailTextLabel.text = [MyLogin getCurrentLoginUser].city;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].city)?[UIColor darkGrayColor]:REDColor;
                break;
            case 10: // 自我介绍
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].descr)?@"请填写自我介绍":[MyLogin getCurrentLoginUser].descr;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].descr)?[UIColor darkGrayColor]:REDColor;
                break;
            case 11: // 授课区域
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].motto)?@"请填写授课区域":[MyLogin getCurrentLoginUser].motto;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].motto)?[UIColor darkGrayColor]:REDColor;
                break;
            case 12: // 授课方式
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].teaching)?@"未选择":[MyLogin getCurrentLoginUser].teaching;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].teaching)?[UIColor darkGrayColor]:REDColor;
                break;
            case 13: // 授课费用(成对出现, 判断一个即可)
                
                cell.detailTextLabel.text = [[NSString stringWithFormat:@"%@",[MyLogin getCurrentLoginUser].cost_low] isEqualToString:@"0"] || kISNullObject([MyLogin getCurrentLoginUser].cost_low)?@"请填写授课费用":[NSString stringWithFormat:@"%@-%@/小时",[MyLogin getCurrentLoginUser].cost_low,[MyLogin getCurrentLoginUser].cost_high];
                
                cell.detailTextLabel.textColor = [[NSString stringWithFormat:@"%@",[MyLogin getCurrentLoginUser].cost_low] isEqualToString:@"0"] || kISNullObject([MyLogin getCurrentLoginUser].cost_low)?[UIColor darkGrayColor]:REDColor;
                break;
            case 15: // 微信
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].wx)?@"请填写正确微信号":[MyLogin getCurrentLoginUser].wx;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].wx)?[UIColor darkGrayColor]:REDColor;
                break;
            case 16: // QQ
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].qq)?@"请填写正确QQ号":[MyLogin getCurrentLoginUser].qq;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].qq)?[UIColor darkGrayColor]:REDColor;
                break;
            case 17: // 电话
                cell.detailTextLabel.text = kISNullObject([MyLogin getCurrentLoginUser].contact)?@"请填写正确电话号":[MyLogin getCurrentLoginUser].contact;
                cell.detailTextLabel.textColor = kISNullObject([MyLogin getCurrentLoginUser].contact)?[UIColor darkGrayColor]:REDColor;
                break;
                
            default:
                break;
        }
        
        // 针对联系方式部分
        if (indexPath.row != 14) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
        }
        
        if (indexPath.row == 14 || indexPath.row == 15 || indexPath.row == 16) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
        }
        
        return cell;
        
    }
    
}

#pragma mark - tableView, didSelectRowAtIndexPath
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cameraAlertController];
        });
        
    }
    if (indexPath.row == 1) { // 昵称
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = self.titleArray[indexPath.row];
        vc.pageType = NickNamePage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 4) { // 教师身份
        IdentityView *view = [[IdentityView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andSelectString:[MyLogin getCurrentLoginUser].identity];
        view.sureBlock = ^{
            [self.tableView reloadData];
        };
        [view showSelf];
    }
    if (indexPath.row == 5) { // 教学经验
        AptitudeView *view = [[AptitudeView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        view.sureBlock = ^{
            [self.tableView reloadData];
        };
        [view showSelf];
    }
    if (indexPath.row == 6) { // 最高学历
        EducationView *eduView = [[EducationView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        eduView.sureBlock = ^{
            [self.tableView reloadData];
        };
        [eduView showSelf];
    }
    if (indexPath.row == 7) { // 毕业院校
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = self.titleArray[indexPath.row];
        vc.pageType = SchoolPage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 8) { // 专业
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = self.titleArray[indexPath.row];
        vc.pageType = MajorPage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 9) { // 城市
        
        if (self.login == LoginYes) {
            CSHomeCityViewController *vc = [[CSHomeCityViewController alloc]init];
            vc.cityType = CityYes;
            vc.sureBlock = ^{
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    if (indexPath.row == 10) { // 自我介绍
        CSDescriptionController *vc = [[CSDescriptionController alloc] init];
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 11) { // 授课区域
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = self.titleArray[indexPath.row];
        vc.pageType = AphorismPage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 12) { // 授课方式
        
        [self requestTeachingMethodList];
        
    }
    if (indexPath.row == 13) { // 授课费用
        LLTeachingPriceController *vc = [[LLTeachingPriceController alloc] init];
        
        BOOL isFromValue = [[NSString stringWithFormat:@"%@",[MyLogin getCurrentLoginUser].cost_low] isEqualToString:@"0"] || kISNullObject([MyLogin getCurrentLoginUser].cost_low);
        
        BOOL isToValue = [[NSString stringWithFormat:@"%@",[MyLogin getCurrentLoginUser].cost_high] isEqualToString:@"0"] || kISNullObject([MyLogin getCurrentLoginUser].cost_high);
        
        vc.fromString = isFromValue ? @"":[NSString stringWithFormat:@"%@",[MyLogin getCurrentLoginUser].cost_low];
        vc.toString = isToValue ? @"":[NSString stringWithFormat:@"%@",[MyLogin getCurrentLoginUser].cost_high];
        
        
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 15) { // 微信
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = @"正确微信号";
        vc.pageType = WeChatPage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 16) { // QQ
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = @"正确QQ号";
        vc.pageType = QQPage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (indexPath.row == 17) { // 电话
        CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
        vc.titleString = @"正确电话号";
        vc.pageType = PhonePage;
        vc.sureBlock = ^{
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
#pragma mark - 选择头像, 底部弹出选择
- (void)cameraAlertController {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"修改头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        
    }];
    UIAlertAction *photoesAlbum = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [self.view showTostWithMessage:@"应用相册权限受限，请在设置中启用"];
            return;
        }else{
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //设置字体颜色
    [cameraAction setValue:REDColor forKey:@"titleTextColor"];
    [photoesAlbum setValue:REDColor forKey:@"titleTextColor"];
    [cancelAct setValue:[UIColor darkGrayColor] forKey:@"titleTextColor"];
    
    //把action添加到actionSheet里
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:photoesAlbum];
    [actionSheet addAction:cancelAct];

    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = nil;
        if (picker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }else{
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        // 修改头像
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        [self uploadHeadImage:imageData];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}
#pragma mark - 上传图片, 获取URL
- (void)uploadHeadImage:(NSData *)imagData {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    [HTTPSessionManger postDataWithNSString:@"/user/upload" withDictionary:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imagData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
        
    } success:^(NSDictionary * _Nonnull dictionary) {

        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.head = dictionary[@"data"][@"url"];
            [MyLogin updateUser:u];
            
            [self updateHeadImg];
            
        } else {
            
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}
#pragma mark - 调取接口, 设置头像
- (void)updateHeadImg {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"head":[MyLogin getCurrentLoginUser].head
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/head" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.tableView reloadData];
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {

    }];
    
}

#pragma mark - 是否必填全部上传

- (void)requestIsMust {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/must" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            if (kISNullObject([MyLogin getCurrentLoginUser].curriculum)) {
                CSProjectTypeController *vc = [[CSProjectTypeController alloc] init];
                vc.projType = TypeNo;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:@"请求失败"];

    }];
    
}

#pragma mark - 授课方式列表

- (void)requestTeachingMethodList {
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/get_teaching_list" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            LLTeachingMethodController *vc = [[LLTeachingMethodController alloc] init];
            vc.dataArray = [[NSMutableArray alloc] initWithArray:[[MyLogin getCurrentLoginUser].teaching componentsSeparatedByString:@","]];
            
            vc.listArray = dictionary[@"data"];
            
            vc.sureBlock = ^{    
                [self.tableView reloadData];
            };
            
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:@"请求失败"];

    }];
    
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
