//
//  HLYinXiangViewController.m
//  hongdou
//
//  Created by 维康1 on 2019/12/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLYinXiangViewController.h"
#import "QQTagView.h"

@interface HLYinXiangViewController ()<QQTagViewDelegate> {
    BOOL select;
}
@property (nonatomic, strong) UILabel *personCountLabel;

@property (nonatomic, strong) UILabel *zanWuLabel;
@property(nonatomic, strong) QQTagView *HeaderView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *vxBtn;
@property (nonatomic, strong) UIButton *pengYouQBtn;


@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation HLYinXiangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.rightBarButtonItem= [[HXBarButtonItem alloc] initWithTitle:@"编辑" withColor:kRGBA(255, 92, 121, 1) style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self editButtonClick];
                   
        
    }];
    self.sc_navigationBar.rightBarButtonItem.enabled = NO;
    
    self.sc_navigationBar.title = @"好友印象";
    
    self.view.backgroundColor = kRGBA(245, 245, 249, 1);
    
    [self createView];
    
    [self requestData];
    
}

// 编辑
- (void)editButtonClick {
    
    if (select) {
        select = NO;
        self.HeaderView.Style = QQTagStyleNone;
        
    } else {
        
        select = YES;
        self.HeaderView.Style = QQTagStyleEditSlect;
    }
    
}

// 标签视图的位置
- (void)QQTagView:(QQTagView *)QQTagView sizeChange:(CGRect)newSize {
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, newSize.size.height);
}

- (void)QQTagView:(QQTagView *)QQTagView QQTagItem:(QQTagItem *)QQTagItem {
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该好友印象" preferredStyle:UIAlertControllerStyleAlert];

    // 确定
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.HeaderView remove:QQTagItem.text];
        [self deleteYinXiangWithEid:QQTagItem.tag];

    }];

    // 取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {


    }];

    [alert addAction:cancelAction];  // 取消
    [alert addAction:defaultAction]; // 确定

    [self presentViewController:alert animated:YES completion:nil];
    
    
}

// 创建页面
- (void)createView {
    
    _personCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 53)];
    _personCountLabel.backgroundColor = [UIColor clearColor];
    _personCountLabel.font = kScaleFont(14);
    _personCountLabel.textColor = [UIColor darkGrayColor];
    
    [self.view addSubview:_personCountLabel];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.personCountLabel.frame), kScreenWidth, 250)];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    self.HeaderView = [[QQTagView alloc] init];
    self.HeaderView.frame = CGRectMake(0, 0, kScreenWidth, 0);
    self.HeaderView.delegate = self;
    
    [self.scrollView addSubview:self.HeaderView];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), kScreenWidth, kScreenHeight-self.personCountLabel.size.height-self.scrollView.size.height-kNavBarHeight)];
    view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:view];
    

    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth-30, 0.5)];
    self.lineView.backgroundColor = kRGBA(232, 233, 235, 1);
    [view addSubview:self.lineView];



    self.vxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.vxBtn setTitle:@"邀请微信好友撰写" forState:UIControlStateNormal];
    [self.vxBtn addTarget:self action:@selector(vkClick) forControlEvents:UIControlEventTouchUpInside];
    self.vxBtn.frame = CGRectMake(42, CGRectGetMaxY(self.lineView.frame)+100, kScreenWidth-84, 41);
    self.vxBtn.backgroundColor = kRGBA(160, 132, 247, 1);
    self.vxBtn.layer.cornerRadius = 20;
    self.vxBtn.layer.masksToBounds = YES;

    [view addSubview:self.vxBtn];



    self.pengYouQBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pengYouQBtn setTitle:@"分享到微信朋友圈" forState:UIControlStateNormal];
    [self.pengYouQBtn addTarget:self action:@selector(pengYouQClick) forControlEvents:UIControlEventTouchUpInside];
    self.pengYouQBtn.frame = CGRectMake(42, CGRectGetMaxY(self.vxBtn.frame)+15, kScreenWidth-84, 41);
    self.pengYouQBtn.backgroundColor = kRGBA(255, 102, 129, 1);
    self.pengYouQBtn.layer.cornerRadius = 20;
    self.pengYouQBtn.layer.masksToBounds = YES;

    [view addSubview:self.pengYouQBtn];
    
    
    
    
    
    self.zanWuLabel = [[UILabel alloc] initWithFrame:self.scrollView.frame];
    self.zanWuLabel.text = @"一起邀请好友写印象吧";
    self.zanWuLabel.textColor = kRGBA(64, 70, 87, 1);
    self.zanWuLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:self.zanWuLabel];
    
}


- (void)vkClick {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params SSDKSetupShareParamsByText:@"一个简单而真实的恋爱平台！"
                                images:[UIImage imageNamed:@"image_touxiang"]
                                   url:[NSURL URLWithString:@"http://db.hongdou.art/index.php/index/index/invitational.html"]
                                 title:APP_NAME
                        type:SSDKContentTypeAuto];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:params onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
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

- (void)pengYouQClick {
  
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params SSDKSetupShareParamsByText:@"一个简单而真实的恋爱平台！"
                                images:[UIImage imageNamed:@"image_touxiang"]
                                   url:[NSURL URLWithString:@"http://db.hongdou.art/index.php/index/index/invitational.html"]
                                 title:APP_NAME
                        type:SSDKContentTypeAuto];
    
    [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:params onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
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

// 删除好友印象
- (void)deleteYinXiangWithEid:(NSInteger)eid {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"eid":[NSNumber numberWithInteger:eid]
    };
    
    [HLHTTPSessionManager postDataWithNSString:HLFriends_Delete_YinXiang withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        [self requestYinXiangCount]; // 获取印象数量
        
        [self.view showTostWithMessage:dictionary[@"msg"]];
        
    } failure:^(NSError * _Nonnull error) {
        
        
    }];
    
}


// 请求数据
- (void)requestData {
    
   
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLFriends_YinXiang withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            
            NSString *string = [NSString stringWithFormat:@"%@",dictionary[@"data"][@"count"]];
            NSString *string1 = [NSString stringWithFormat:@"    共收集到%@枚好友印象",string];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string1];
            [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[string1 rangeOfString:string]];
            
            self.personCountLabel.attributedText = text;
            
            if ([string isEqualToString:@"0"]) {
                
            } else {
                self.sc_navigationBar.rightBarButtonItem.enabled = YES;
                [self.HeaderView addTags:dictionary[@"data"][@"list"]];
                self.zanWuLabel.hidden = YES;
            }
            
            
        } else {
            
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
//        [weakSelf.collectionView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
        
}

// 删除成功, 在请求好友印象数量
- (void)requestYinXiangCount {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:HLFriends_YinXiang withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            
            NSString *string = [NSString stringWithFormat:@"%@",dictionary[@"data"][@"count"]];
            NSString *string1 = [NSString stringWithFormat:@"    共收集到%@枚好友印象",string];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string1];
            [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[string1 rangeOfString:string]];
            
            self.personCountLabel.attributedText = text;
            
            if ([string isEqualToString:@"0"]) {
                self.zanWuLabel.hidden = NO;
                self.sc_navigationBar.rightBarButtonItem.enabled = NO;
            } else {
                
            }
            
            
        } else {
            
            [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
        
//        [weakSelf.collectionView reloadData];
        
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
