//
//  HLWenDaController.m
//  hongdou
//
//  Created by 李龙 on 2020/6/22.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLWenDaController.h"
#import "LLCustomButton.h"

@interface HLWenDaController () {
    NSString *_aid;
}
@property (weak, nonatomic) IBOutlet UILabel *questionLab;
@property (weak, nonatomic) IBOutlet LLCustomButton *buttonOne;
@property (weak, nonatomic) IBOutlet LLCustomButton *buttonTwo;

@property (weak, nonatomic) IBOutlet UILabel *todayCount;
@property (weak, nonatomic) IBOutlet UILabel *sumCount;
@property (weak, nonatomic) IBOutlet UILabel *messageLab;

@end

@implementation HLWenDaController
// 跳过该题
- (IBAction)jumpQuestion:(id)sender {
    
    [self requestQuestion];
    
}
- (IBAction)likeClick:(LLCustomButton *)sender {
    
    sender.selected = !sender.selected;
    
    [self selectQuestionWithSid:[NSString stringWithFormat:@"%ld",sender.tag] andAid:_aid];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sc_navigationBar.title = @"三观调查";
    self.view.backgroundColor = kRGBA(251, 251, 253, 1);
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.buttonOne.imgViewPointX = kScreenWidth-50-50;
    self.buttonTwo.imgViewPointX = kScreenWidth-50-50;
    
    self.buttonOne.titlePointX = 15;
    self.buttonTwo.titlePointX = 15;
    
    [self requestQuestion];
    
    [self getCount];
}

// 获取问题
- (void)requestQuestion {
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/subject/get_subject" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            self->_aid = dictionary[@"data"][@"id"];
            
            self.questionLab.text = dictionary[@"data"][@"subject"];
            [self.buttonOne setTitle:dictionary[@"data"][@"answer"][0][@"answer"] forState:UIControlStateNormal];
            [self.buttonTwo setTitle:dictionary[@"data"][@"answer"][1][@"answer"] forState:UIControlStateNormal];
            
            self.buttonOne.tag = [dictionary[@"data"][@"answer"][0][@"id"] integerValue];
            self.buttonTwo.tag = [dictionary[@"data"][@"answer"][1][@"id"] integerValue];
            
        } else if ([code isEqualToString:@"202"]) {
            
            self.messageLab.hidden = NO;
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 答题
- (void)selectQuestionWithSid:(NSString *)sid andAid:(NSString *)aid {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":sid,
        @"aid":aid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/subject/answer" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            [MBProgressHUD hideLoading];
            
            [self.buttonOne setSelected:NO];
            [self.buttonTwo setSelected:NO];
            
            [self getCount];
            
            [self requestQuestion];
            
        } else {
            
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
            
            [self.buttonOne setSelected:NO];
            [self.buttonTwo setSelected:NO];
            
            [self getCount];
            
            [self requestQuestion];
            
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 答题统计
- (void)getCount {
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/subject/get_count" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self.sumCount.text = [NSString stringWithFormat:@"今天回答%@题",dictionary[@"data"][@"today"]];
            self.todayCount.text = [NSString stringWithFormat:@"总共回答%@题",dictionary[@"data"][@"total"]];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
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
