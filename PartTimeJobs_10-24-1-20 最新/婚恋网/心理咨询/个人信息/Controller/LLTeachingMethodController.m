//
//  LLTeachingMethodController.m
//  PartTimeJobs
//
//  Created by 维康1 on 2020/5/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLTeachingMethodController.h"

@interface LLTeachingMethodController ()

@end

@implementation LLTeachingMethodController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sc_navigationBar.title = @"授课方式";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    NSLog(@"%@",self.dataArray);
    
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[NSString stringWithFormat:@"%@",obj] isEqualToString:@""]) {
            [self.dataArray removeObject:[NSString stringWithFormat:@"%@",obj]];
        }
    }];
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"queren_ico"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if (self.dataArray.count == 0) {
            [self.view showTostWithMessage:@"请选择授课方式"];
        } else {
            if (self.teaType == FaBuType) {
                
                self.teachingBlock([self.dataArray componentsJoinedByString:@","]);
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self sureClick];
            }
            
        }
                
    }];
    
    [self creatView];
}

// 创建按钮视图
- (void)creatView {
    
    CGFloat viewCenterY = self.view.frame.size.height/self.listArray.count;
    
    for (int i=0; i<self.listArray.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.listArray[i][@"val"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        btn.layer.borderWidth = .5;
        btn.layer.cornerRadius = 20;
        
        if ([self.dataArray containsObject:self.listArray[i][@"val"]]) {
            btn.selected = YES;
        }
        
        if (btn.selected) {
            btn.backgroundColor = REDColor;
            btn.layer.borderWidth = 0;
        }
        
        [self.view addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(self.view);
            
            make.top.equalTo(self.view).mas_offset(i*40+i*43+viewCenterY);
            make.size.mas_equalTo(CGSizeMake(220,40));
        }];
        
        
    }
    
}

- (void)selectClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self.dataArray addObject:sender.titleLabel.text];
        
        sender.backgroundColor = REDColor;
        sender.layer.borderWidth = 0;
    } else {
        [self.dataArray removeObject:sender.titleLabel.text];
        
        sender.backgroundColor = [UIColor whiteColor];
        sender.layer.borderWidth = .5;
    }
    
}

// 提交授课方式
- (void)sureClick {
    
    [kAppDelegate.window showLoading];
    
    NSLog(@"%@",self.dataArray);
    NSLog(@"%@",[self.dataArray componentsJoinedByString:@","]);
    
    NSDictionary *parmas = @{
        @"uid":[MyLogin getCurrentLoginUser].userid,
        @"token":[MyLogin getCurrentLoginUser].token,
        @"teaching":[self.dataArray componentsJoinedByString:@","]
    };

    [HTTPSessionManger postDataWithNSString:@"/coach/teaching" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        [kAppDelegate.window hideLoading];
        
        NSLog(@"%@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            MyLogin *u = [MyLogin getCurrentLoginUser];
            u.teaching = [self.dataArray componentsJoinedByString:@","];
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
