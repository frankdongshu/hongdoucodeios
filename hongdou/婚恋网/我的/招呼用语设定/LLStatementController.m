//
//  LLStatementController.m
//  hongdou
//
//  Created by 维康1 on 2020/8/14.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLStatementController.h"

@interface LLStatementController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UITableView *waitTableView;
@property (weak, nonatomic) IBOutlet UITableView *passTableView;
@property (weak, nonatomic) IBOutlet UILabel *showNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *waitNoDataLab;
@property (weak, nonatomic) IBOutlet UILabel *passNoDataLab;

@property (nonatomic, strong) UILabel *placeHolderlabel;

@property (nonatomic, strong) NSMutableArray *waitArray, *passArray;

@end

@implementation LLStatementController

// 提交
- (IBAction)goClick:(id)sender {
    
    [self.textView resignFirstResponder];
    
    [self requestTitleWithContent:self.textView.text];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sc_navigationBar.title = @"招呼用语设定";
    
    @weakify(self);
    self.sc_navigationBar.leftBarButtonItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.waitArray = [NSMutableArray new];
    self.passArray = [NSMutableArray new];
    
    [self setupSomeParamars];
    
    // 请求列表
    [self requestDataList];
    
}

- (void)setupSomeParamars {
    
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDone;
    // 设置边框：
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.borderWidth = .5;
    
    self.placeHolderlabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6 , kScreenWidth , 21)];
    self.placeHolderlabel.font = [UIFont systemFontOfSize:16];
    self.placeHolderlabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
    self.placeHolderlabel.text = @"请在这里输入要设置的招呼语";
    
    [self.textView addSubview:self.placeHolderlabel];
    
    _waitTableView.dataSource = self;
    _waitTableView.delegate = self;
    
    _waitTableView.tableFooterView = [[UIView alloc] init];
    
    _passTableView.dataSource = self;
    _passTableView.delegate = self;
    
    _passTableView.tableFooterView = [[UIView alloc] init];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == _waitTableView) {
        return self.waitArray.count;
    } else {
        return self.passArray.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuse"];
    }
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.selectionStyle = 0;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"home_cha"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 30, 30);
    
    
    if (tableView == self.waitTableView) {
        btn.tag = [self.waitArray[indexPath.row][@"id"] integerValue];
    } else {
        btn.tag = [self.passArray[indexPath.row][@"id"] integerValue];
    }
    
    
    [btn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryView = btn;
    
    
    if (tableView == _waitTableView) {
        cell.textLabel.text = self.waitArray[indexPath.row][@"val"];
    } else {
        cell.textLabel.text = self.passArray[indexPath.row][@"val"];
    }
    
    
    return cell;
}

- (void)deleteBtnClick:(UIButton *)sender {
    
    [self deleteRequestDataWithSid:[NSString stringWithFormat:@"%ld",sender.tag]];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    
    // 字数限制操作
    if ([textView.text length] == 0) {
        [self.placeHolderlabel setHidden:NO];
    }
    else{
        [self.placeHolderlabel setHidden:YES];
    }
    
    self.showNumLabel.text = [NSString stringWithFormat:@"%ld/50",textView.text.length ];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    
    // 如果复制的字数加上原本的字数超过200, 不添加到textView上/ 后期在做超过200字的截取
    NSLog(@"textViewLength: %ld -- textLegth: %ld",textView.text.length, text.length);
    
    if ([text isEqualToString:@"\n"]){
        
        [textView resignFirstResponder];
        //禁止输入换行
        return NO;
    }
    
    
    if (text.length + textView.text.length > 50) {
        
        NSLog(@"%@",textView.text);
        
        return NO;
    }
    
    

    //控制文本输入内容
    if (range.location>=50){
        //控制输入文本的长度
        return  NO;
    }
    
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}

// 删除提交
- (void)deleteRequestDataWithSid:(NSString *)sid {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"sid":sid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/del_syntax" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            [self requestDataList];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 提交内容
- (void)requestTitleWithContent:(NSString *)content {
    
    if (content.length == 0) {
        [MBProgressHUD showMessage:@"您还没有输入文字" view:nil];
        return;
    }
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"val":content
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/add_syntax" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            self.textView.text = @"";
            self.placeHolderlabel.hidden = NO;
            self.showNumLabel.text = @"0/50";
            
            [self requestDataList];
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 请求列表
- (void)requestDataList {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/get_syntax" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        [MBProgressHUD hideLoading];
        NSLog(@"-- %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"]) {
            
            NSArray *reverseWaitArr = [[dictionary[@"data"][@"wait"] reverseObjectEnumerator] allObjects];
            NSArray *reversePassArr = [[dictionary[@"data"][@"adopt"] reverseObjectEnumerator] allObjects];
            
            self.waitArray = [NSMutableArray arrayWithArray:reverseWaitArr];
            self.passArray = [NSMutableArray arrayWithArray:reversePassArr];
            
            if (self.waitArray.count == 0) {
                self.waitNoDataLab.hidden = NO;
            } else {
                self.waitNoDataLab.hidden = YES;
            }
            
            if (self.passArray.count == 0) {
                self.passNoDataLab.hidden = NO;
            } else {
                self.passNoDataLab.hidden = YES;
            }
            
            [self.waitTableView reloadData];
            [self.passTableView reloadData];
            
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
