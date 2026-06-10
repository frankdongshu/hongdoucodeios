//
//  HLSucessViewController.m
//  婚恋网
//
//  Created by iMac on 2019/3/24.
//  Copyright © 2019年 红豆-婚恋网. All rights reserved.
//

#import "HLSucessViewController.h"

@interface HLSucessViewController ()
{
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *messageLable;

@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (nonatomic, strong)HXBarButtonItem *leftBarItem;

//标志位
@property (nonatomic,assign)NSInteger volidationTime;//验证码获取时间;
@end

@implementation HLSucessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
        
    self.messageLable.text = _sucessMessage;
    [self initContollerView];
    [self createNavig];
    self.volidationTime = 15;
    [self addTimerForMessage];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //禁用全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = NO;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //开启全局滑动手势
    HXNavigationController * navigationController = (HXNavigationController *)self.navigationController;
    navigationController.enableInnerInactiveGesture = YES;
}

- (void)createNavig{
    
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back_white"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        @strongify(self);
        [self removeTimer];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    UILabel *titleLbale = [[UILabel alloc] initWithFrame:CGRectMake(80, kStatusBarHeight, kScreenWidth - 160, 44)];
    titleLbale.text = _navTitle;
    titleLbale.textAlignment = NSTextAlignmentCenter;
    titleLbale.font = [UIFont systemFontOfSize:17];
    titleLbale.backgroundColor = [UIColor clearColor];
    titleLbale.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLbale];
}
- (void)initContollerView{
     [_headerView az_setGradientBackgroundWithColors:@[[UIColor colorWithRed:189/255.0 green:100/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:130/255.0 green:92/255.0 blue:244/255.0 alpha:1.0]] locations:@[@(0.0),@(0.7),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
}

//定时器 15S
-(void)addTimerForMessage
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantPast]];
}
-(void)timerAction:(NSTimer *)timer
{
    NSLog(@"_____1");
    if (self.volidationTime != 0)
    {
        self.volidationTime = self.volidationTime - 1;
        NSString *titleStr = [NSString stringWithFormat:@"系统%ld秒后自动",(long)self.volidationTime];
        [self.timeLable setText:titleStr];
    }
    else
    {
        [timer invalidate];
        timer = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)backButtonClick:(id)sender {
    [self removeTimer];
    [self.navigationController popToRootViewControllerAnimated:YES];

}
- (void)removeTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
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
