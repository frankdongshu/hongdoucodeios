//
//  HLAddressController.m
//  hongdou
//
//  Created by 维康1 on 2020/12/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLAddressController.h"

@interface HLAddressController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *phoneTf;
@property (weak, nonatomic) IBOutlet UITextView *addTextView;
@property (weak, nonatomic) IBOutlet UIView *updateView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *addLab;


@property (nonatomic, strong) HXBarButtonItem *updateRightItem, *doneRightItem;

@end

@implementation HLAddressController

- (HXBarButtonItem *)updateRightItem {
    if (!_updateRightItem) {
        
        @weakify(self);
        _updateRightItem = [[HXBarButtonItem alloc] initWithTitle:@"修改" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            
            self.sc_navigationBar.rightBarButtonItem = self.doneRightItem;
            
            self.nameLab.hidden = YES;
            self.addLab.hidden = YES;
            self.updateView.hidden = NO;
            
        }];
    }
    return _updateRightItem;
}

- (HXBarButtonItem *)doneRightItem {
    if (!_doneRightItem) {
        
        @weakify(self);
        _doneRightItem = [[HXBarButtonItem alloc] initWithTitle:@"完成" withColor:[UIColor blackColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            
            // 添加或修改地址
            [self requestUpdateAddress];
            
        }];
    }
    return _doneRightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sc_navigationBar.title = @"邮寄地址";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    self.nameTf.layer.borderWidth = .7;
    self.nameTf.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.phoneTf.layer.borderWidth = .7;
    self.phoneTf.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    // _placeholderLabel
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"详细地址: 如道路、门牌号、小区、楼栋号、单元室等";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [self.addTextView addSubview:placeHolderLabel];

    // same font
    placeHolderLabel.font = [UIFont systemFontOfSize:14];

    [self.addTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    
    self.addTextView.layer.borderWidth = .7;
    self.addTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    
    // 获取邮寄地址
    [self requestShowAddress];
    
}

/// 展示邮寄地址
- (void)requestShowAddress {
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [MBProgressHUD showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_address" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"===%@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            self.sc_navigationBar.rightBarButtonItem = self.updateRightItem;
            
            self.updateView.hidden = YES;
            self.nameLab.hidden = NO;
            self.addLab.hidden = NO;
            
            self.nameLab.text = [NSString stringWithFormat:@"%@    %@",dictionary[@"data"][@"name"],dictionary[@"data"][@"phone"]];
            self.addLab.text = dictionary[@"data"][@"address"];
            
            
            self.nameTf.text = dictionary[@"data"][@"name"];
            self.phoneTf.text = dictionary[@"data"][@"phone"];
            self.addTextView.text = dictionary[@"data"][@"address"];
            
        } else { // 202 没有设置邮寄地址, 取消隐藏设置界面
            
            self.sc_navigationBar.rightBarButtonItem = self.doneRightItem;
            
            self.nameLab.hidden = YES;
            self.addLab.hidden = YES;
            self.updateView.hidden = NO;
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

/// 添加或修改地址
- (void)requestUpdateAddress {
    
    [self.view endEditing:YES];
    
    if (self.nameTf.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入名字" view:self.view];
        return;
    }
    if (self.phoneTf.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入手机号" view:self.view];
        return;
    }
    if (self.addTextView.text.length == 0) {
        [MBProgressHUD showMessage:@"请输入详细地址" view:self.view];
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"name":self.nameTf.text,
        @"phone":self.phoneTf.text,
        @"address":self.addTextView.text
    };
    
    [MBProgressHUD showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/user/add_address" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        
        NSLog(@"===%@",dictionary);
        
        if ([[[dictionary objectForKey:@"code"] stringValue] isEqualToString:@"200"]) {
            
            // 是否添加过邮寄地址
            [self requestShowAddress];
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
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
