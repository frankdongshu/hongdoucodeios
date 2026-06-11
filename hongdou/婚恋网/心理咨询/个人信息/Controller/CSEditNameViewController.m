//
//  CSEditNameViewController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSEditNameViewController.h"

@interface CSEditNameViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) NSInteger textNum;


@end

@implementation CSEditNameViewController

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.textView.frame)+5, kScreenWidth-30, 1)];
        
        _lineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _lineView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.text = [NSString stringWithFormat:@"0/%ld",(_textNum > 0? _textNum: 35)];
        _nameLabel.font = kScaleFont(14);
        _nameLabel.textColor = [UIColor grayColor];
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, kNavBarHeight+20, kScreenWidth-30, 35)];
        _textView.textColor = [UIColor grayColor];
        _textView.font = kFontSize(14);
        _textView.delegate = self;
        
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = [NSString stringWithFormat:@"请输入%@",self.titleString];
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = [UIColor lightGrayColor];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        placeHolderLabel.font = kFontSize(14);
        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    }
    return _textView;
}

-(void)setPageType:(PageType)pageType{
    _pageType = pageType;
    _textNum = 35;
    if (pageType == DiscriPage) {
        _textNum = 500;
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].description)?@"":[MyLogin getCurrentLoginUser].description;
    }
    if (pageType == AphorismPage) {
        _textNum = 50;
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].motto)?@"":[MyLogin getCurrentLoginUser].motto;
    }
    if (pageType == SchoolPage) {
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].school)?@"":[MyLogin getCurrentLoginUser].school;
    }
    if (pageType == MajorPage) {
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].major)?@"":[MyLogin getCurrentLoginUser].major;
    }
    if (pageType == NickNamePage) {
        self.textView.text = [MyLogin getCurrentLoginUser].nickname;
    }
    if (pageType == WeChatPage) {
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].wx)?@"":[MyLogin getCurrentLoginUser].wx;
    }
    if (pageType == QQPage) {
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].qq)?@"":[MyLogin getCurrentLoginUser].qq;
    }
    if (pageType == PhonePage) {
        self.textView.text = kISNullObject([MyLogin getCurrentLoginUser].contact)?@"":[MyLogin getCurrentLoginUser].contact;
    }
    
    [self textViewDidChange:self.textView];
    self.nameLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.textView.text.length,_textNum];
}

//自动调节输入文本框的高度

- (void)textViewDidChange:(UITextView *)textView {

    float height;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {

        CGRect textFrame = [[self.textView layoutManager] usedRectForTextContainer:[self.textView textContainer]];

        height = textFrame.size.height;

    }

    else{

        height = self.textView.contentSize.height;

    }

    self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, height+15);
    
    self.lineView.frame = CGRectMake(15, CGRectGetMaxY(self.textView.frame)+5, kScreenWidth-30, 1);

}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextClick {
    
    if (self.textView.text.length == 0) {
        [self.view showTostWithMessage:[NSString stringWithFormat:@"请输入%@",self.titleString]];
    } else {
        [self sure];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.title = self.titleString;
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"确定" withColor:[UIColor darkGrayColor] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self nextClick];
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];

    titleLabel.font = [UIFont systemFontOfSize:16];

    titleLabel.textColor = [UIColor blackColor];

    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    titleLabel.text = self.titleString;

    self.navigationItem.titleView = titleLabel;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(nextClick)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [self.view addSubview:self.textView];
    
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).mas_offset(5);
        make.right.equalTo(self.lineView.mas_right).mas_offset(-5);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

// 确定
- (void)sure {
    
    if (_pageType == NickNamePage) { // 设置昵称
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"nickname",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.nickname = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    if (_pageType == SchoolPage) { // 设置学校
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"school",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.school = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    if (_pageType == MajorPage) { // 设置专业
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"major",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.major = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
        
    }
    
    if (_pageType == DiscriPage) { // 自我介绍
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"description",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.descr = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    if (_pageType == AphorismPage) { // 职业格言
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"motto",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.motto = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    if (_pageType == WeChatPage) { // 设置微信
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"wx",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.wx = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    if (_pageType == QQPage) { // 设置QQ
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"qq",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.qq = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
    if (_pageType == PhonePage) { // 设置手机号
        
        NSDictionary *parmas = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":@"contact",
            @"var":self.textView.text
        };
        
        [HLHTTPSessionManager postDataWithNSString:@"/mind/modify_information" withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"/mind/modify_information: %@",dictionary);
            
            if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
                
                MyLogin *u = [MyLogin getCurrentLoginUser];
                u.contact = self.textView.text;
                [MyLogin updateUser:u];
                
                self.sureBlock();
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self.view showTostWithMessage:dictionary[@"msg"]];
            }
            
            
        } failure:^(NSError * _Nonnull error) {
            [MBProgressHUD showMessage:error.localizedDescription view:nil];
        }];
        
    }
    
}

- (void)textViewEditChanged:(NSNotification *)notification {
    
    // 拿到文本改变的 text field
    UITextView *textView = (UITextView *)notification.object;
    // 需要限制的长度
    NSUInteger maxLength = (_textNum > 0? _textNum: 35);
    
    // text field 的内容
    NSString *contentText = textView.text;
    
    // 获取高亮内容的范围
    UITextRange *selectedRange = [textView markedTextRange];
    // 这行代码 可以认为是 获取高亮内容的长度
    NSInteger markedTextLength = [textView offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
    // 没有高亮内容时,对已输入的文字进行操作
    if (markedTextLength == 0) {
        // 如果 text field 的内容长度大于我们限制的内容长度
        if (contentText.length > maxLength) {
            // 截取从前面开始maxLength长度的字符串
            //            textField.text = [contentText substringToIndex:maxLength];
            // 此方法用于在字符串的一个range范围内，返回此range范围内完整的字符串的range
            NSRange rangeRange = [contentText rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
            textView.text = [contentText substringWithRange:rangeRange];
        }
    }
    self.nameLabel.text = [NSString stringWithFormat:@"%ld/%ld",textView.text.length,(_textNum > 0? _textNum: 35)];

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
