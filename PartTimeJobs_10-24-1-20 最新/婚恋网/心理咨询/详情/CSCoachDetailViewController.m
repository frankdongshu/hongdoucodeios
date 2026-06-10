//
//  CSCoachDetailViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSCoachDetailViewController.h"
#import "CoachHeadCell.h"
#import "CSEducationDetailCell.h"
#import "CSHomeTableViewCell.h"
#import "CSDetailContactCell.h" // 联系方式
#import "CSCoachDetailDescriptCell.h"
#import "MultipleImgCell.h"
#import "HLNewChatViewController.h"
#import "LLSelectAlertView.h"
#import "FKGPopOption.h"
#import "HLComplaintViewController.h"

#import "CLAmplifyView.h"

@interface CSCoachDetailViewController ()<UITableViewDelegate, UITableViewDataSource, CoachHeadCellDeleagte>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *dictemp;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *followBtn;
@property (nonatomic, strong) UIButton *chatBtn;

@end

@implementation CSCoachDetailViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.isApp == HongApp?kScreenHeight-kTabBarHeight:kScreenHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 100.0f;
        
        [_tableView registerNib:[UINib nibWithNibName:@"CoachHeadCell" bundle:nil] forCellReuseIdentifier:@"CoachHeadCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"CSEducationDetailCell" bundle:nil] forCellReuseIdentifier:@"CSEducationDetailCell"];
        [_tableView registerClass:[CSHomeTableViewCell class] forCellReuseIdentifier:@"CSHomeTableViewCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"CSDetailContactCell" bundle:nil] forCellReuseIdentifier:@"CSDetailContactCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"CSCoachDetailDescriptCell" bundle:nil] forCellReuseIdentifier:@"CSCoachDetailDescriptCell"];
        [_tableView registerClass:[MultipleImgCell class] forCellReuseIdentifier:@"MultipleImgCell"];
        
        if(@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
        
    }
    return _tableView;
}

// 分区个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

// 每个区的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// 页眉高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.01;
    }
    if (section == 3) {
        if (kISNullObject(self.model.motto)) {
            return 0.01;
        } else {
            return 50;
        }
    }
    if (section == 4) {
        if (kISNullObject(self.model.teaching)) {
            return 0.01;
        } else {
            return 50;
        }
    }
    if (section == 5) {
        if ([[NSString stringWithFormat:@"%@",self.model.cost_low] isEqualToString:@"0"]) {
            return 0.01;
        } else {
            return 50;
        }
    }
    if (section == 6) {
        if (kISNullObject(self.model.qq) && kISNullObject(self.model.wx) && kISNullObject(self.model.contact)) {
            return 0.01;
        } else {
            return 50;
        }
    }
    if (section == 8) {
        if (kISNullObject(self.model.papers)) {
            return 0.01;
        } else {
            return 50;
        }
    }
    return 50;
}
// 页眉
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 50)];
    lab.textColor = kRGBA(51, 51, 51, 1);
    lab.font = kFontSize(16);
    
    if (section == 1) {
        lab.text = [NSString stringWithFormat:@"%@\t%@经验",self.model.identity,self.model.intelligence];
    } else if (section == 2) {
        lab.text = @"擅长领域";
    } else if (section == 3) {
        if (kISNullObject(self.model.motto)) {
            lab.text = @"";
        } else {
            lab.text = @"授课区域";
        }
    } else if (section == 4) {
        if (kISNullObject(self.model.teaching)) {
            lab.text = @"";
        } else {
            lab.text = @"授课方式";
        }
    } else if (section == 5) {
        if ([[NSString stringWithFormat:@"%@",self.model.cost_low] isEqualToString:@"0"]) {
            lab.text = @"";
        } else {
            lab.text = @"授课费用";
        }
    } else if (section == 6) {
        if (kISNullObject(self.model.qq) && kISNullObject(self.model.wx) && kISNullObject(self.model.contact)) {
            lab.text = @"";
        } else {
            lab.text = @"联系方式";
        }
    } else if (section == 7) {
        
        lab.text = @"个人介绍";
        
    } else if (section == 8) {
        
        if (kISNullObject(self.model.papers)) {
            lab.text = @"";
        } else {
            lab.text = @"证书公示";
        }
        
    }
    
    [view addSubview:lab];
    
    return view;
}

// 页脚高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) { // 擅长领域
        CGFloat height ;
        NSInteger rowww = self.model.curriculum.count / 3;
        if (self.model.curriculum.count % 3 == 0) {
            height = rowww *30 + (rowww - 1)*20;
        } else {
            height = (rowww + 1) *30 + (rowww)*20;
            
        }
        return  height;
    }
    if (indexPath.section == 3) { // 授课区域
        if (kISNullObject(self.model.motto)) {
            return 0;
        } else {
            return UITableViewAutomaticDimension;
        }
    }
    if (indexPath.section == 4) { // 授课方式
        if (kISNullObject(self.model.teaching)) {
            return 0;
        } else {
            return UITableViewAutomaticDimension;
        }
    }
    if (indexPath.section == 5) { // 授课费用
        if ([[NSString stringWithFormat:@"%@",self.model.cost_low] isEqualToString:@"0"]) {
            return 0;
        } else {
            return UITableViewAutomaticDimension;
        }
    }
    if (indexPath.section == 6) { // 联系方式
        
        if (!kISNullObject(self.model.qq) || !kISNullObject(self.model.wx) || !kISNullObject(self.model.contact)) {
            CGFloat f = 120.f;

            if (kISNullObject(self.model.qq)) {
                f-=30;
            }
            if (kISNullObject(self.model.wx)) {
                f-=30;
            }
            if (kISNullObject(self.model.contact)) {
                f-=30;
            }

            return f;
            
        } else {
            return 0;
        }
        
    }
    if (indexPath.section == 8) { // 证件公示
        if (self.isApp == HongApp) {
            if (kISNullObject(self.model.papers)) {
                return kSafeAreaBottom;
            } else {
                return 380;
            }
            
        }
        else {
            if (kISNullObject(self.model.papers)) {
                return kSafeAreaBottom;
            } else {
                return 330;
            }
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // 头部视图
        CoachHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachHeadCell"];
        cell.delegate = self;
        [cell.headImg sd_setImageWithURL:[NSURL URLWithString:self.model.head]];
        cell.nameLab.text = self.model.nickname;
        cell.cityLab.text = self.model.city;
        cell.sexLab.text = self.model.sex;
        cell.ageLab.text = [NSString stringWithFormat:@"%@岁",self.model.age];
        cell.geYanLab.text = self.model.motto;
        
        return cell;
    }
    if (indexPath.section == 1) { // 教育背景
        CSEducationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSEducationDetailCell"];
        cell.selectionStyle = 0;
        cell.schoolLab.text = self.model.school;
        cell.eduLab.text = self.model.education;
        cell.marLab.text = self.model.major;
        
        return cell;
    }
    if (indexPath.section == 2){ // 擅长领域
        CSHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSHomeTableViewCell" forIndexPath:indexPath];
        cell.cellType = GradeType;
        cell.dataMuArray = [NSMutableArray arrayWithArray:self.model.curriculum];
        cell.selectionStyle = 0;
        
        cell.seleBlock = ^(NSInteger cuid,NSString *title) {
            
        };
        
        return cell;
    }
    if (indexPath.section == 3) { // 授课区域
        CSCoachDetailDescriptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSCoachDetailDescriptCell"];
        cell.selectionStyle = 0;
        
        cell.dicinfo = @{@"content":kISNullObject(self.model.motto)?@"":self.model.motto};
        
        return cell;
    }
    if (indexPath.section == 4) { // 授课方式
        CSCoachDetailDescriptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSCoachDetailDescriptCell"];
        cell.selectionStyle = 0;
        
        cell.dicinfo = @{@"content":kISNullObject(self.model.teaching)?@"":self.model.teaching};
        
        return cell;
    }
    if (indexPath.section == 5) { // 授课费用
        CSCoachDetailDescriptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSCoachDetailDescriptCell"];
        cell.selectionStyle = 0;
        
        cell.dicinfo = @{@"content":[[NSString stringWithFormat:@"%@",self.model.cost_low] isEqualToString:@"0"]?@"":[NSString stringWithFormat:@"%@-%@/小时",self.model.cost_low,self.model.cost_high]};
        
        return cell;
    }
    
    if (indexPath.section == 6) { // 联系方式
        
        CSDetailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSDetailContactCell"];
        cell.selectionStyle = 0;
        
        cell.phoneLab.text = kISNullObject(self.model.contact)?@"":self.model.contact;
        cell.qqLab.text = kISNullObject(self.model.qq)?@"":self.model.qq;
        cell.weChatLab.text = kISNullObject(self.model.wx)?@"":self.model.wx;
        
        if (kISNullObject(self.model.wx)) {
            cell.wxView.hidden = YES;
            [cell.wxView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
        if (kISNullObject(self.model.qq)) {
            cell.qqView.hidden = YES;
            [cell.qqView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
        if (kISNullObject(self.model.contact)) {
            cell.phoneView.hidden = YES;
            [cell.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
        
        return cell;
        
    }
    if (indexPath.section == 7) { // 个人介绍
        
        CSCoachDetailDescriptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CSCoachDetailDescriptCell"];
        cell.selectionStyle = 0;
        
        cell.dicinfo = self.dictemp;
        
        return cell;
        
    }
    if (indexPath.section == 8) { // 证件公示
        MultipleImgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultipleImgCell"];
        cell.selectionStyle = 0;
        cell.picType = OnlyShow;
        cell.pictures = self.model.papers;
        
        // 选择图片控制器
        cell.block = ^(UIViewController *vc) {
            [self presentViewController:vc animated:YES completion:nil];
        };
        
        return cell;
    }
    
    return nil;
}

// 单元格点击方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 7) { // 个人介绍(缩放展开)
        
        if ([self.dictemp[@"isChoice"] isEqualToString:@"NO"]) {
            [self.dictemp setValue:@"YES" forKey:@"isChoice"];
        } else {
            [self.dictemp setValue:@"NO" forKey:@"isChoice"];
        }
        
        [self.tableView reloadData];
    }
}

// 查看头像
- (void)photoImgViewClick:(UITapGestureRecognizer *)tap {
    
    CLAmplifyView *amplifyView = [[CLAmplifyView alloc] initWithFrame:self.view.bounds andGesture:tap andSuperView:self.view];
    [[UIApplication sharedApplication].keyWindow addSubview:amplifyView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if ([[LoginManager defaultManager] isLogin]) {
//            [self getComplaintList];
            [self showPopSelector];
        } else {
            [self.view showTostWithMessage:@"请登录后尝试"];
        }
        
    }];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dictemp = [NSMutableDictionary dictionary];
    [self.dictemp setValue:@"NO" forKey:@"isChoice"];
    [self.dictemp setValue:self.model.descr forKey:@"content"];
    
    [self.view addSubview:self.tableView];
    
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
    
    if (self.isApp == XinLiApp) {
        self.bottomView.hidden = YES;
        self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] init];
    } else {
        self.bottomView.hidden = NO;
    }
    
    [self settingBottomViewWithFrame];
}

// 底部视图根据是否关注, 显示界面内容
- (void)settingBottomViewWithFrame {
    
    [self.bottomView removeAllSubviews];
    
    if (self.userMod.follow) {
        self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, kScreenWidth - 34, 40)];
//        [self.chatBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x7994FE],[UIColor colorWithHex:0x9184FD]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.chatBtn setImage:[[UIImage imageNamed:@"icon_goChat"] imageWithColor:REDColor] forState:UIControlStateNormal];
        [self.chatBtn setTitle:@"沟通" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:REDColor forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.layer.cornerRadius = 20.f;
        self.chatBtn.layer.masksToBounds = YES;
        self.chatBtn.layer.borderWidth = 0.5;
        self.chatBtn.layer.borderColor = [REDColor CGColor];
        
        
        [self.bottomView addSubview:self.chatBtn];
    }else{

        self.followBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, 5, kScreenWidth/2 - 25, 40)];
//        [self.followBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xFFAE9D],[UIColor colorWithHex:0xFF7098]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        self.followBtn.backgroundColor = REDColor;
        [self.followBtn setImage:[UIImage imageNamed:@"icon_addFollow"] forState:UIControlStateNormal];
        [self.followBtn setTitle:@"关注" forState:UIControlStateNormal];
        [self.followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.followBtn addTarget:self action:@selector(goFollow) forControlEvents:UIControlEventTouchUpInside];
        self.followBtn.layer.cornerRadius = 20.f;
        self.followBtn.layer.masksToBounds = YES;
        [self.bottomView addSubview:self.followBtn];

        self.chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2 +8, 5, kScreenWidth/2 - 25, 40)];
//        [self.chatBtn az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0x995ff8],[UIColor colorWithHex:0x5d57ed]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self.chatBtn setImage:[[UIImage imageNamed:@"icon_goChat"] imageWithColor:REDColor] forState:UIControlStateNormal];
        [self.chatBtn setTitle:@"沟通" forState:UIControlStateNormal];
        [self.chatBtn setTitleColor:REDColor forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(goChat) forControlEvents:UIControlEventTouchUpInside];
        self.chatBtn.layer.cornerRadius = 20.f;
        self.chatBtn.layer.masksToBounds = YES;
        self.chatBtn.layer.borderWidth = 0.5;
        self.chatBtn.layer.borderColor = [REDColor CGColor];
        [self.bottomView addSubview:self.chatBtn];

    }
    
    
}

- (void)showPopSelector{
    
    CGRect frame = CGRectMake(kScreenWidth - 20 , kStatusBarHeight+22, 20, 20);
    
    FKGPopOption *s = [[FKGPopOption alloc] initWithFrame:self.view.bounds];
    s.option_optionContents = @[@"拉黑", @"拉黑并投诉"];

    [[s option_setupPopOption:^(NSInteger index, NSString *content) {
        if (index == 0) {
            [self pushBlack];
        }else{
            [self goComplaint];
        }
        
    } whichFrame:frame animate:YES] option_show];
}

// 拉黑
- (void)pushBlack{
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"mobile":self.userMod.JIM
    };
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLPull_Black withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hideLoading];
            
            [kAppDelegate.window showSuccessWithMessage:dictionary[@"msg"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePerson" object:self.userMod.JIM];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else {
            
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
    }];
    
    
}

// 拉黑并投诉
- (void)goComplaint {
    
    HLComplaintViewController *comPlaintVC = [[HLComplaintViewController alloc] init];
    comPlaintVC.userMobile = self.userMod.JIM;
    comPlaintVC.pertEnum = ZiXunShi;
    [self.navigationController pushViewController:comPlaintVC animated:YES];
    
}

// 投诉列表
- (void)getComplaintList {
    [self.view showLoading];

    [HTTPSessionManger postDataWithNSString:@"/customer/getcomplaint" withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            [LLSelectAlertView showWithTitle:@"选择投诉类型" titles:dictionary[@"data"] selectIndex:^(NSInteger selectIndex) {
                
                
            } selectValue:^(NSString * _Nonnull selectValue) {
                NSLog(@"选择的值为%@",selectValue);
                
                // 投诉
                [self requesetComplaintText:selectValue];
                
            } showCloseButton:NO];
            
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
    
    
}

// 进行举报
- (void)requesetComplaintText:(NSString *)content {
    [self.view showLoading];
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"token":[LoginManager defaultManager].token,
        @"text":content,
        @"cid":self.userMod.userId
    };

    [HTTPSessionManger postDataWithNSString:@"/customer/complaint" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:[error localizedDescription]];
    }];
}

// 聊天
- (void)goChat{
    if (![[LoginManager defaultManager] isLogin]) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    [JMSGConversation createSingleConversationWithUsername:self.userMod.JIM appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
        if (error == nil) {
            JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
            conversation = resultObject;
            HLNewChatViewController *sendMessageCtl =[[HLNewChatViewController alloc] init];
            sendMessageCtl.hidesBottomBarWhenPushed = YES;
            sendMessageCtl.conversation = conversation;
            sendMessageCtl.userName = self.userMod.JIM;
            [self.navigationController pushViewController:sendMessageCtl animated:YES];
        } else {
            NSLog(@"%@",error);
            [self.view showTostWithMessage:@"创建会话失败"];
        }
        
    }];
    
    
}

// 关注
- (void)goFollow{
    
    if (![[LoginManager defaultManager] isLogin]) {
        [self.view showErrorWithMessage:@"请登录后尝试!"];
        return;
    }
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"muid":self.userMod.userId
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/mind/collect" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.followBtn.hidden = YES;
            self.chatBtn.frame = CGRectMake(17, 5, kScreenWidth - 34, 40);
            self.sureBlock();
        }else{
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"操作失败，请重试！"];
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
