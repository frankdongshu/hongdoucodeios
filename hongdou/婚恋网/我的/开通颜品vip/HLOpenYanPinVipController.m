//
//  HLOpenYanPinVipController.m
//  hongdou
//
//  Created by 维康1 on 2021/3/11.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLOpenYanPinVipController.h"
#import "HLYanMemberCell.h"
#import "HLOpenYanPinCell.h"
#import "HXInAppPurchaseTool.h"
#import "HXIAPProducts.h"
#import "HLDreamLoverDesView.h"
#import "HLDreamLoverDesView.h"

@interface HLOpenYanPinVipController ()<UITableViewDelegate,UITableViewDataSource,HXInAppPurchaseToolDelegate,HLYanMemberCellDelegate>
{
    HXInAppPurchaseTool * IAPTool;
    NSString *_imgUrl;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *productArr; // 测试产品ID


@property (nonatomic, strong) NSArray *vipListArray;
@property (nonatomic, strong) NSString *listMessageString;

@end

@implementation HLOpenYanPinVipController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"颜品会员";
    self.userTitleArray = @[@"VIP会员套餐",@"会员特权介绍"];
    self.dataSource = [NSMutableArray array];
    IAPTool = [[HXInAppPurchaseTool alloc] init];
    IAPTool.isYanPinVip = YES;
    IAPTool.delegate = self;
    [self creatTableView];
    [self requestMemberInfo];
    [self requestMessage];
    

}
- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
    
    _tableView.backgroundColor = [UIColor whiteColor];
    
    _tableView.estimatedRowHeight = 200;
    
    _tableView.scrollsToTop = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_tableView registerNib:[UINib nibWithNibName:@"HLYanMemberCell" bundle:nil] forCellReuseIdentifier:@"HLYanMemberCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLOpenYanPinCell" bundle:nil] forCellReuseIdentifier:@"HLOpenYanPinCell"];
    [self.view addSubview:_tableView];
}
// 请求当会员价格信息
- (void)requestMemberInfo{
    [MBProgressHUD showLoading];
//    [IAPTool requestProductsWithProductArray:IAP_VIPProducts_Arr];
    
    NSDictionary *params = @{
        @"type":@"abvip"
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLVip_PriceList withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"~~~%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.vipListArray = [HLMemberModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (HLMemberModel *model in self.vipListArray) {
                [array addObject:model.spid];
            }
            
            NSLog(@"物品id: %@",array);
            
            [self->IAPTool requestProductsWithProductArray:array];
            
            
            [self.tableView reloadData];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];

}

// 描述
- (void)requestMessage {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"sign":@"ab",
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~~: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.listMessageString = dictionary[@"data"][@"val"];
            
            [self.tableView reloadData];
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}


#pragma mark tableView代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.userTitleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.vipListArray.count;
    }else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 55.f;
//        return UITableViewAutomaticDimension;
    }
    return UITableViewAutomaticDimension;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kRGB(250, 250, 253);
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 33)];
    lab.text = self.userTitleArray[section];
    [lab setFont:[UIFont systemFontOfSize:13]];
    [lab setTextColor:[UIColor colorWithHex:0x6175F6]];
    [view addSubview:lab];
    
    return view;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HLYanMemberCell *cell = (HLYanMemberCell*)[tableView dequeueReusableCellWithIdentifier:@"HLYanMemberCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.memberModel = self.vipListArray[indexPath.row];
        cell.delegate = self;
        return cell;
        
    } else {
        HLOpenYanPinCell *cell = (HLOpenYanPinCell*)[tableView dequeueReusableCellWithIdentifier:@"HLOpenYanPinCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        [cell.webView loadHTMLString:[self reSizeImageWithHTML:self.listMessageString] baseURL:nil];
        
        
        return cell;
    }
   
}

- (NSString *)reSizeImageWithHTML:(NSString *)html {
    return [NSString stringWithFormat:@"<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0'><meta name='apple-mobile-web-app-capable' content='yes'><meta name='apple-mobile-web-app-status-bar-style' content='black'><meta name='format-detection' content='telephone=no'><style type='text/css'>img{width:%fpx}</style>%@", kScreenWidth - 30, html];
}


#pragma mark - 内购按钮点击

-(void)didSelectBuyButtonWithProductID:(NSString *)productID {
    
    NSLog(@"内购按钮点击 产品ID：%@",productID);
    
    [MBProgressHUD showLoading];
    
    if (![IAPTool buyProduct:productID]) {
        [MBProgressHUD showMessage:@"您没有权限购买商品！" view:nil];
    } else {
        
    }
    
}


//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"获取到可购买商品%lu个",(unsigned long)products.count);
    
    if (products.count < 1) {
        [self.view showTostWithMessage:@"暂无可购买会员产品"];
    }
    
//    self.dataSource = products;
//
//    //设置空白页
//    if (self.dataSource.count == 0) {
//        [self.view showTostWithMessage:@"暂无可购买会员产品"];
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//        [self.view hideLoading];
//    });
    
    
}

// 支付已被取消
- (void)IAPToolCanceldWithProductID:(NSString *)productID {
    NSLog(@"canceld:%@",productID);
    [MBProgressHUD showMessage:@"购买失败" view:nil];
}

// 支付成功了，并开始上服务器验证收据有效性
- (void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"BeginChecking:%@",productID);
    
}

// 充值成功
- (void)IAPToolCheckSuccessedWithProductID:(NSString *)productID andInfo:(NSString *)info {
    
    NSLog(@"BoughtSuccessed:%@",productID);
    
    [[LoginManager defaultManager] setIsVip:YES];
    
    [MBProgressHUD showSuccess:@"购买成功" toView:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"openVIP" object:nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"openChatiing" object:nil]; // 通知聊天界面刷新

        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

//服务器验证失败了
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSString *)info {
    NSLog(@"CheckFailed:%@",productID);
    
    [MBProgressHUD showError:info toView:nil];
    
    [self createHelpMessageHeaderView];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    NSLog(@"Restored:%@",productID);
    [MBProgressHUD showSuccess:@"成功恢复了商品！" toView:nil];
}

//内购系统错误了
-(void)IAPToolSysWrong {
    [MBProgressHUD showError:@"未连接到itunes store，请稍后再试！" toView:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
/**
 提示用户不用重复充值
 */
- (void)createHelpMessageHeaderView{
    
//    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    [MBProgressHUD hideHUDForView:app.window animated:YES];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 90)];
    headerView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    
    UILabel *contentLabel = [[UILabel alloc]init];
    contentLabel.textColor = [UIColor darkGrayColor];
    contentLabel.numberOfLines = 0;
    [headerView addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(headerView).insets(UIEdgeInsetsMake(8, 10, 8, 10));
    }];
    NSString *textStr = [NSString stringWithFormat:@"当金币充值失败后，请勿重复购买！！请重新启动APP，打开此页面即可自动完成充值！如果依然无法充值，请联系客服"];
    // 调整行间距、段间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    NSRange range = NSMakeRange(0, textStr.length);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    contentLabel.attributedText = attributedString;
    
    // 计算文本的大小
    NSDictionary *dic = [attributedString attributesAtIndex:0 effectiveRange:&range];
    CGSize sizeToFit = [textStr boundingRectWithSize:CGSizeMake(kScreenWidth-20, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:dic
                                             context:nil].size;
    
    headerView.frame = CGRectMake(0, 0, kScreenWidth, sizeToFit.height+18);
    self.tableView.tableHeaderView = headerView;
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
