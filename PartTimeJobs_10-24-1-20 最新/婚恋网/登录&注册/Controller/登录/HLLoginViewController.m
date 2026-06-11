//
//  HLLoginViewController.m
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLLoginViewController.h"
#import "HLLoginView.h"
#import "HLRegisterViewController.h"
#import "HLResetViewController.h"
#import "HDThridLoginManager.h"
#import "HLAuthenticationViewController.h"
#import "HLBindingViewController.h"
#import "HLUserDetailInfoViewController.h" // 完善信息
#import "HLHTMLLableViewController.h"
#import "MentalityController.h" // 心理咨询登录界面
#import "HDLoginController.h" // 红豆登录界面


#import "CustomButtom.h"
#import "CSUserInfoViewController.h"

@interface HLLoginViewController ()


@property (nonatomic, strong) CustomButtom *coachBtn;
@property (nonatomic, strong) CustomButtom *customerBtn;
@property (nonatomic, assign) NSInteger identity;

@end

@implementation HLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.title = @"登录";
    
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DismissLoginView object:nil];
    }];
    
    _identity =1;
    [self createUI];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissVC) name:DismissLoginView object:nil];
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([LoginManager defaultManager].isEditInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ShowDetailInfoView object:nil];
    }
}

-(void)createUI{
    
    [self.view addSubview:self.coachBtn];
    [self.view addSubview:self.customerBtn];
    self.coachBtn.selected = YES;
    self.customerBtn.selected = YES;
    
    [self.customerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).mas_offset(kNavBarHeight+50);
        make.width.height.mas_equalTo(200);
    }];

    [self.coachBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.customerBtn.mas_bottom).mas_offset(30);
        make.width.height.mas_equalTo(200);
    }];


}

-(void)seleBtn:(UIButton *)btn{
    NSLog(@"%@",btn.imageView.image);
    if (btn.tag == 100) { // 家教
        MentalityController *vc = [[MentalityController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else { // 学生
        HDLoginController *vc = [[HDLoginController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(CustomButtom *)coachBtn{
    if (_coachBtn == nil) {
        _coachBtn = [[CustomButtom alloc]init];
        _coachBtn.tag = 100;
        [_coachBtn setTitle:@"我是家教老师" forState:UIControlStateNormal];
        [_coachBtn setTitle:@"我是家教老师" forState:UIControlStateSelected];
        _coachBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

        [_coachBtn setImage:[UIImage imageNamed:@"jiajiao_img_nor"] forState:UIControlStateNormal];
        [_coachBtn setImage:[UIImage imageNamed:@"jiajiao_img_pre"] forState:UIControlStateSelected];

        [_coachBtn setTitleColor:REDColor forState:UIControlStateNormal];
        [_coachBtn addTarget:self action:@selector(seleBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coachBtn;
}

-(CustomButtom *)customerBtn{
    if (_customerBtn == nil) {
        _customerBtn = [[CustomButtom alloc]init];
        _customerBtn.tag = 101;
        [_customerBtn setTitle:@"我是学生家长" forState:UIControlStateNormal];
        [_customerBtn setTitle:@"我是学生家长" forState:UIControlStateSelected];
        _customerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_customerBtn setImage:[UIImage imageNamed:@"xuesheng_img_nor"] forState:UIControlStateNormal];
        [_customerBtn setImage:[UIImage imageNamed:@"xuesheng_img_per"] forState:UIControlStateSelected];
        [_customerBtn setTitleColor:REDColor forState:UIControlStateNormal];
        [_customerBtn addTarget:self action:@selector(seleBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customerBtn;
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
