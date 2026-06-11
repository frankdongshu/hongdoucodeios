//
//  HLOpenMemberViewController.m
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLOpenMemberViewController.h"
#import "HLMemberTableViewCell.h"
#import "HLMemberIntroTableViewCell.h"
#import "HXInAppPurchaseTool.h"
#import "HXIAPProducts.h"

@interface HLOpenMemberViewController ()<UITableViewDelegate,UITableViewDataSource,HXInAppPurchaseToolDelegate,HLMemberTableViewCellDelegate>
{
    HXInAppPurchaseTool * IAPTool;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *userTitleArray;/*用户标题数组*/

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSArray *productArr; // 测试产品ID


@property (nonatomic, strong) NSArray *vipListArray;

@end

@implementation HLOpenMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"开通会员";
    self.userTitleArray = @[@"VIP会员套餐",@"会员特权介绍"];
    self.dataSource = [NSMutableArray array];
    IAPTool = [[HXInAppPurchaseTool alloc] init];
    IAPTool.delegate = self;
    [self creatTableView];
    [self requestMemberInfo];
    

}
- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
    _tableView.scrollsToTop = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_tableView registerNib:[UINib nibWithNibName:@"HLMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLMemberTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLMemberIntroTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLMemberIntroTableViewCell"];
    [self.view addSubview:_tableView];
}
// 请求当会员价格信息
- (void)requestMemberInfo{
    [self.view showLoading];
//    [IAPTool requestProductsWithProductArray:IAP_VIPProducts_Arr];
    
    NSDictionary *params = @{
        @"type":@"iOS"
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLVip_PriceList withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [self.view hideLoading];
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.vipListArray = [HLMemberModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (HLMemberModel *model in self.vipListArray) {
                [array addObject:model.spid];
            }
            
            [self->IAPTool requestProductsWithProductArray:array];
            
            
            [self.tableView reloadData];
            
        } else {
            
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        
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
        return 48.f;
    }
    return 48.f;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.userTitleArray[section];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.backgroundColor = [UIColor lightGrayColor];
    [header.textLabel setFont:[UIFont systemFontOfSize:13]];
    [header.textLabel setTextColor:REDColor];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HLMemberTableViewCell *cell = (HLMemberTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLMemberTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.memberModel = self.vipListArray[indexPath.row];
        
//        SKProduct *product = [self.dataSource objectAtIndex:indexPath.row];
//        cell.productID = product.productIdentifier;
//        cell.titleLabel.text = product.localizedTitle;
//        cell.productID = IAP_VIPProducts_Arr[indexPath.row];;
//        cell.titleLabel.text = IAP_VIPNameProducts_Arr[indexPath.row];;
        
//        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [numberFormatter setLocale:product.priceLocale];
//        [numberFormatter setMaximumFractionDigits:0];
//        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
//        cell.payPriceLabel.text = formattedPrice;
        
//        cell.payPriceLabel.text = IAP_VIPPriceProducts_Arr[indexPath.row];
//        NSString *textStr = [NSString stringWithFormat:@"%@", IAP_VIPOriginProducts_Arr[indexPath.row]];
//        //中划线
//        NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
//        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
//        cell.orginPriceLabel.attributedText = attribtStr;
        cell.delegate = self;
        return cell;
    }else{
        HLMemberIntroTableViewCell *cell = (HLMemberIntroTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLMemberIntroTableViewCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.hiddenSelfSeparator = YES;
        return cell;
    }
   
}

#pragma mark - 内购按钮点击

-(void)didSelectBuyButtonWithProductID:(NSString *)productID {
    
    NSLog(@"内购按钮点击 产品ID：%@",productID);
    
    [self.view showLoading];
    
    if (![IAPTool buyProduct:productID]) {
        [self.view showErrorWithMessage:@"您没有权限购买商品！"];
    } else {
        [self.view hideLoading];
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
    [self.view showErrorWithMessage:@"购买失败"];
}

// 支付成功了，并开始上服务器验证收据有效性
- (void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"BeginChecking:%@",productID);
    [self.view showLoadingWithMessage:@"支付成功, 正在购买…"];
}

// 充值成功
- (void)IAPToolCheckSuccessedWithProductID:(NSString *)productID andInfo:(NSString *)info {
    
    NSLog(@"BoughtSuccessed:%@",productID);
    
    [self.view showSuccessWithMessage:@"购买成功" hideAfter:3];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openVIP" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openChatiing" object:nil]; // 通知聊天界面刷新

        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

//服务器验证失败了
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSString *)info {
    NSLog(@"CheckFailed:%@",productID);
    [self.view showErrorWithMessage:info hideAfter:5];
    
    [self createHelpMessageHeaderView];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    NSLog(@"Restored:%@",productID);
    [self.view showSuccessWithMessage:@"成功恢复了商品！"];
}

//内购系统错误了
- (void)IAPToolSysWrong {
//    [self.view showErrorWithMessage:@"未连接到itunes store，请稍后再试！" hideAfter:3.5];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.navigationController popViewControllerAnimated:YES];
//    });
}
/**
 提示用户不用重复充值
 */
- (void)createHelpMessageHeaderView{
    
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
