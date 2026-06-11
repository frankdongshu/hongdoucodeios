//
//  HLFriendBaseInfoViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/21.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFriendBaseInfoViewController.h"
#import "HXContextTableViewCell.h"
#import "HLEditInfoTableViewCell.h"

#import "HLFriendsFactorTableViewCell.h"

@interface HLFriendBaseInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/
@property (nonatomic, strong) NSArray *userInfoArray;/*用户信息数组*/
@property (nonatomic, strong) NSArray *personInfoArray;

@property (nonatomic, strong)HLFriendModel *friendModel;


@end

@implementation HLFriendBaseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = [NSString stringWithFormat:@"%@的资料",self.userInfo.nickname];
    
    self.userTitleArray = @[@[@""],@[@"年龄",@"居住地",@"月收入",@"身高",@"体重",@"学历",@"行业",@"住房",@"车",@"户口",@"籍贯",@"民族",@"毕业院校",@"单位",@"职位",@"婚姻状况",@"子女",@"属相",@"星座",@"血型"],@[@"年龄",@"居住地",@"月收入",@"身高",@"学历"]];
    
    self.personInfoArray = @[
        kISNullString(self.userInfo.age)?@"":self.userInfo.age,
        kISNullString(self.userInfo.habitation)?@"":self.userInfo.habitation,
        kISNullString(self.userInfo.earns)?@"":self.userInfo.earns,
        kISNullString(self.userInfo.height)?@"":self.userInfo.height,
        kISNullString(self.userInfo.weight)?@"":self.userInfo.weight,
        kISNullString(self.userInfo.education)?@"":self.userInfo.education,
        kISNullString(self.userInfo.industry)?@"":self.userInfo.industry,
        kISNullString(self.userInfo.housing)?@"":self.userInfo.housing,
        kISNullString(self.userInfo.car)?@"":self.userInfo.car,
        kISNullString(self.userInfo.registered)?@"":self.userInfo.registered,
        kISNullString(self.userInfo.native)?@"":self.userInfo.native,
        kISNullString(self.userInfo.nation)?@"":self.userInfo.nation,
        kISNullString(self.userInfo.school)?@"":self.userInfo.school,
        kISNullString(self.userInfo.company)?@"":self.userInfo.company,
        kISNullString(self.userInfo.position)?@"":self.userInfo.position,
        kISNullString(self.userInfo.marital)?@"":self.userInfo.marital,
        kISNullString(self.userInfo.children)?@"":self.userInfo.children,
        kISNullString(self.userInfo.animals)?@"":self.userInfo.animals,
        kISNullString(self.userInfo.constellation)?@"":self.userInfo.constellation,
        kISNullString(self.userInfo.blood)?@"":self.userInfo.blood,
    ];
    
    [self creatTableView];
    [self requestFriendsUserInfo];
}

- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.scrollsToTop = NO;
    _tableView.contentInsetTop = 0;
    _tableView.estimatedRowHeight = 48.f;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"HLFriendsFactorTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLFriendsFactorTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLEditInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLEditInfoTableViewCell"];
    [self.view addSubview:_tableView];
}

// 请求交友的信息
- (void)requestFriendsUserInfo{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLNewGet_FriendsINFO withDictionary:@{@"sid":self.userInfo.userid,@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
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
    if(indexPath.section == 0){
        if (kISNullObject(self.userInfo.listen)) {
            return 0.1;
        } else {
            return UITableViewAutomaticDimension;
        }
        
    }
    else if(indexPath.section == 1){
        
        if (kISNullString(self.personInfoArray[indexPath.row])) {
            return 0;
        } else {
            return 48.f;
        }
        
    }
    else{
        return 48.f;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        if (kISNullObject(self.userInfo.listen)) {
            return 0.1;
        } else {
            return 33;
        }
    }
    
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSArray *array = @[kISNullObject(self.userInfo.listen)?@"":@"倾听我心",@"基本资料",@"交友条件"];
    
    UIView *view = [[UIView alloc] init];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 33)];
    lab.text = array[section];
    [lab setFont:[UIFont systemFontOfSize:13]];
    [lab setTextColor:[UIColor colorWithHex:0x6175F6]];
    [view addSubview:lab];
    
    return view;
    
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSArray *array = @[@"倾听我心",@"基本资料",@"交友条件"];
//    return [array objectAtIndex:section];
//}
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.backgroundColor = [UIColor whiteColor];
//    [header.textLabel setFont:[UIFont systemFontOfSize:13]];
//    [header.textLabel setTextColor:[UIColor colorWithHex:0x6175F6]];
//
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HLFriendsFactorTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"HLFriendsFactorTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.factorLabel.text = self.userInfo.listen;
        return cell;
    }else if(indexPath.section == 1){
        HLEditInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLEditInfoTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBaseinfoText:self.userTitleArray[indexPath.section][indexPath.row] withHLUserInfo:self.userInfo withCurrentIndex:indexPath];
        
        if (kISNullString(self.personInfoArray[indexPath.row])) {
            cell.titleLable.text = @"";
        } else {
            cell.titleLable.text = self.userTitleArray[indexPath.section][indexPath.row];
        }
        
        return cell;
    }
//    else if(indexPath.section == 2){ // 详细资料
//        HLEditInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLEditInfoTableViewCell"];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        [cell setBaseinfoText:self.userTitleArray[indexPath.section][indexPath.row] withHLUserInfo:self.userInfo withCurrentIndex:indexPath];
//        return cell;
//    }
    else{
        HLEditInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLEditInfoTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.nextImageView.hidden = YES;
        [cell setFriendTitleLableText:self.userTitleArray[indexPath.section][indexPath.row] withHLUserInfo:self.friendModel withCurrentIndex:indexPath];
        return cell;
    }
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
