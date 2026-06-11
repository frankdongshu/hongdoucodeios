//
//  HLNotifionViewController.m
//  hongdou
//
//  Created by iMac on 2019/9/25.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNotifionViewController.h"
#import "HLSwitchTableViewCell.h"
#import "HLNotifionModel.h"

@interface HLNotifionViewController ()<UITableViewDelegate,UITableViewDataSource,HLSwitchCellDeleagte>

@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;/*用户标题数组*/

@property (nonatomic, strong) HLNotifionModel *model;

@end

@implementation HLNotifionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"通知设置";
    self.titleArray = @[@"私信提醒",@"被关注提醒",@"被赞提醒",@"被浏览提醒"];
    [self creatTableView];
    [self loadReques];
}


- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.contentInsetTop = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLSwitchTableViewCell"];
    [self.view addSubview:_tableView];
}

- (void)loadReques{
    WeakSelf(weakSelf);
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:HLGET_Notifiction withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.model = [HLNotifionModel mj_objectWithKeyValues:[dictionary objectForKey:@"data"]];
            [weakSelf.tableView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HLSwitchTableViewCell *cell = (HLSwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLSwitchTableViewCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.index = indexPath.row;
    cell.delegate = self;
    
    switch (indexPath.row) {
//        case 0:
//        {
//            cell.statu = self.model.voice;
//            [cell.swicthOn setOn:self.model.voice];
//        }
//            break;
//        case 1:
//        {
//            cell.statu = self.model.shock;
//            [cell.swicthOn setOn:self.model.shock];
//        }
//            break;
        case 0:
        {
            cell.statu = self.model.letter;
            [cell.swicthOn setOn:self.model.letter];
        }
            break;
        case 1:
        {
            cell.statu = self.model.follow;
            [cell.swicthOn setOn:self.model.follow];
        }
            break;
        case 2:
        {
            cell.statu = self.model.likes;
            [cell.swicthOn setOn:self.model.likes];
        }
            break;
        case 3:
        {
            cell.statu = self.model.see;
            [cell.swicthOn setOn:self.model.see];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)refreshTableView{
    [self loadReques];
}

@end
