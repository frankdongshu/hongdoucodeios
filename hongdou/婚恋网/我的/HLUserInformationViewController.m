//
//  HLUserInformationViewController.m
//  婚恋网
//
//  Created by iMac on 2019/5/14.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLUserInformationViewController.h"
#import "HLPhotoAlbumTableViewCell.h"
#import "HLEditInfoTableViewCell.h"
#import "HXContextTableViewCell.h"
#import "HLPhotoManageViewController.h"
#import "HLMyVoiceViewController.h"
#import "HLCitySelectorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HLYinXiangViewController.h" // 好友印象
#import "BRPickerView.h"
#import "HLFriendListenTableViewCell.h"


#define NUM @"0123456789"
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


@interface HLUserInformationViewController ()<UITableViewDelegate,UITableViewDataSource,HLPhotoAlbumDeleagte,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>
{
    NSData *_imgeData;
    NSString *currentType;
    NSString *currentUrl;

}

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/
@property (nonatomic, strong) NSArray *userInfoArray;/*用户信息数组*/

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong)HLUser *userInfo;
@property (nonatomic, strong)HLFriendModel *friendModel;

@property (nonatomic, strong) NSArray *keyArry; // 参数key值
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation HLUserInformationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"个人信息";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
//    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"好友印象" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
//        @strongify(self);
//
//        HLYinXiangViewController *yinXiangVC = [[HLYinXiangViewController alloc] init];
//        yinXiangVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:yinXiangVC animated:YES];
//
//    }];
    
    self.userTitleArray = @[@[@""],@[@""],@[@"年龄",@"居住地",@"月收入",@"身高",@"体重",@"学历",@"行业",@"住房",@"车",@"户口",@"籍贯",@"民族",@"毕业院校",@"单位",@"职位",@"婚姻状况",@"子女",@"血型"],@[@"年龄",@"居住地",@"月收入",@"身高",@"学历"]];
    self.keyArry = @[@[@""],@[@"listen"],@[@"age",@"habitation",@"earns",@"height",@"weight",@"education",@"industry",@"housing",@"car",@"registered",@"native",@"nation",@"school",@"company",@"position",@"marital",@"children",@"blood"],@[@"age",@"habitation",@"income",@"height",@"education"]];

    [self creatTableView];
    

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self requestCurrentUserInfo];
    [self requestFriendsUserInfo];
}


- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HLPhotoAlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLPhotoAlbumTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLFriendListenTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFriendListenTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLEditInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLEditInfoTableViewCell"];
    [self.view addSubview:_tableView];
}

// 请求当前用户的信息
- (void)requestCurrentUserInfo{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLGET_UserINFO withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.userInfo = [HLUser mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            
            
            [weakSelf.tableView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"获取个人信息失败"];
    }];
}
// 请求交友的信息
- (void)requestFriendsUserInfo{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLGet_FriendsINFO withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            weakSelf.friendModel = [HLFriendModel mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            
            
            [weakSelf.tableView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"获取个人信息失败"];
    }];
}


#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.userTitleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userTitleArray[section] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        return (kScreenWidth - 48)/4.f+20;
        return 0;
    }else if(indexPath.section == 1){
        return UITableViewAutomaticDimension;
    }else{
        return 53.f;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 33;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    NSArray *array = @[@"名片相册(高质量照片有助于获得更多关注)",@"自我描述",@"基本资料",@"交友条件"];
    NSArray *array = @[@"",@"自我描述",@"基本资料",@"交友条件"];
    return [array objectAtIndex:section];
}
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.backgroundColor = [UIColor lightGrayColor];
////    [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
//    [header.textLabel setFont:[UIFont systemFontOfSize:13]];
//    [header.textLabel setTextColor:[UIColor colorWithHex:0x6175F6]];
//    if (section == 1) {
//        self.editBtn = [[UIButton alloc] initWithFrame:(CGRect)CGRectMake(kScreenWidth - 45, 0, 40, 30)];
//        [header addSubview:self.editBtn];
//        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
////        [self.editBtn setTitle:@"完成" forState:UIControlStateSelected];
//        self.editBtn.selected = NO;
//        self.editBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//        [self.editBtn setTitleColor:[UIColor colorWithHex:0xFF5C79] forState:UIControlStateNormal];
//        [self.editBtn addTarget:self action:@selector(editCellContext:) forControlEvents:UIControlEventTouchUpInside];
//    }
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        
        UIView *view = [[UIView alloc] init];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 70, 30)];
        lab.text = @"倾听我心";
        lab.font = kFontSize(13);
        lab.textColor = [UIColor darkGrayColor];
        
        [view addSubview:lab];
        
        
        
        self.editBtn = [[UIButton alloc] initWithFrame:(CGRect)CGRectMake(kScreenWidth - 45, 0, 40, 30)];
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
//        [self.editBtn setTitle:@"完成" forState:UIControlStateSelected];
        self.editBtn.selected = NO;
        self.editBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.editBtn setTitleColor:[UIColor colorWithHex:0xFF5C79] forState:UIControlStateNormal];
        [self.editBtn addTarget:self action:@selector(editCellContext:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [view addSubview:self.editBtn];
        
        return view;
        
    }
    
    return nil;
}

- (void)editCellContext:(UIButton *)btn{
    self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    HLMyVoiceViewController *myVoiceVC  = [[HLMyVoiceViewController alloc] init];
    myVoiceVC.myVoiceString = self.userInfo.listen;
    myVoiceVC.editVoiceBlock = ^(NSString * _Nonnull voiceStr) {
        if (voiceStr.length <= 0) {
            [self.view showTostWithMessage:@"不能为空"];
        } else {
            [self uploadUserInfoVaule:voiceStr];
        }
        
    };
    [self.navigationController pushViewController:myVoiceVC animated:YES];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HLPhotoAlbumTableViewCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"HLPhotoAlbumTableViewCell"];
        [headCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        headCell.delegate = self;
        headCell.userModel = self.userInfo;
        return headCell;
    }else if(indexPath.section == 1){
//        HXContextTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"HXContextTableViewCell"];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.myVoiceTextView.text = self.userInfo.listen;
//        return cell;
        
        HLFriendListenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLFriendListenTableViewCell"];
        cell.palanceLabel.backgroundColor = [UIColor whiteColor];
        cell.listensLabel.text = [NSString stringWithFormat:@"%@",self.userInfo.listen.length ? self.userInfo.listen : @"快来填写吧~"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }else if(indexPath.section == 2){ // 个人信息
        HLEditInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLEditInfoTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setTitleLableText:self.userTitleArray[indexPath.section][indexPath.row] withHLUserInfo:self.userInfo withCurrentIndex:indexPath];
        return cell;
    }else{ // 交友信息
        HLEditInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLEditInfoTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setFriendTitleLableText:self.userTitleArray[indexPath.section][indexPath.row] withHLUserInfo:self.friendModel withCurrentIndex:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentIndexPath = indexPath;
    if (indexPath.section == 0) {
       // 相册管理
    }else if (indexPath.section == 1){
        //倾听我心
    }else if (indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                {
                    // 年龄不可修改
                }
                break;
            case 1:
            {
                //居住地
                HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
                citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
                    self.friendModel.f_habitation = model.cityName;
                    [self uploadUserInfoVaule:model.cityID];
                };
                [self presentViewController:citySelectVC animated:YES completion:nil];

            }
                break;
            case 2:
            {
                [self requestListWithUrl:HLIncome_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.earns];

            }
                break;
            case 3:
            {
                [self requestListWithUrl:HLHeight_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.height];

            }
                break;
            case 4:
            {
                // 体重

                [self showInputAlterWithTitle:self.userTitleArray[indexPath.section][indexPath.row] withVaule:self.userInfo.weight];
            }
                break;
            case 5:
            {
                //学历
                [self requestListWithUrl:HLEducation_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.education];

            }
                break;
            case 6:
            {
                //行业
                [self requestListWithUrl:HLIndustry_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.industry];
            }
                break;
            case 7:
            {
                //住房
                [self requestListWithUrl:HLHousing_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.housing];
            }
                break;
            case 8:
            {
                //车
                NSArray *arr = @[@"未购",@"已购"];
                
                NSInteger index = [arr indexOfObject:self.userInfo.car];
                
                [BRStringPickerView showPickerWithTitle:@"车" dataSourceArr:@[@"未购",@"已购"] selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                    
                    if ([resultModel.value isEqualToString:@"已购"]) {
                        [self uploadUserInfoVaule:@"1"];
                    } else {
                        [self uploadUserInfoVaule:@"2"];
                    }
                    [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                    
                }];
                
            }
                break;
            case 9:
            {
                //户口
                HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
                citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
                    self.friendModel.f_registered = model.cityName;
                    [self uploadUserInfoVaule:model.cityID];
                };
                
                [self presentViewController:citySelectVC animated:YES completion:nil];
                
            }
                break;
            case 10:
            {
                //籍贯
                HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
                citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
                    self.friendModel.f_habitation = model.cityName;
                    [self uploadUserInfoVaule:model.cityID];
                };
                [self presentViewController:citySelectVC animated:YES completion:nil];
            }
                break;
            case 11:
            {
                //民族
                [self requestListWithUrl:HLNation_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.nation];
            }
                break;
            case 12:
            {
                //毕业院校
                [self showInputAlterWithTitle:self.userTitleArray[indexPath.section][indexPath.row] withVaule:self.userInfo.school];
            }
                break;
            case 13:
            {
                //单位
                [self showInputAlterWithTitle:self.userTitleArray[indexPath.section][indexPath.row] withVaule:self.userInfo.company];

            }
                break;
            case 14:
            {
                //职位
                [self requestListWithUrl:HLPosition_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.position];
            }
                break;
            case 15:
            {
                //婚姻状况
                [self requestListWithUrl:HLMarital_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.marital];
            }
                break;
            case 16:
            {
                //子女
                [self requestListWithUrl:HLChildren_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.children];
            }
                break;
            case 17:
            {
                //血型
                [self requestListWithUrl:HLBlood_List withTitle:@{@"name":self.userTitleArray[indexPath.section][indexPath.row],@"value":@"本科"} withCurrentSelect:self.userInfo.blood];
            }
                break;
            default:
                break;
        }
        
    }else{
        // 编辑交友信息
        switch (indexPath.row) {
            case 0:
            {
                //年龄 段
                [self requesFriendstListWithUrl:HLAge_List withTitle:@"年龄" withCurrentSelect:self.friendModel.f_age];
            }
                break;
            case 1:
            {
                //居住地
                HLCitySelectorViewController *citySelectVC = [[HLCitySelectorViewController alloc] init];
                citySelectVC.selectorCityBlock = ^(HLCityModel * _Nonnull model) {
                    self.friendModel.f_habitation = model.cityName;
                    [self uploadFriendsTypeKey:self.keyArry[indexPath.section][indexPath.row] lowVaule:model.cityID withHigh:nil];
                };
                [self presentViewController:citySelectVC animated:YES completion:nil];
            }
                break;
            case 2:
            {
                //月收入
                [self requestListWithUrl:HLIncome_List withTitle:@{@"name":@"月收入",@"value":@"8000以上"} withCurrentSelect:self.friendModel.f_income];
                
            }
                break;
            case 3:
            {
                //身高 段
                [self requesFriendstListWithUrl:HLHeight_List withTitle:@"身高" withCurrentSelect:self.friendModel.f_height];
                
            }
                break;
            case 4:
            {
                // 学历
                [self requestListWithUrl:HLEducation_List withTitle:@{@"name":@"学历",@"value":@"本科"} withCurrentSelect:self.friendModel.f_education];
            }
                break;
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
            
            NSString *string = [selectTitle isEqualToString:@"不限"]?dic[@"value"]:selectTitle;
            
            NSInteger index = [allVaule indexOfObject:string];
            
            [BRStringPickerView showPickerWithTitle:dic[@"name"] dataSourceArr:allVaule selectIndex:index resultBlock:^(BRResultModel * _Nullable resultModel) {
                            
                for (NSString *key in allDiction.allKeys) {
                    
                    if ([allDiction[key] isEqualToString:resultModel.value]) {
                        
                        if (weakSelf.currentIndexPath.section == 2) {
                            [weakSelf uploadUserInfoVaule:key];
                            
                        } else {
                            [weakSelf uploadFriendsTypeKey:self.keyArry[weakSelf.currentIndexPath.section][weakSelf.currentIndexPath.row] lowVaule:key withHigh:nil];
                        }
                        break;
                    }
                }
                
            }];
            
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


// 上传用户基本信息
- (void)uploadUserInfoVaule:(NSString *)vaule{
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"type":self.keyArry[_currentIndexPath.section][_currentIndexPath.row],
        @"val":vaule
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserModify withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/modify = %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [weakSelf.view hideLoading];
            
            [weakSelf requestCurrentUserInfo];
            [weakSelf requestFriendsUserInfo];

        }
        else {
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

// 请求列表数据
- (void)requesFriendstListWithUrl:(NSString *)url withTitle:(NSString *)title withCurrentSelect:(NSString *)selectTitle{
    
//    NSString *string = @"-";
//    NSRange range = [selectTitle rangeOfString:string];
//
//    NSString *select2 = [selectTitle substringWithRange:NSMakeRange(range.location+1, selectTitle.length-range.location-1)];
//    NSString *select1 = [selectTitle substringWithRange:NSMakeRange(0, range.location)];
    
    NSString *select1 = @"";
    NSString *select2 = @"";

    if (selectTitle.length>0) {
        NSArray *array = [selectTitle componentsSeparatedByString:@"-"]; //从字符-中分隔成2个元素的数组
        select1 = array.firstObject;
        select2 = array.lastObject;
    }

    WeakSelf(weakSelf);
    [HLHTTPSessionManager getDataWithNSString:url withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            NSMutableArray *listArry = [NSMutableArray array];
            listArry = [HLListModel mj_objectArrayWithKeyValuesArray:[dictionary objectForKey:@"data"]];
            NSMutableDictionary *allDiction = [NSMutableDictionary dictionary];
            NSMutableArray *allVaule  = [NSMutableArray array];
            NSMutableArray *allVaule1  = [NSMutableArray array];
            [listArry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HLListModel *model = obj;
                [allDiction setObject:model.name forKey:model.Id];
                [allVaule addObject:model.name];
                [allVaule1 addObject:model.name];

            }];
            
            
            NSInteger index1 = [allVaule indexOfObject:select1];
            NSInteger index2 = [allVaule1 indexOfObject:select2];
            
            
            [BRStringPickerView showMultiPickerWithTitle:title dataSourceArr:@[allVaule,allVaule1] selectIndexs:@[@(index1),@(index2)] resultBlock:^(NSArray<BRResultModel *> * _Nullable resultModelArr) {
               
                NSArray *resultArr = resultModelArr;
          
                BRResultModel *reseult1 = resultArr.firstObject;
                BRResultModel *reseult2 = resultArr.lastObject;
                
                NSString *lowId;
                NSString *highId;
                
                for (NSString *key in allDiction.allKeys) {
                    if ([allDiction[key] isEqualToString:reseult1.value]) {
                        lowId = key;
                        break;
                    }
                }
                for (NSString *key in allDiction.allKeys) {
                    if ([allDiction[key] isEqualToString:reseult2.value]) {
                        highId = key;
                        break;
                    }
                }
                if ([lowId intValue] < [highId intValue]) {
                    [self uploadFriendsTypeKey:weakSelf.keyArry[weakSelf.currentIndexPath.section][weakSelf.currentIndexPath.row] lowVaule:lowId withHigh:highId];
                }else{
                    if ([title isEqualToString:@"年龄"]) {
                        [self.view showTostWithMessage:@"请正确选择年龄段"];
                    } else {
                        [self.view showTostWithMessage:@"请正确选择身高条件"];
                    }
                    
                }
                
            }];
            
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

// 上传修改交友信息
- (void)uploadFriendsTypeKey:(NSString *)type lowVaule:(NSString *)lowVaule withHigh:(NSString *)highVaule{
    
    [self.view showLoading];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setValue:[LoginManager defaultManager].userid forKey:@"uid"];
    [paramDic setValue:type forKey:@"type"];
    if ([type isEqualToString:@"age"] || [type isEqualToString:@"height"]) {
        [paramDic setValue:lowVaule forKey:@"low"];
        [paramDic setValue:highVaule forKey:@"high"];
    }else{
        [paramDic setValue:lowVaule forKey:@"val"];

    }
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_FriendsModify withDictionary:paramDic success:^(NSDictionary * _Nonnull dictionary) {
        [weakSelf.view hideLoading];
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [weakSelf requestFriendsUserInfo];
            
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

#pragma mark 输入弹框
/*
 * 输入弹框弹框
 */
- (void)showInputAlterWithTitle:(NSString *)title withVaule:(NSString *)vaule{
    
    if (self.currentIndexPath.row == 4) {
        title = @"体重（单位kg)";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *userNameTextField = alertController.textFields.firstObject;
        if (self.currentIndexPath.row == 4) {
            
            if (!kISNullString(userNameTextField.text) && [userNameTextField.text intValue] < 201 && [userNameTextField.text intValue] > 30) {
                userNameTextField.text = [NSString stringWithFormat:@"%@kg",userNameTextField.text];
                [self uploadUserInfoVaule:userNameTextField.text];
            }
            else if ([userNameTextField.text intValue] > 201 || [userNameTextField.text intValue] < 30) {
                [self.view showErrorWithMessage:@"请填写正常体重数值!"];
            }
            else {
                [self.view showErrorWithMessage:@"体重数值不可设置为空!"];
            }
            
        } else {
            
            if (userNameTextField.text.length < 1) {
                [self.view showErrorWithMessage:@"不可设置为空!"];
            }
            else {
                [self uploadUserInfoVaule:userNameTextField.text];
            }
            
        }
        
        
    }]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = self;
        
        if (self.currentIndexPath.row == 4) {
            textField.tag = 110;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.text = [vaule substringToIndex:vaule.length-2];
        }
        else if ([title isEqualToString:@"单位"] || [title isEqualToString:@"毕业院校"]) {
            textField.tag = 111;
            textField.text = vaule;
        }
        else {
            textField.text = vaule;
        }
        
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

// 限制输入类型
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 110) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    if (textField.tag == 111) { // 学校名字和单位名字都是限制15字及以下并且不能输入空格
        return current.length <= 15 && ![string isEqualToString:@" "];
    }
    
    return YES;
}



#pragma mark 相片管理代理
// 添加
- (void)photoAddClick:(NSString *)sender{
    self.currentIndexPath  = [NSIndexPath indexPathForRow:0 inSection:0];
    currentType = sender;
    [self indexPathRowModifyUserIcon];
}

- (void)photoDeleteClick:(NSString *)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定删除" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self uplodaPhotoType:sender withValue:@""];
    }]];
    
   
    [self presentViewController:alertController animated:true completion:nil];
    
}



/**
 *  相片修改选择的路径
 */
- (void)indexPathRowModifyUserIcon{
    
//    UIView *view = [self.tableView cellForRowAtIndexPath:_currentIndexPath];
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"添加相片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
        NSData *imageData = UIImageJPEGRepresentation(image,0.5);
        _imgeData = imageData;
        
        [self uploadUserHeaderImage];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    
}
// 上传相片
- (void)uploadUserHeaderImage {
    [self.view showLoading];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    NSData* imageData = _imgeData;
    if (!_imgeData) {
        [self.view showTostWithMessage:@"请选择图片"];
    }else{
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            //
            [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
            
        } success:^(NSDictionary *dictionary) {
            
            NSLog(@"=====名片: %@",dictionary);
            
//            [self.view hideLoading];
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                self->currentUrl =[dictionary objectForKey:@"data"][@"url"];
                
                if (self->currentUrl) {
                    
                    if ([self->currentType isEqualToString:@"one"]) {
                        weakSelf.userInfo.pic_one = self->currentUrl;
                    }else if([self->currentType isEqualToString:@"two"]){
                        weakSelf.userInfo.pic_two = self->currentUrl;

                    }else{
                        weakSelf.userInfo.pic_three = self->currentUrl;
                    }
                    
                    [weakSelf uplodaPhotoType:self->currentType withValue:self->currentUrl];
                    
//                    [weakSelf.tableView reloadRowAtIndexPath:weakSelf.currentIndexPath withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    [weakSelf.view showTostWithMessage:@"上传失败，请稍后再试！"];
                }
            }else
            {
                [weakSelf.view showTostWithMessage:dictionary[@"msg"]];
            }
            
        } failure:^(NSError *error) {
            if (error.code == NSURLErrorBadServerResponse) {
                [weakSelf.view showTostWithMessage:@"上传失败，请稍后再试！"];
            }else
            {
                [weakSelf.view showTostWithMessage:@"上传失败，请检查网络！"];
            }
        }];
    }
    
}
- (void)uplodaPhotoType:(NSString *)type withValue:(NSString *)vaule{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLEdit_UserCard withDictionary:@{@"uid":[LoginManager defaultManager].userid, @"type":type,@"url":vaule} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            if (vaule.length>0) {
                [weakSelf.view showTostWithMessage:@"上传成功"];
            }else{
                [weakSelf.view showTostWithMessage:@"删除成功"];
            }

            
        }else
        {
            [weakSelf.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        [weakSelf requestCurrentUserInfo];
        
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"上传失败，请稍后再试！"];

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



@end
