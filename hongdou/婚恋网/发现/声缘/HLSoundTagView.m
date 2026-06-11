//
//  HLSoundTagView.m
//  hongdou
//
//  Created by 李龙 on 2021/12/12.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLSoundTagView.h"
#import "SKTagView.h"

@interface HLSoundTagView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) SKTagView *tagView;

@property (nonatomic, strong) NSMutableArray *tagArray, *selectArray;

@end

@implementation HLSoundTagView

- (instancetype)initWithFrame:(CGRect)frame andArr:(NSMutableArray *)arr {
    if ([super initWithFrame:frame]) {
        
        _selectArray = arr;
        
        [self addSubview:self.headerView];
        [self addSubview:self.tagView];
        
        [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
        }];
        
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.tagView.mas_top).equalTo(@10);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.height.mas_equalTo(60);
        }];
        
        [self requestSoundTagList];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isDescendantOfView:self.tagView] || [touch.view isDescendantOfView:self.headerView]) {
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
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        _headerView.layer.cornerRadius = 10;
        _headerView.layer.masksToBounds = YES;
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(0, 0, 70, 50);
        btn1.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn1 setTitle:@"取消" forState:UIControlStateNormal];
        [btn1 setTitleColor:kRGBA(64, 70, 87, 1) forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
        
        [_headerView addSubview:btn1];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kScreenWidth-70, 0, 70, 50);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:kRGBA(97, 117, 246, 1) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(confirmClick) forControlEvents:UIControlEventTouchUpInside];
        
        [_headerView addSubview:btn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreenWidth, .5)];
        lineView.backgroundColor = kRGBA(232, 232, 232, 1);
        
        [_headerView addSubview:lineView];
        
    }
    return _headerView;
}

// 确认
- (void)confirmClick {
    [self removeSelf];
    self.SelectBlock(self.tagArray);
}

- (SKTagView *)tagView {
    if (!_tagView) {
        _tagView = [[SKTagView alloc] init];
        _tagView.backgroundColor = [UIColor whiteColor];
        _tagView.preferredMaxLayoutWidth = kScreenWidth;
        _tagView.padding = UIEdgeInsetsMake(20, 20, kSafeAreaBottom+15, 20);
        _tagView.lineSpacing = 12;
        _tagView.interitemSpacing = 12;
        _tagView.singleLine = NO;
        // 给出两个字段，如果给的是0，那么就是变化的,如果给的不是0，那么就是固定的
//        cell.tagView.regularWidth = 80;
        _tagView.regularHeight = 30;
        
    }
    return _tagView;
}

- (void)requestSoundTagList {
    
    [MBProgressHUD showLoading];
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:@"/index/get_vw_label" withDictionary:@{} success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            NSArray *arr = dictionary[@"data"];
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                SKTag *tag = [[SKTag alloc] initWithText:arr[idx]];
                tag.font = [UIFont systemFontOfSize:14];
                
                if ([self.selectArray containsObject:arr[idx]]) {
                    [self.tagArray addObject:arr[idx]];
                    
                    tag.textColor = kRGBA(188, 96, 255, 1);
                    tag.bgColor = kRGBA(251, 240, 255, 1);
                } else {
                    tag.textColor = kRGBA(155, 156, 161, 1);
                    tag.bgColor = kRGBA(234, 235, 236, 1);
                }
                
                
                
                tag.cornerRadius = 15;
                tag.enable = YES;
                tag.padding = UIEdgeInsetsMake(5, 22, 5, 22);
                [self.tagView addTag:tag];
                
            }];
            
            self.tagView.didTapTagAtIndex = ^(NSUInteger index, UIButton *btn) {
                
                
                if (![weakSelf.tagArray containsObject:arr[index]]) {
                    [weakSelf.tagArray addObject:arr[index]];
                    
                    [btn setTitleColor:kRGBA(188, 96, 255, 1) forState:UIControlStateNormal];
                    btn.backgroundColor = kRGBA(251, 240, 255, 1);
                } else {
                    
                    [weakSelf.tagArray removeObject:arr[index]];
                    
                    [btn setTitleColor:kRGBA(155, 156, 161, 1) forState:UIControlStateNormal];
                    btn.backgroundColor = kRGBA(234, 235, 236, 1);
                }
                
            };
            
        } else {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

- (NSMutableArray *)tagArray {
    if (!_tagArray) {
        _tagArray = [[NSMutableArray alloc] init];
    }
    return _tagArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
