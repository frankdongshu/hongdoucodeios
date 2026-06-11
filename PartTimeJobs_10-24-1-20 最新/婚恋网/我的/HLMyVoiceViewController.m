//
//  HLMyVoiceViewController.m
//  婚恋网
//
//  Created by iMac on 2019/7/2.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLMyVoiceViewController.h"

@interface HLMyVoiceViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeHolderlabel;
@property (nonatomic, strong) UILabel *showNumLabel;

@property (nonatomic, strong) HXBarButtonItem *leftBarItem;
@property (nonatomic, strong) HXBarButtonItem *rightBarItem;

@end

@implementation HLMyVoiceViewController

-(void)loadView
{
    [super loadView];
    @weakify(self);
    self.leftBarItem = [[HXBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];

    }];
    self.rightBarItem = [[HXBarButtonItem alloc] initWithTitle:@"确认" withColor:[UIColor colorWithHex:0xFF5C79] style:HXBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        if (self.textView.isFirstResponder) {
            [self.textView resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
            if (self.editVoiceBlock) {
                self.editVoiceBlock(self.textView.text);
            }
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.sc_navigationBar.title = @"倾听我心";
    self.sc_navigationBar.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationBar.rightBarButtonItem = self.rightBarItem;
    [self creatUITextView];

}

- (void)creatUITextView{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, 220)];
    self.textView.text = self.myVoiceString;
    self.textView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.0];
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    
    self.placeHolderlabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 6 , kScreenWidth , 21)];
    self.placeHolderlabel.font = [UIFont systemFontOfSize:16];
    self.placeHolderlabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
    self.placeHolderlabel.text = @"这一刻您想说点什么…";
    
    // 字数限制操作
    if ([self.textView.text length] == 0) {
        [self.placeHolderlabel setHidden:NO];
    }
    else{
        [self.placeHolderlabel setHidden:YES];
    }
    
    [self.textView addSubview:self.placeHolderlabel];
    
    self.showNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.textView.frame), kScreenWidth - 15, 20)];
    self.showNumLabel.textAlignment = NSTextAlignmentRight;
    self.showNumLabel.font = [UIFont systemFontOfSize:14];
    self.showNumLabel.textColor = [UIColor colorWithRed:157/255.0 green:164/255.0 blue:174/255.0 alpha:1.0];
    self.showNumLabel.text = @"0/200";
    [self.view addSubview:self.showNumLabel];
}





- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"开始编辑");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"结束编辑");
}

- (void)textViewDidChange:(UITextView *)textView {
    
    // 字数限制操作
    if ([textView.text length] == 0) {
        [self.placeHolderlabel setHidden:NO];
    }
    else{
        [self.placeHolderlabel setHidden:YES];
    }
    
    self.showNumLabel.text = [NSString stringWithFormat:@"%ld/200",textView.text.length ];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    
    // 如果复制的字数加上原本的字数超过200, 不添加到textView上/ 后期在做超过200字的截取
    NSLog(@"textViewLength: %ld -- textLegth: %ld",textView.text.length, text.length);
    if (text.length + textView.text.length > 200) {
        
        NSLog(@"%@",textView.text);
        
        return NO;
    }
    
    

    //控制文本输入内容
    if (range.location>=200){
        //控制输入文本的长度
        return  NO;
    }
    if ([text isEqualToString:@"\n"]){
        //禁止输入换行
        return NO;
    }
    
    return YES;
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
