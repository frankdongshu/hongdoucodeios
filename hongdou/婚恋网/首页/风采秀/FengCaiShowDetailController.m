//
//  FengCaiShowDetailController.m
//  hongdou
//
//  Created by user on 2022/8/8.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "FengCaiShowDetailController.h"
#import "HLShowComplaintPopView.h"

@interface FengCaiShowDetailController ()
@property (strong, nonatomic) UIImageView *imgView, *imgView1;

@property (strong, nonatomic) UILabel *nameLab, *addLab, *likeNumLab;

@property (strong, nonatomic) UILabel *bottomLab;

@property (strong, nonatomic) UIButton *likeBtn, *delBtn;

@property (strong, nonatomic) NSDictionary *dic;

@end

@implementation FengCaiShowDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 400)];
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    self.imgView.clipsToBounds = YES;
    [self.view addSubview:self.imgView];
    
    self.imgView1 = [[UIImageView alloc] init];
    self.imgView1.image = [UIImage imageNamed:@"show_detail_rank"];
    [self.imgView1 sizeToFit];
    [self.imgView addSubview:self.imgView1];
    
    self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.imgView.frame)+16, kScreenWidth-40, 20)];
    self.nameLab.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.nameLab];
    
    self.addLab = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.nameLab.frame)+5, kScreenWidth-40, 15)];
    self.addLab.textColor = kRGBA(102, 102, 102, 1);
    self.addLab.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.addLab];
    
    self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"show_red_zan"] forState:UIControlStateSelected];
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"show_gray_zan"] forState:UIControlStateNormal];
    self.likeBtn.frame = CGRectMake(kScreenWidth-44, CGRectGetMinY(self.nameLab.frame), 24, 24);
    [self.likeBtn addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.likeBtn];
    
    
    self.likeNumLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.likeBtn.frame)+5, 0, 0)];
    self.likeNumLab.textColor = kRGBA(102, 102, 102, 1);
    self.likeNumLab.font = [UIFont systemFontOfSize:12];
    self.likeNumLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.likeNumLab];
    
    [self createBottomView];
    
    [self requestData];
}

// 底部视图
- (void)createBottomView {
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-71-kSafeAreaBottom-1, kScreenWidth, 1)];
    lineView.backgroundColor = kRGBA(242, 242, 242, 1);
    [self.view addSubview:lineView];
    
    
    UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-71-kSafeAreaBottom, kScreenWidth, 71+kSafeAreaBottom)];
    theView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:theView];
    
    self.bottomLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 71)];
    self.bottomLab.textColor = kRGBA(34, 34, 34, 1);
    self.bottomLab.font = [UIFont systemFontOfSize:14];
    [theView addSubview:self.bottomLab];
    
    
    self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.delBtn.frame = CGRectMake(kScreenWidth-116, 11.5, 96, 48);
    [self.delBtn setTitle:@"删除" forState:UIControlStateNormal];
    self.delBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.delBtn.backgroundColor = kRGBA(204, 204, 204, 1);
    [self.delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.delBtn.userInteractionEnabled = NO;
    [self.delBtn addTarget:self action:@selector(delClick) forControlEvents:UIControlEventTouchUpInside];
    self.delBtn.layer.cornerRadius = 24;
    self.delBtn.layer.masksToBounds = YES;
    self.delBtn.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
    self.delBtn.layer.borderWidth = 1;
    [theView addSubview:self.delBtn];
    
    UIButton *touSuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [touSuBtn setTitle:@"投诉" forState:UIControlStateNormal];
    touSuBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [touSuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    touSuBtn.frame = CGRectMake(kScreenWidth-8-96*2-20, 11.5, 96, 48);
    [touSuBtn addTarget:self action:@selector(touSuClick) forControlEvents:UIControlEventTouchUpInside];
    touSuBtn.layer.cornerRadius = 24;
    touSuBtn.layer.masksToBounds = YES;
    
    touSuBtn.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
    touSuBtn.layer.borderWidth = 1;
    [theView addSubview:touSuBtn];
}

// 删除
- (void)delClick {
    
    [kAppDelegate.window showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.dic[@"id"]
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/activitydel" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"--->: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
    
}

// 投诉
- (void)touSuClick {
    
    HLShowComplaintPopView *pView = [[HLShowComplaintPopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    pView.aid = self.uid;
    
    [pView showSelf];
    
}

- (void)likeClick:(UIButton *)sender {
    
    if (sender.selected) {
        [self requestCollectionUrl:@"/album/activitynotlikes"];
    } else {
        [self requestCollectionUrl:@"/album/activitylikes"];
    }
    
}

- (void)requestCollectionUrl:(NSString *)url {
    [kAppDelegate.window showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.dic[@"id"]
    };
    
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"--->: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            self.likeBtn.selected = !self.likeBtn.selected;
            
            if (![url isEqualToString:@"/album/activitylikes"]) {
                self.likeNumLab.text = [NSString stringWithFormat:@"%d",[self.likeNumLab.text intValue]-1];
            } else {
                self.likeNumLab.text = [NSString stringWithFormat:@"%d",[self.likeNumLab.text intValue]+1];
            }
            
            [self.likeNumLab sizeToFit];
            
            self.likeNumLab.centerX = self.likeBtn.centerX;
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_ZAN" object:nil];
            
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
}

// 获取详情
- (void)requestData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.uid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/activity" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        HDLog(@"/album/activity: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self.view hide];
            
            self.dic = dictionary[@"data"];
            
            if (kISNullObject(self.dic)) {
                [self.view showTitle:@"获取详情失败"];
                
                return;
            }
            
            if ([[self.dic[@"uid"] stringValue] isEqualToString:[LoginManager defaultManager].userid]) {
                self.delBtn.backgroundColor = [UIColor whiteColor];
                [self.delBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                self.delBtn.userInteractionEnabled = YES;
            }
            
            if (![[self.dic[@"ranking"] stringValue] isEqualToString:@"1"]) {
                self.imgView1.hidden = YES;
            }
            
            self.likeBtn.selected = [dictionary[@"data"][@"in_likes"] intValue];
            
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"photo"]]];
            
            self.nameLab.text = dictionary[@"data"][@"nickname"];
            self.addLab.text = [NSString stringWithFormat:@"%@·%@岁",dictionary[@"data"][@"habitation"],dictionary[@"data"][@"age"]];
            
            self.likeNumLab.text = [NSString stringWithFormat:@"%@",dictionary[@"data"][@"likes"]];
            
            [self.likeNumLab sizeToFit];
            
            self.likeNumLab.centerX = self.likeBtn.centerX;
            
            
            self.bottomLab.text = [NSString stringWithFormat:@"赞%@   排名%@",dictionary[@"data"][@"likes"],dictionary[@"data"][@"ranking"]];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view showError:error.localizedDescription];
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
