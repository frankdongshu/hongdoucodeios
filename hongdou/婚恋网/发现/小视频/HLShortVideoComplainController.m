//
//  HLShortVideoComplainController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/22.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLShortVideoComplainController.h"

@interface HLShortVideoComplainController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HLShortVideoComplainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"提交" withColor:kRGBA(255, 92, 120, 1) style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self uploadData];
        
    }];
    
    
    self.sc_navigationBar.title = @"视频分享";
    
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = .5;
}

- (void)uploadData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"title":self.titleTF.text,
        @"txt":self.textView.text
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/share" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [MBProgressHUD showSuccess:@"提交成功" toView:kAppDelegate.window];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
