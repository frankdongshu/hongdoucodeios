//
//  LLBuyNumberController.m
//  hongdou
//
//  Created by 维康1 on 2021/6/24.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "LLBuyNumberController.h"
#import "LLBuyVipCell.h"
#import "LLBuyVipHeaderView.h"

#import "HZIAPManager.h"

@interface LLBuyNumberController ()<UITableViewDelegate, UITableViewDataSource, LLBuyVipCellDelegate> {
    HZIAPManager *_IAPTool;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LLBuyVipHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation LLBuyNumberController

// 禁用侧滑返回手势
- (void)forbiddenGesture {
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self forbiddenGesture];
    self.view.backgroundColor = [UIColor whiteColor];
    self.sc_navigationBar.title = @"购买联系方式可显功能";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBarHeight);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self getMemberDate]; // 获取功能到期时间
//    [self requestVipList]; // 获取购买项目
    
    LLBuyVipModel *model = [[LLBuyVipModel alloc] init];
    
    model.day = @"365";
    model.money = @"108";
    model.type = @"M_year";
    
    self.dataArray = [NSMutableArray arrayWithObject:model];
    
    _IAPTool = [[HZIAPManager alloc] init];
}

- (LLBuyVipHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[LLBuyVipHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.estimatedRowHeight = 100.0f;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableFooterView = [[UIView alloc] init];
        
        [_tableView registerNib:[UINib nibWithNibName:@"LLBuyVipCell" bundle:nil] forCellReuseIdentifier:@"LLBuyVipCell"];
        
        _tableView.tableHeaderView = self.headerView;
        
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLBuyVipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLBuyVipCell"];
    cell.selectionStyle = 0;
    cell.theModel = self.dataArray[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

// 点击开通按钮
- (void)didSelectBuyButtonWithProductID:(NSString *)productID {
    
    NSLog(@"%@",productID);
    
    [self.view showLoading];
    [_IAPTool startIAPWithProductID:productID agentId:nil andUrl:@"/mind/newmember" completeHandle:^(IAPResultType type, NSData * _Nonnull data) {

        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (type) {
                case IAPResultSuccess:
                    [self.view showSuccessWithMessage:@"购买成功"];
                    break;
                case IAPResultFailed:
                    [self.view showErrorWithMessage:@"购买失败"];
                    break;
                case IAPResultCancle:
                    [self.view showErrorWithMessage:@"取消购买"];
                    break;
                case IAPResultVerFailed:
                    [self.view showErrorWithMessage:@"订单校验失败"];
                    break;
                case IAPResultVerSuccess:
                    [self.view showSuccessWithMessage:@"订单校验成功"];
                    [self getMemberDate];
                    break;
                case IAPResultNotArrow:
                    [self.view showErrorWithMessage:@"不允许程序内付费"];
                    break;
                default:
                    break;
            }
            
        });
        
    }];
    
}

- (void)requestVipList {
    [self.view showLoading];
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/member_price" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self.view hideLoading];
            
            self.dataArray = [LLBuyVipModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            [self.tableView reloadData];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:@"请求失败"];
    }];
}

// 会员到期时间
- (void)getMemberDate {
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [self.view showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/mind/is_newmember" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        [self.view hideLoading];
        
        NSLog(@"/mind/is_newmember: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.headerView.typeLabel.attributedText = [[NSString alloc] attriStringWithFirstString:@"您的查看联系方式到期日是：" withTwoString:[NSString stringWithFormat:@"%@",!kISNullObject(dictionary[@"data"][@"date"]) ? dictionary[@"data"][@"date"] : @"未开通"] withThreeString:@"" color:[UIColor blackColor]];
            
            
        } else {
            
            self.headerView.typeLabel.attributedText = [[NSString alloc] attriStringWithFirstString:@"您的信息置顶功能到期日是：" withTwoString:@"未开通" withThreeString:@"" color:[UIColor blackColor]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:error.localizedDescription];
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
