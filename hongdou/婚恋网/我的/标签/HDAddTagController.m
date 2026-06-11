//
//  HDAddTagController.m
//  hongdou
//
//  Created by 维康1 on 2020/6/16.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HDAddTagController.h"

@interface HDAddTagController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) NSInteger textNum;

@end

@implementation HDAddTagController

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
        _nameLabel.text = [NSString stringWithFormat:@"0/%ld",(_textNum > 0? _textNum: 10)];
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
        placeHolderLabel.text = @"请编写标签";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = [UIColor lightGrayColor];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        placeHolderLabel.font = kFontSize(14);
        [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    }
    return _textView;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sc_navigationBar.title = @"添加标签";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.sc_navigationBar.rightBarButtonItem = [[HXBarButtonItem alloc] initWithTitle:@"完成" withColor:kHYLColor(255, 92, 121, 1) style:HXBarButtonItemStylePlain handler:^(id sender) {
        
        NSDictionary *dic = @{
            @"uid":[LoginManager defaultManager].userid,
            @"type":self.typeString,
            @"label":self.textView.text
        };
        
        
        WeakSelf(weakSelf);
        [HLHTTPSessionManager postDataWithNSString:@"/user/add_label" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
            
            NSLog(@"-- %@",dictionary);
            
            NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
            if ([code isEqualToString:@"200"] ) {
                
                [self.selectArray addObject:self.textView.text]; // 选标签页
                [self.tagArray addObject:self.textView.text]; // 用于标签首页
                
                [self.navigationController popViewControllerAnimated:YES];
                
                
            }else {
                [weakSelf.view showTostWithMessage:[dictionary objectForKey:@"msg"]];
            }
        } failure:^(NSError * _Nonnull error) {
            [weakSelf.view showTostWithMessage:error.localizedDescription];
        }];
        
    }];
    
    
    [self.view addSubview:self.textView];
    
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).mas_offset(5);
        make.right.equalTo(self.lineView.mas_right).mas_offset(-5);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)textViewEditChanged:(NSNotification *)notification{
    
    // 拿到文本改变的 text field
    UITextView *textView = (UITextView *)notification.object;
    // 需要限制的长度
    NSUInteger maxLength = (_textNum > 0? _textNum: 10);
    
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
    self.nameLabel.text = [NSString stringWithFormat:@"%ld/%ld",textView.text.length,(_textNum > 0? _textNum: 10)];

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
