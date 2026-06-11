//
//  HLInvitationFriendsViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLInvitationFriendsViewController.h"
#import "HLInviteAwardTableViewCell.h"
#import "HLInviteorCodeTableViewCell.h"
#import "HLShowInputView.h"


@interface HLInvitationFriendsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString *invitatCode; //邀请码
}
@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HLInvitationModel *model;

@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation HLInvitationFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
//    self.sc_navigationBar.rightBarButtonItem= [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more"] style:HXBarButtonItemStylePlain handler:^(id sender) {
//        @strongify(self);
//    }];
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:244/255.0 blue:250/255.0 alpha:1.0];
    self.sc_navigationBar.title = @"邀请有奖";
    self.titleArray = @[@"我邀请的",@"我的推荐人",@"我的推荐码"];
    [self creatTableView];
    [self requestDetail];
}
- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(17, kNavigationBarHeight, kScreenWidth - 34,kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.scrollsToTop = NO;
    self.tableView.estimatedRowHeight = 120.f;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    _tableView.tableFooterView=[[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_tableView registerNib:[UINib nibWithNibName:@"HLInviteAwardTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLInviteAwardTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLInviteorCodeTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLInviteorCodeTableViewCell"];

    [self.view addSubview:_tableView];
    
}

- (void)requestDetail{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLInviten_Reward withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-->%@",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.model =  [HLInvitationModel mj_objectWithKeyValues:dictionary[@"data"]];
            [self.tableView reloadData];

        }else{
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];
        
    }];
    [HLHTTPSessionManager postDataWithNSString:HLInviten_Code withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-->%@",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->invitatCode = [dictionary[@"data"] objectForKey:@"code"];
        }else{
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"请求失败"];
        
    }];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 210.f;
    }
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 16.5f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.section==0) {
        HLInviteAwardTableViewCell *cell = (HLInviteAwardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HLInviteAwardTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.inviteModel = self.model;
        cell.shareBlock = ^{
            // 分享 QQ 微信 sina 短信 邀请 格式是什么
            [self sharePressed];
        };
        return cell;
    }else{
        HLInviteorCodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HLInviteorCodeTableViewCell"];
        cell.titleLabel.text = self.titleArray[indexPath.section];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        if (indexPath.section == 1) {
            cell.contentLabel.hidden = YES;
            cell.fuZhiBtn.hidden = YES;
            
            if (kISNullString(self.model.invitemy)) {
                cell.inviteButton.hidden = NO;
                cell.inviteImgV.hidden = YES;
            } else {
                cell.inviteButton.hidden = YES;
                cell.inviteImgV.hidden = NO;
            }
            
            
            [cell.inviteImgV sd_setImageWithURL:[NSURL URLWithString:self.model.invitemy]];
            cell.inviteBlock = ^{
                
                if (kISNullString(self.model.invitemy)) {
                    // 邀请
                    HLShowInputView *popView = [HLShowInputView popInputView];
                    [popView show];
                    popView.submissBlock = ^(NSString * _Nonnull str) {
                        [self uploadCode:str];
                    };
                } else {
                    [self.view showTostWithMessage:@"推荐人已经存在了"];
                }
                
                
            };
        }else{
            cell.contentLabel.hidden = NO;
            cell.fuZhiBtn.hidden = NO;
            cell.inviteButton.hidden = YES;
            cell.inviteImgV.hidden = YES;
            cell.contentLabel.text = invitatCode;
        }
        return cell;
    }
 
}

// 邀请
- (void)uploadCode:(NSString *)code{
    WeakSelf(weakSelf);
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"recommend":code
    };
    
    NSLog(@"%@",params);
    
    [HLHTTPSessionManager postDataWithNSString:HLInviten_UplodeCode withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-->%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            [self requestDetail];
        }else{
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        [weakSelf.view showTostWithMessage:@"邀请失败"];
        
    }];
}

// 分享
- (void)sharePressed{
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params SSDKSetupShareParamsByText:[NSString stringWithFormat:@"邀请你来红豆佳缘, 注册时别忘了填写我的邀请码:%@",invitatCode]
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
