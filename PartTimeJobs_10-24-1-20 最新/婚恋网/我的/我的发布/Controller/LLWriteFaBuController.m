//
//  LLWriteFaBuController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLWriteFaBuController.h"
#import "LLMuBiaoTextViewCell.h"
#import "LLSelectKeMuController.h"
#import "LLTeachingMethodController.h"
#import "LLTeachingPriceController.h" // 课时费
#import "IdentityView.h"
#import "CSEditNameViewController.h"

#import "HZIAPManager.h"

@interface LLWriteFaBuController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>{
    HZIAPManager *_IAPTool;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *promptArray;

@property (nonatomic, strong) NSMutableDictionary *params;

@property (nonatomic, strong) UIView *footerView;

@end

@implementation LLWriteFaBuController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"发布信息";
    
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"发布" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        for (NSString *str in self.params.allValues) {
            if ([str isEqualToString:@""]) {
                [self.view showTostWithMessage:@"请完善后再提交!"];
                return;
            }
        }
        
        // 提交发布
        [self faBuClick];
        
    }];
    
    self.titleArray = @[@[@"授课科目",@"授课方式",@"课时费",@"教师身份",@"授课地点"],@[@""]];
    self.promptArray = [NSMutableArray arrayWithArray:@[@"未选择",@"未选择",@"请填写课时费",@"未选择",@"请填写授课地点"]];
    
    self.params = [NSMutableDictionary dictionaryWithDictionary:@{
        @"uid":[LoginManager defaultManager].userid,
        @"curriculum":@"",
        @"teaching":@"",
        @"cost1":@"",
        @"cost2":@"",
        @"identity":@"",
        @"place":@"",
        @"demand":@""
    }];
    
    [self.view addSubview:self.tableView];
    
    _IAPTool = [[HZIAPManager alloc] init];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight -kNavigationBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerNib:[UINib nibWithNibName:@"LLMuBiaoTextViewCell" bundle:nil] forCellReuseIdentifier:@"LLMuBiaoTextViewCell"];
        
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
//        _footerView.backgroundColor = [UIColor redColor];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        btn.backgroundColor = kRGBA(249, 120, 99, 1);
        btn.frame = CGRectMake(kScreenWidth/2-150, 30, 300, 40);
        btn.layer.cornerRadius = 20;
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_footerView addSubview:btn];
    }
    return _footerView;
}

- (void)btnClick {
    
    for (NSString *str in self.params.allValues) {
        if ([str isEqualToString:@""]) {
            [self.view showTostWithMessage:@"请完善后再提交!"];
            return;
        }
    }
    
    // 提交发布
    [self faBuClick];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 53;
    }
    return 128;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.titleArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuse"];
        }
        cell.selectionStyle = 0;
        
        cell.textLabel.text = self.titleArray[indexPath.section][indexPath.row];
        cell.detailTextLabel.text = self.promptArray[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    if (indexPath.section == 1) {
        LLMuBiaoTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLMuBiaoTextViewCell"];
        cell.selectionStyle = 0;
        
        cell.textView.delegate = self;
        
        return cell;
    }
    
    return nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self.params setValue:textView.text forKey:@"demand"];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) { // 授课科目
            
            LLSelectKeMuController *vc = [[LLSelectKeMuController alloc] init];
            vc.seleArray = kISNullObject(self.params[@"curriculum"])?[NSMutableArray new]:[NSMutableArray arrayWithArray:@[self.params[@"curriculum"]]];
            vc.block = ^(NSString * _Nonnull city) {
                [self.params setValue:city forKey:@"curriculum"];
                [self.promptArray replaceObjectAtIndex:0 withObject:city];
                
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        if (indexPath.row == 1) { // 授课方式
            [self requestTeachingMethodList];
        }
        if (indexPath.row == 2) { // 课时费
            
            LLTeachingPriceController *vc = [[LLTeachingPriceController alloc] init];
            
            vc.fromString = kISNullObject(self.params[@"cost1"])?@"":self.params[@"cost1"];
            vc.toString = kISNullObject(self.params[@"cost2"])?@"":self.params[@"cost2"];
            
            vc.priType = PriceFaBuType;
            vc.priceBlock = ^(NSString *fromStr, NSString *toStr) {
              
                [self.params setValue:fromStr forKey:@"cost1"];
                [self.params setValue:toStr forKey:@"cost2"];
                
                [self.promptArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%@-%@/小时",fromStr,toStr]];
                [self.tableView reloadData];
                
            };
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        if (indexPath.row == 3) { // 教师身份
            
            IdentityView *view = [[IdentityView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andSelectString:self.params[@"identity"]];
            view.identityType = IdentityFaBu;
            view.idenBlock = ^(NSString * _Nonnull string) {
                
                [self.params setValue:string forKey:@"identity"];
                
                [self.promptArray replaceObjectAtIndex:3 withObject:string];
                [self.tableView reloadData];
                
            };
            [view showSelf];
            
        }
        if (indexPath.row == 4) { // 授课地点
            
            CSEditNameViewController *vc = [[CSEditNameViewController alloc] init];
            vc.titleString = @"授课地点";
            vc.alreadyString = self.params[@"place"];
            vc.pageType = ShouKePlace;
            
            vc.shoukeBlock = ^(NSString * _Nonnull shouKeString) {
              
                [self.params setValue:shouKeString forKey:@"place"];
                
                [self.promptArray replaceObjectAtIndex:4 withObject:shouKeString];
                [self.tableView reloadData];
                
            };
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
    }
    
}

#pragma mark - 授课方式列表

- (void)requestTeachingMethodList {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"token":[LoginManager defaultManager].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/get_teaching_list" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            LLTeachingMethodController *vc = [[LLTeachingMethodController alloc] init];
            
            vc.dataArray = kISNullObject(self.params[@"teaching"])?[NSMutableArray new]:[NSMutableArray arrayWithArray:[self.params[@"teaching"] componentsSeparatedByString:@","]];
            
            vc.teaType = FaBuType;
            vc.listArray = dictionary[@"data"];
            
            vc.teachingBlock = ^(NSString * _Nonnull teaching) {
               
                [self.params setValue:teaching forKey:@"teaching"];
                [self.promptArray replaceObjectAtIndex:1 withObject:teaching];
                
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView endEditing:YES];
}

// 提交发布信息
- (void)faBuClick {
    
    [self.tableView endEditing:YES];
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/issue/user_issue" withDictionary:self.params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"=== %@",dictionary);

        if ([[NSString stringWithFormat:@"%@",dictionary[@"code"]] isEqualToString:@"200"]) {
            
            // 持久化iid, 以防不成功再进来直接空的问题
            [[LoginManager defaultManager] setIid:dictionary[@"data"][@"iid"]];
            
            [self->_IAPTool startIAPWithProductID:@"fabufei11" completeHandle:^(IAPResultType type, NSData * _Nonnull data) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    switch (type) {
                        case IAPResultSuccess:
                            [self.view showSuccessWithMessage:@"购买成功"];
                            break;
                        case IAPResultFailed:
                            [self.view showErrorWithMessage:@"购买失败"];
                            break;
                        case IAPResultCancle:
                            [[LoginManager defaultManager] setIid:@""];
                            [self.view showErrorWithMessage:@"取消购买"];
                            break;
                        case IAPResultVerFailed:
                            [self.view showErrorWithMessage:@"订单校验失败"];
                            break;
                        case IAPResultVerSuccess:
                            [[LoginManager defaultManager] setIid:@""];
                            [kAppDelegate.window showSuccessWithMessage:@"支付成功"];
                            [self.navigationController popViewControllerAnimated:YES];
                            break;
                        case IAPResultNotArrow:
                            [self.view showErrorWithMessage:@"不允许程序内付费"];
                            break;
                        default:
                            break;
                    }
                    
                });
                
            }];
            
            
        } else {
            [self.view showErrorWithMessage:dictionary[@"msg"]];
        }

    } failure:^(NSError * _Nonnull error) {
        [self.view showErrorWithMessage:[error localizedDescription]];
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
