//
//  HLShortVedeoPopView.m
//  hongdou
//
//  Created by 李龙 on 2021/12/22.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLShortVedeoPopView.h"

@interface HLShortVedeoPopView ()<UIGestureRecognizerDelegate>{
    NSString *_type;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoBtn;
@property (weak, nonatomic) IBOutlet UIButton *threeBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation HLShortVedeoPopView


- (IBAction)uploadClick:(id)sender {
    
    [self endEditing:YES];
    
    if (kISNullObject(_type)) {
        [MBProgressHUD showMessage:@"请选择投诉类型" view:kAppDelegate.window];
        return;
    }
    if (self.textView.text.length == 0) {
        [MBProgressHUD showMessage:@"请描述投诉内容" view:kAppDelegate.window];
        return;
    }
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"vid":self.vid,
        @"type":_type,
        @"txt":self.textView.text,
        @"title":@"title"
    };
    
    
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/share" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"~~~: %@",dictionary);
        
        if ([[dictionary[@"code"] stringValue] isEqualToString:@"200"]) {
            
            [MBProgressHUD showSuccess:@"提交成功" toView:kAppDelegate.window];
            
            [self removeSelf];
            
        } else {
            [MBProgressHUD showSuccess:dictionary[@"msg"] toView:kAppDelegate.window];
        }

        

    } failure:^(NSError * _Nonnull error) {

    }];
    
}

- (IBAction)oneClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        _type = @"1";
        self.twoBtn.selected = NO;
        self.threeBtn.selected = NO;
    }
    
}
- (IBAction)twoClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        _type = @"2";
        self.oneBtn.selected = NO;
        self.threeBtn.selected = NO;
    }
}
- (IBAction)threeClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        _type = @"3";
        self.twoBtn.selected = NO;
        self.oneBtn.selected = NO;
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = .5;
    
    [self.uploadBtn setBackgroundImage:[UIImage imageNamed:@"topic_zi"] forState:UIControlStateNormal];
    self.uploadBtn.layer.cornerRadius = 18;
    self.uploadBtn.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.bgView]) {
        return NO;
    }
    return YES;
}

+(instancetype)initWithXib:(CGRect)frame {
    HLShortVedeoPopView *view = [[UINib nibWithNibName:NSStringFromClass([HLShortVedeoPopView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    [view awakeFromNib];
    return view;
}

- (void)sureClick:(UIButton *)sender {
    
    if (sender.tag == 222) {
        [self removeSelf];
    } else {
        [self removeSelf];
        self.SelectBlock();
    }
    
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
