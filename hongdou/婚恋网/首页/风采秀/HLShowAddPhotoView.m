//
//  HLShowAddPhotoView.m
//  hongdou
//
//  Created by user on 2022/8/11.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLShowAddPhotoView.h"

@interface HLShowAddPhotoView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headerView;

@end

@implementation HLShowAddPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        [self addSubview:self.headerView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.headerView.frame = CGRectMake(0, kScreenHeight-373, kScreenWidth, 373);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.headerView]) {
        return NO;
    }
    return YES;
}

-(void)showSelf{
    UIWindow *windew = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    [windew addSubview:self];
}

-(void)removeSelf{
    [self removeFromSuperview];
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight+373, kScreenWidth, 373)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        _headerView.layer.cornerRadius = 5;
        _headerView.layer.masksToBounds = YES;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2-60, 15, 120, 40)];
        lab.text = @"上传照片";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:19];
        lab.textColor = kRGBA(63, 70, 88, 1);
        [_headerView addSubview:lab];
        
        [_headerView addSubview:self.imgView];
        
        // 删除按钮
        self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.delBtn setBackgroundImage:[UIImage imageNamed:@"sound_ del"] forState:UIControlStateNormal];
        [self.delBtn addTarget:self action:@selector(delClick) forControlEvents:UIControlEventTouchUpInside];
        self.delBtn.frame = CGRectMake(_imgView.right-25, _imgView.top, 25, 25);
        self.delBtn.hidden = YES;
        [_headerView addSubview:self.delBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imgView.frame)+20, kScreenWidth, 1)];
        lineView.backgroundColor = kRGBA(242, 242, 242, 1);
        [_headerView addSubview:lineView];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(15, CGRectGetMaxY(lineView.frame)+12, 168, 48);
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 24;
        btn.layer.masksToBounds = YES;
        
        btn.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        btn.layer.borderWidth = 1;
        [_headerView addSubview:btn];
        
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.backgroundColor = kRGBA(255, 89, 130, 1);
        [btn1 setTitle:@"确定" forState:UIControlStateNormal];
        btn1.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame)+8, CGRectGetMaxY(lineView.frame)+12, 168, 48);
        [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
        btn1.layer.cornerRadius = 24;
        btn1.layer.masksToBounds = YES;
        
        btn1.right = _headerView.right-15;
        
        btn1.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        btn1.layer.borderWidth = 1;
        [_headerView addSubview:btn1];
        
    }
    return _headerView;
}

// 取消
- (void)btnClick {
    [self removeSelf];
}

- (void)btn1Click {
    
    if (kISNullObject(self.url)) {
        [kAppDelegate.window showTostWithMessage:@"请先上传照片"];
        
        return;
    }
    
    
    [kAppDelegate.window showLoading];

    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":self.url
    };

    [HLHTTPSessionManager postDataWithNSString:@"/album/activityadd" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {

        NSLog(@"--->: %@",dictionary);

        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window showTostWithMessage:@"上传成功"];
            [self.delegate updateList];
            [self removeSelf];
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }

    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
    
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 70, kScreenWidth-40, 200)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.userInteractionEnabled = YES;
        _imgView.backgroundColor = kRGBA(247, 247, 247, 1);
        
        _imgView.layer.cornerRadius = 8;
        _imgView.layer.masksToBounds = YES;
        
        _imgView.layer.borderColor = [kRGBA(221, 221, 221, 1) CGColor];
        _imgView.layer.borderWidth = 1;
        
        
        self.addImg = [[UIImageView alloc] initWithFrame:CGRectMake(_imgView.width/2-12, 44, 24, 24)];
        self.addImg.image = [UIImage imageNamed:@"show_add_photo"];
        
        [_imgView addSubview:self.addImg];
        
        self.lab1 = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.width/2-60, CGRectGetMaxY(self.addImg.frame)+16, 120, 20)];
        self.lab1.text = @"点击上传";
        self.lab1.textAlignment = NSTextAlignmentCenter;
        self.lab1.font = [UIFont systemFontOfSize:14];
        self.lab1.textColor = kRGBA(102, 102, 102, 1);
        [_imgView addSubview:self.lab1];
        
        
        self.lab2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lab1.frame)+8, _imgView.width, 20)];
        self.lab2.text = @"*上传广告、色情等不良照片封号";
        self.lab2.textAlignment = NSTextAlignmentCenter;
        self.lab2.font = [UIFont systemFontOfSize:12];
        self.lab2.textColor = kRGBA(153, 153, 153, 1);
        [_imgView addSubview:self.lab2];
        
        
        self.selbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selbtn.frame = CGRectMake(0, 0, _imgView.width, _imgView.height);
        [self.selbtn addTarget:self action:@selector(addPhotoClick) forControlEvents:UIControlEventTouchUpInside];
        [_imgView addSubview:self.selbtn];
        
    }
    return _imgView;
}

- (void)addPhotoClick {
    
    [self.delegate addPhotoClick];
    
}

// 删除按钮
- (void)delClick {
    
    self.url = @"";
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:@""]];
    
    self.addImg.hidden = NO;
    self.lab1.hidden = NO;
    self.lab2.hidden = NO;
    self.delBtn.hidden = YES;
    self.selbtn.hidden = NO;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
