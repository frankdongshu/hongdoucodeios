//
//  LLFindJiaJiaoDetailGoChatViewController.m
//  PartTimeJobs
//
//  Created by houli on 2024/10/27.
//  Copyright © 2024 红豆-婚恋网. All rights reserved.
//

#import "LLFindJiaJiaoDetailGoChatViewController.h"

@interface LLFindJiaJiaoDetailGoChatViewController ()
@property (nonatomic, strong) UIImageView *chatImageView;
@end

@implementation LLFindJiaJiaoDetailGoChatViewController

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    // Do any additional setup after loading the view.
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    self.chatImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    self.chatImageView.image = [UIImage imageNamed:@"gochat"];
    
    [self.view addSubview:self.chatImageView];
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
   
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    
    self.tabBarController.tabBar.hidden = NO;
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
