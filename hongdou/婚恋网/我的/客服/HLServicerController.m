//
//  HLServicerController.m
//  hongdou
//
//  Created by 维康1 on 2021/4/21.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLServicerController.h"
#import "HLNewChatViewController.h"

@interface HLServicerController ()

@end

@implementation HLServicerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.title = @"客服";
    
}

// 跳转客服界面
- (IBAction)serviceClick:(id)sender {
    
//    [JMSGConversation createSingleConversationWithUsername:@"hongdoukefu" appKey:JPushAPPKEY completionHandler:^(id resultObject, NSError *error) {
//        if (error == nil) {
//            JMSGConversation  *conversation  = [[JMSGConversation alloc] init];
//            conversation = resultObject;
//            HLNewChatViewController *sendMessageCtl = [[HLNewChatViewController alloc] init];
//            sendMessageCtl.conversation = conversation;
//            sendMessageCtl.userName = @"hongdoukefu";
//
//            [self.navigationController pushViewController:sendMessageCtl animated:YES];
//        }else{
//            [self.view showTostWithMessage:@"创建会话失败"];
//            return;
//        }
//    }];
    
    
    HLChatController *vc = [[HLChatController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.chatDic = @{
        @"cid":@"30020657",
        @"cname":@"客服",
        @"cmobile":@"13912345678",
        @"chead":@"http://db.hongdou.art/tp5/public/uploads/20210805/16c2a592721c7d77dd0580c634d29943.jpg",
    };
    
    [self.navigationController pushViewController:vc animated:YES];
    
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
