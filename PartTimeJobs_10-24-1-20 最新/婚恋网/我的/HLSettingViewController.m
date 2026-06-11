//
//  HLSettingViewController.m
//  婚恋网
//
//  Created by iMac on 2019/5/9.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLSettingViewController.h"
#import "HLNotifionViewController.h"
#import "HLHTMLLableViewController.h"
#import "HLLeavingViewController.h"

@interface HLSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString *_newVersionURlString;
    UIAlertView * alert;
    BOOL isClose;
}
@property(nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;/*用户标题数组*/
@end

@implementation HLSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"设置";
    isClose = YES;
    self.titleArray = @[@[@"通知设置",@"清除缓存",@"资料状态"],@[@"关于我们",@"防骗手册",@"隐私政策",@"免责声明",@"服务协议",@"客服留言"]];
    [self creatTableView];
    
    if ([[LoginManager defaultManager] isLogin]) {
        [self getUserInfoStatue];
    }
    
    
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
    [self.view addSubview:_tableView];
}

-(void)logout
{
    alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 110;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 1000) {
            if(_newVersionURlString)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_newVersionURlString]];
            }
        }else if (alertView.tag == 110){
            
            [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {

                if (iResCode == 0) {

                    NSLog(@"删除别名成功");

                }
                
            } seq:0];
            
            // 先注销  如果不主动调用 logout 接口，原则上是一直处于登录的。
            [JMSGUser logout:^(id resultObject, NSError *error) {
                NSLog(@"退出结果 返回%@",resultObject);
                
                // 心理咨询刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOAD_XIN" object:nil];
                
                //注销登录
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
                [self.tabBarController setSelectedIndex:0];  //默认第一个
                [self.navigationController popViewControllerAnimated:NO];
            }];
//            [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
//            [self.tabBarController setSelectedIndex:0];  //默认第一个
//            [self.navigationController popViewControllerAnimated:NO];
            
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titleArray[section] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==1) {
        return 65;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == self.titleArray.count-1) {
        UIView * view = [[UIView alloc]init];
        CGRect frameRect = CGRectMake(0, 0, kScreenWidth, 40);
        view.frame = frameRect;
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setFrame:CGRectMake(20, 20, kScreenWidth-40, 38)];
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor colorWithHex:0xFF3B30] forState:UIControlStateNormal];
        button.layer.cornerRadius = 19.0;
         button.layer.masksToBounds = YES;
         button.layer.borderColor = [UIColor redColor].CGColor;
         button.layer.borderWidth = 1.f;
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        return view;
    }
    
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //需要补全
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MoreViewCell"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = kCellTitleColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.text = nil;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];//@"#666666"];
    if (indexPath.section == 0 && indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.titleArray[indexPath.section][indexPath.row];
    int row = (int)indexPath.row;
    
    switch (indexPath.section) {
        case 0:
            if (row==1) {
                [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount1, NSUInteger totalSize1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2lf M", ((CGFloat)totalSize1+fileCount1)/1024/1024];
                }];
            }else if (row==2){
                UISwitch * swi = [[UISwitch alloc]initWithFrame:CGRectMake(kScreenWidth - 65, 8, 50, 40)];
                // 设置控件开启状态填充色
                swi.onTintColor = REDColor;
                [swi setOn:isClose];
               
                [swi addTarget:self action:@selector(changeStatu:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:swi];
            }
            break;
        case 1:{
            
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    switch (indexPath.section) {
        case 0:
            if (row==0) {
                // 跳转通知
                HLNotifionViewController *notifionVC = [[HLNotifionViewController alloc] init];
                [self.navigationController pushViewController:notifionVC animated:YES];
                
            }else if (row==1){
                [self.view showLoadingWithMessage:@"清除缓存中……"];
                [[SDImageCache sharedImageCache] cleanDiskWithCompletionBlock:^{
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    
                    NSFileManager * fileManager = [NSFileManager defaultManager];
                    
                    NSString * path = [paths firstObject];
                    
                    if ([fileManager fileExistsAtPath:path]) {
                        NSArray *childerFiles=[fileManager subpathsAtPath:path];
                        for (NSString *fileName in childerFiles) {
                            //如有需要，加入条件，过滤掉不想删除的文件
                            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
                            [fileManager removeItemAtPath:absolutePath error:nil];
                        }
                    }
                    //
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [self.view showSuccessWithMessage:@"清除完毕！"];
                }];
            }else if (row==2){
            }
            break;
        case 1:
            if (row==0) {
                HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
                htmlVC.navTitle = @"关于我们";
                htmlVC.type = @"concerning";
                [self.navigationController pushViewController:htmlVC animated:YES];
            }else if (row==1){
                HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
                htmlVC.navTitle = @"防骗手册";
                htmlVC.type = @"security";
                [self.navigationController pushViewController:htmlVC animated:YES];
            }else if (row==2){
                HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
                htmlVC.navTitle = @"隐私政策";
                htmlVC.type = @"privacy";
                [self.navigationController pushViewController:htmlVC animated:YES];
            }else if(row == 3){
                HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
                htmlVC.navTitle = @"免责声明";
                htmlVC.type = @"disclaimer";
                [self.navigationController pushViewController:htmlVC animated:YES];
            }else if(row == 4){
                HLHTMLLableViewController *htmlVC = [[HLHTMLLableViewController alloc] init];
                htmlVC.navTitle = @"服务协议";
                htmlVC.type = @"service";
                [self.navigationController pushViewController:htmlVC animated:YES];
            }else{ // 客服留言
                HLLeavingViewController *leavVC = [[HLLeavingViewController alloc] init];
                [self.navigationController pushViewController:leavVC animated:YES];
            }
            break;
        default:
            break;
    }
}

-(void)changeStatu:(UISwitch *)swi{
    [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadData];
    if (isClose) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"关闭资料后你将不能使用大部分功能，别人也无法看到您!!!" preferredStyle:UIAlertControllerStyleAlert];
        //增加取消按钮；
        @weakify(self);
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        
        //增加确定按钮；
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self changeStatu];
        }]];
        
        
        [self presentViewController:alertController animated:true completion:nil];
    }else{
        [self changeStatu];
    }
}

// 获取用户资料状态
- (void)getUserInfoStatue{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLISClose withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->isClose = [[dictionary objectForKey:@"data"][@"close"] boolValue];
            [weakSelf.tableView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
//切换用户资料转态
- (void)changeStatu{
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLSWITCH withDictionary:@{@"uid":[LoginManager defaultManager].userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self->isClose = !self->isClose;
            [weakSelf.tableView reloadData];
            
        }else {
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        
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
