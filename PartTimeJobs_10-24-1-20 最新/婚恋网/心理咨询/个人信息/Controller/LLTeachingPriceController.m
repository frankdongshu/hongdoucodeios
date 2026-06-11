//
//  LLTeachingPriceController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLTeachingPriceController.h"

@interface LLTeachingPriceController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fromTF;
@property (weak, nonatomic) IBOutlet UITextField *toTF;

@end

@implementation LLTeachingPriceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sc_navigationBar.title = @"课时费设置";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"queren_ico"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.fromTF.text.length == 0 || self.toTF.text.length == 0) {
            [self.view showTostWithMessage:@"请填写费用区间"];
        } else if ([self.fromTF.text intValue] > [self.toTF.text intValue]) {
            [self.view showTostWithMessage:@"最低费用不能高于最高费用"];
        } else {
            if (self.priType == PriceFaBuType) {
                self.priceBlock(self.fromTF.text, self.toTF.text);
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self sureClick];
            }
            
        }
             
    }];
    
    self.fromTF.text = self.fromString;
    self.toTF.text = self.toString;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 获取当前文本内容
    NSString *current = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return current.length <= 5;
    
}

// 提交授课费用
- (void)sureClick {
    
    [kAppDelegate.window showLoading];
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"cost1":self.fromTF.text,
        @"cost2":self.toTF.text
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/cost" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        [kAppDelegate.window hideLoading];
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.cost_low = self.fromTF.text;
            u.cost_high = self.toTF.text;
            [MyLogin updateUser:u];

            self.sureBlock();
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [self.view showTostWithMessage:dictionary[@"msg"]];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        
        [self.view showTostWithMessage:@"请求失败"];

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
