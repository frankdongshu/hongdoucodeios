//
//  HLSettingLinkController.m
//  hongdou
//
//  Created by 维康1 on 2021/3/16.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLSettingLinkController.h"
#import "HPGrowingTextView.h"

@interface HLSettingLinkController ()

@property (nonatomic,strong) HPGrowingTextView *growingTextView;
@property (nonatomic, strong) UILabel *showNumLabel;

@end

@implementation HLSettingLinkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.growingTextView resignFirstResponder];
        
        if ([self.growingTextView.text isTrueUrl]) {
            
            self.growingTextView.text = [[self getURLFromStr:self.growingTextView.text] firstObject];
            
            [self requestSettingUrl];
            
        } else {
            [MBProgressHUD showMessage:@"请输入正确的URL" view:nil];
        }
        
    }];
    
    self.sc_navigationBar.title = @"详情链接";
    
    self.growingTextView = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(20,kNavigationBarHeight+20, kScreenWidth-40, 300)];
    self.growingTextView.minHeight = 200;
    self.growingTextView.textColor = [UIColor blackColor];
    self.growingTextView.font = [UIFont systemFontOfSize:16];
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxNumberOfLines = 10;
    self.growingTextView.animateHeightChange = NO;
    self.growingTextView.placeholder = @"请输入有效的链接地址";
    self.growingTextView.placeholderColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
//    self.growingTextView.returnKeyType = UIReturnKeyDone;
    self.growingTextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.growingTextView.enablesReturnKeyAutomatically = YES;
    self.growingTextView.backgroundColor = [UIColor whiteColor];
    self.growingTextView.text = self.oldUrl;
    self.growingTextView.textColor = [UIColor darkGrayColor];
    self.growingTextView.layer.borderWidth = 1.5;
    self.growingTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.view addSubview:self.growingTextView];
    
    
    [self.growingTextView becomeFirstResponder];
}


- (void)requestSettingUrl {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.aid,
        @"url":self.growingTextView.text
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/aburl" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        NSLog(@"%@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD showMessage:@"设置成功" view:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPhotoManage" object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
    
}

- (NSArray*)getURLFromStr:(NSString *)string {
    NSError *error;
    //可以识别url的正则表达式
    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
    options:NSRegularExpressionCaseInsensitive
    error:&error];

    NSArray *arrayOfAllMatches = [regex matchesInString:string
    options:0
    range:NSMakeRange(0, [string length])];

    //NSString *subStr;
    NSMutableArray *arr=[[NSMutableArray alloc] init];

    for (NSTextCheckingResult *match in arrayOfAllMatches){
        NSString* substringForMatch;
        substringForMatch = [string substringWithRange:match.range];
        [arr addObject:substringForMatch];
    }
    return arr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.growingTextView resignFirstResponder];
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
