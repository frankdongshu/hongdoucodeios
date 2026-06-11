//
//  HLHerWishController.m
//  hongdou
//
//  Created by 李龙 on 2021/12/21.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLHerWishController.h"
#import "HLMyWishController.h"

@interface HLHerWishController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *leftLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic, strong) NSString *wishId;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;

@end

@implementation HLHerWishController


- (IBAction)btnClick:(id)sender {
    [self zhuliClick];
    
}

// 红豆剩余
- (IBAction)weihaoClick:(id)sender {
    
}

// 如何获得红豆
- (IBAction)youjiClick:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"我的心愿" withColor:kRGBA(255, 92, 120, 1) style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        HLMyWishController *vc = [[HLMyWishController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    self.sc_navigationBar.title = [NSString stringWithFormat:@"%@的心愿",kISNullObject(self.theName)?@"ta":self.theName];
    
    self.btn.layer.cornerRadius = self.btn.height/2;
    self.btn.layer.masksToBounds = YES;
    
    [self.btn az_setGradientBackgroundWithColors:@[kRGB(255, 174, 157),kRGB(255, 112, 152)] locations:@[@(0),@(.8),@(0),@(0)] startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    
    [self loadNewData];
    
}

- (void)loadNewData {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"wid":self.theId
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/getinwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"pic"]]];
            
            NSString *string = [NSString stringWithFormat:@"已有%@人帮他助力",dictionary[@"data"][@"hpc"]];
            NSString *string1 = [NSString stringWithFormat:@"%@人",dictionary[@"data"][@"hpc"]];
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
            [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[string rangeOfString:string1]];
            self.leftLab.attributedText = text;
            
            
            int i = [dictionary[@"data"][@"price"] intValue]- [dictionary[@"data"][@"sy"] intValue];
            
            NSString *stringNum = [NSString stringWithFormat:@"%d/%@红豆",i,dictionary[@"data"][@"price"]];
            NSString *stringNum1 = [NSString stringWithFormat:@"%d/",i];
            
            
            NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:stringNum];
            
            [text1 addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 92, 120, 1) range:[stringNum rangeOfString:stringNum1]];
            
            
            self.rightLab.attributedText = text1;
            
            
            [self.topBtn setTitle:[NSString stringWithFormat:@"红豆剩余: %@ 购买",dictionary[@"data"][@"mebean"]] forState:UIControlStateNormal];
            
            self.wishId = dictionary[@"data"][@"id"];
            
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

    }];
    
    
}

- (void)zhuliClick {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"puid":self.wishId
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/product/helpwish" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            [self loadNewData];
        } else {
            [self.view showTitle:dictionary[@"msg"]];
        }

        

    } failure:^(NSError * _Nonnull error) {

        [self.view showErrorWithMessage:[error localizedDescription]];

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
