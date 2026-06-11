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
#import "HLZuanShiVipCell.h" // 钻石会员开通图片
#import "HXInAppPurchaseTool.h"
#import "HXIAPProducts.h"
#import "HLDreamLoverDesView.h"

@interface HLOpenMemberViewController ()<UITableViewDelegate,UITableViewDataSource,HXInAppPurchaseToolDelegate,HLMemberTableViewCellDelegate,GDTRewardedVideoAdDelegate>
{
    HXInAppPurchaseTool * IAPTool;
    NSString *_imgUrl;
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
//    self.userTitleArray = @[@"VIP会员套餐",@"会员特权介绍",@"钻石会员"];
    self.userTitleArray = @[@"VIP会员套餐",@"会员特权介绍"];
    self.dataSource = [NSMutableArray array];
    IAPTool = [[HXInAppPurchaseTool alloc] init];
    IAPTool.delegate = self;
    [self creatTableView];
    [self requestVVipImage];
    [self requestMemberInfo];
    

    [self rewardVideoAd];
}

- (GDTRewardVideoAd *)rewardVideoAd {
    
    if (!_rewardVideoAd) {
        // 激励视频
        _rewardVideoAd = [[GDTRewardVideoAd alloc] initWithPlacementId:@"9083926724082632"];
        _rewardVideoAd.delegate = self;
        _rewardVideoAd.videoMuted = NO; // 设置模板激励视频是否静音
        
        GDTServerSideVerificationOptions *ssv = [[GDTServerSideVerificationOptions alloc] init];
        ssv.userIdentifier = [LoginManager defaultManager].userid;
        _rewardVideoAd.serverSideVerificationOptions = ssv;
        
        [_rewardVideoAd loadAd];
    }
    
    return _rewardVideoAd;
}

#pragma mark - GDTRewardedVideoAdDelegate

/**
 广告数据加载成功回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    
}

/**
 视频播放页关闭回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 */
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    
    [self.rewardVideoAd loadAd];
    
    // 获取观看次数
    [self requestVideoNumber];
    
}

// 获取观看次数
- (void)requestVideoNumber {
    
    [self.view showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_cs" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/user/get_cs %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [self.view hideLoading];
            
            [self requestAlertWithMessage:dictionary[@"data"][@"txit"]];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showTostWithMessage:error.localizedDescription];
    }];
    
}

- (void)requestAlertWithMessage:(NSString *)message {
    
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAlert = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *continueAlert = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.rewardVideoAd showAdFromRootViewController:self];
        
    }];
    
    [continueAlert setValue:REDColor forKey:@"titleTextColor"];
    
    [alertC addAction:cancelAlert];
    [alertC addAction:continueAlert];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

/**
 视频广告各种错误信息回调

 @param rewardedVideoAd GDTRewardVideoAd 实例
 @param error 具体错误信息
 */
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    
    if (error.code == 4014) {
        [self.view showError:@"请拉取到广告后再调用展示接口"];
    } else if (error.code == 4016) {
        [self.view showError:@"应用方向与广告位支持方向不一致"];
    } else if (error.code == 5012) {
        [self.view showError:@"广告已过期"];
    } else if (error.code == 4015) {
        [self.view showError:@"广告已经播放过，请重新拉取"];
    } else if (error.code == 5002) {
        [self.view showError:@"视频下载失败"];
    } else if (error.code == 5003) {
        [self.view showError:@"视频播放失败"];
    } else if (error.code == 5004) {
        [self.view showError:@"没有合适的广告"];
    } else if (error.code == 5013) {
        [self.view showError:@"请求太频繁，请稍后再试"];
    } else if (error.code == 3002) {
        [self.view showError:@"网络连接超时"];
    } else if (error.code == 5027){
        [self.view showError:@"页面加载失败"];
    } else if (error.code == 5043) {
        [self.view showError:@"模板渲染失败"];
    } else {
        [self.view showError:@"拉取失败"];
    }
    NSLog(@"ERROR: %@", error);
    
}


- (void)creatTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:250/255.f green:250/255.f blue:253/255.f alpha:1];
    
    _tableView.estimatedRowHeight = 200;
    
    _tableView.scrollsToTop = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 9.0, *)) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_tableView registerNib:[UINib nibWithNibName:@"HLMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLMemberTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLMemberIntroTableViewCell" bundle:nil] forCellReuseIdentifier:@"HLMemberIntroTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HLZuanShiVipCell" bundle:nil] forCellReuseIdentifier:@"HLZuanShiVipCell"];
    [self.view addSubview:_tableView];
}
// 请求当会员价格信息
- (void)requestMemberInfo{
    [MBProgressHUD showLoading];
//    [IAPTool requestProductsWithProductArray:IAP_VIPProducts_Arr];
    
    NSDictionary *params = @{
        @"type":@"iOS"
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLVip_PriceList withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.vipListArray = [HLMemberModel mj_objectArrayWithKeyValuesArray:dictionary[@"data"]];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (HLMemberModel *model in self.vipListArray) {
//                [array addObject:model.spid];
                [array addObject:model.ProductId];
            }
            
            [self->IAPTool requestProductsWithProductArray:array];
            
            
            [self.tableView reloadData];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];

}

// 钻石会员图片
- (void)requestVVipImage {
    
    NSDictionary *dic = @{
        @"sign":@"buyVIPios"
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"/index/notice %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self->_imgUrl = dictionary[@"data"][@"val"];
            
            [weakSelf.tableView reloadData];
            
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
//    if (indexPath.section == 0) {
//        return 56;
//    }
    return UITableViewAutomaticDimension;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 33)];
    lab.text = self.userTitleArray[section];
    [lab setFont:[UIFont systemFontOfSize:13]];
    [lab setTextColor:[UIColor colorWithHex:0x6175F6]];
    [view addSubview:lab];
    
    
    if (section == 0) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.hidden = YES;
        btn.frame = CGRectMake(kScreenWidth-210, 0, 200, 33);
//        [btn setTitle:@"您可以看视频得会员" forState:UIControlStateNormal];
        [btn setTitle:@"" forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn addTarget:self action:@selector(seeClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    if (section == 2) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth-40, 0, 33, 33);
        [btn setImage:[UIImage imageNamed:@"vvip_weihao"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(weiHaoClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    
    return view;
    
}

- (void)seeClick {
    
    [self.rewardVideoAd showAdFromRootViewController:self];
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return self.userTitleArray[section];
//}
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.backgroundColor = [UIColor lightGrayColor];
//    [header.textLabel setFont:[UIFont systemFontOfSize:13]];
//    [header.textLabel setTextColor:[UIColor colorWithHex:0x6175F6]];
//
//    if (section == 2) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(kScreenWidth-40, 0, 33, 33);
//        [btn setImage:[UIImage imageNamed:@"vvip_weihao"] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(weiHaoClick) forControlEvents:UIControlEventTouchUpInside];
//
//        [header addSubview:btn];
//    }
//
//}

- (void)weiHaoClick {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"sign":@"svip",
        @"pure":@"1"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [MBProgressHUD hideLoading];
            
            HLDreamLoverDesView *dView = [[HLDreamLoverDesView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:dictionary[@"data"][@"val"]];
            
            dView.SelectBlock = ^{
                
            };
            
            dView.CloseBlock = ^{
                
            };
            
            [dView showSelf];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
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
    }
//    else {
//        HLMemberIntroTableViewCell *cell = (HLMemberIntroTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"HLMemberIntroTableViewCell"];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.hiddenSelfSeparator = YES;
//        return cell;
//    }
    
    else {

        HLZuanShiVipCell *cell = (HLZuanShiVipCell*)[tableView dequeueReusableCellWithIdentifier:@"HLZuanShiVipCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:self->_imgUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
//            cell.imageHeight.constant = image.size.height/image.size.width*kScreenWidth;
            
        }];

        return cell;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        
        if (self.isChat) {
            [self.navigationController popViewControllerAnimated:NO];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVIPDiamond" object:self.chatVC];
            
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVIPDiamond" object:self.navigationController];
        
    }
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
        NSLog(@"暂无可购买会员产品");
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openVIP" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openChatiing" object:nil]; // 通知聊天界面刷新
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSending" object:nil];

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
