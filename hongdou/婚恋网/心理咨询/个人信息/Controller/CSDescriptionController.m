//
//  CSDescriptionController.m
//  hongdou
//
//  Created by 李龙 on 2020/3/17.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "CSDescriptionController.h"

@interface CSDescriptionController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation CSDescriptionController

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.textView.frame)+5, kScreenWidth-30, 1)];
        
        _lineView.backgroundColor = [UIColor lightGrayColor];
    }
    return _lineView;
}

-(UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.text = [NSString stringWithFormat:@"%ld/500",self.textView.text.length];
        _nameLabel.font = kScaleFont(14);
        _nameLabel.textColor = [UIColor grayColor];
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, kNavBarHeight+20, kScreenWidth-30, 220)];
        
        _textView.textColor = [UIColor grayColor];
        _textView.font = kFontSize(14);
        
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = @"请输入您的自我描述";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = [UIColor lightGrayColor];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        placeHolderLabel.font = kFontSize(14);
        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        
        _textView.text = kISNullObject([MyLogin getCurrentLoginUser].descr)?@"":[MyLogin getCurrentLoginUser].descr;
    }
    return _textView;
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextClick {
    
    if (self.textView.text.length == 0) {
        [self.view showTostWithMessage:@"请输入您的自我描述"];
    } else {
        [self sure];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self sc_setNavigationBarBackgroundAlpha:0];
    [self setSc_NavigationBarAnimateInvalid:YES];
    
    self.sc_navigationBar.title = @"自我描述";
    
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
    
    titleLabel.text = @"自我描述";

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

- (void)sure {
    
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

-(void)textViewEditChanged:(NSNotification *)notification{
    
    // 拿到文本改变的 text field
    UITextView *textView = (UITextView *)notification.object;
    // 需要限制的长度
    NSUInteger maxLength = 500;
    
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
    self.nameLabel.text = [NSString stringWithFormat:@"%ld/500",textView.text.length];

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
