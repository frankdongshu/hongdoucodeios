//
//  HXActionSheet.m
//  HXActionSheet
//
//  Created by iMac on 16/6/1.
//  Copyright © 2016年 TheLittleBoy. All rights reserved.
//

#import "HXActionSheet.h"
#import "UIImage+ImageWithColor.h"
#import "NSObject+BKBlockExecution.h"

#define TEXT_BLACK_COLOR    [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00]
#define WINDOW_COLOR        [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define ANIMATE_DURATION    0.25f

@interface HXActionSheet ()
{
    CGFloat backgroundHeight;
}
@property (nonatomic,strong) UIView *backGroundView;
@property (nonatomic,strong) UIVisualEffectView * blureffectbackGroundView;
@property (nonatomic,strong) NSLayoutConstraint * backGroundViewBottomConstraint;

@end

@implementation HXActionSheet

- (void)show
{
    [self showInView:[UIApplication sharedApplication].delegate.window];
}

-(void)showInView:(UIView *)view{
    
    if (self.superview) {
        return;
    }
    
    [view addSubview:self];

    NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-10)-[self]-(-10)-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(self)];
    
    NSArray *constraints2=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[self]-0-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(self)];
    
    [view addConstraints:constraints1];
    [view addConstraints:constraints2];
    
    
    _backGroundViewBottomConstraint.constant = 0;
    
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        
        self.backgroundColor = WINDOW_COLOR;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (id)initWithTitle:(NSString *)title delegate:(id<HXActionSheetDelegate>)delegate otherButtons:(NSArray *)buttons cancelButton:(NSString *)cancelButton{
    self = [super init];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        
        self.userInteractionEnabled = YES;
        self.translatesAutoresizingMaskIntoConstraints=NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        BOOL isHasTitle = title && title.length;
        //计算高度
        backgroundHeight = (isHasTitle?30:0) + 55 * buttons.count + 20;
        if (cancelButton) {
            backgroundHeight += 55;
        }
        if (IS_iPhoneX) {
            backgroundHeight += 14;  //只需要加14px即可满足需求
        }
        
        self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, backgroundHeight)];
        self.backGroundView.backgroundColor = [UIColor clearColor];
        self.backGroundView.translatesAutoresizingMaskIntoConstraints=NO;
        [self addSubview:self.backGroundView];
        
        NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_backGroundView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_backGroundView)];
        
        _backGroundViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_backGroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-50];
        
        NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:_backGroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:backgroundHeight];
        
        [self addConstraints:constraints1];
        [self addConstraint:_backGroundViewBottomConstraint];
        [self addConstraint:constraint3];
        
        //生成HXActionSheetView
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        self.blureffectbackGroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blureffectbackGroundView.frame = CGRectMake(0, 0, screenWidth, backgroundHeight);
        self.blureffectbackGroundView.translatesAutoresizingMaskIntoConstraints=NO;
        [self.backGroundView addSubview:self.blureffectbackGroundView];
        
        NSArray *constraints4=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_blureffectbackGroundView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_blureffectbackGroundView)];
        
        NSArray *constraints5=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_blureffectbackGroundView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_blureffectbackGroundView)];
        
        [self.backGroundView addConstraints:constraints4];
        [self.backGroundView addConstraints:constraints5];
                
        UILabel *titleLabel = [[UILabel alloc] init];
        
        if (isHasTitle) {
            [titleLabel setTextColor:TEXT_BLACK_COLOR];
            [titleLabel setFont:[UIFont systemFontOfSize:14]];
            titleLabel.frame = CGRectMake(0, 15, screenWidth, 15);
            titleLabel.text = title;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.translatesAutoresizingMaskIntoConstraints=NO;
            [_blureffectbackGroundView.contentView addSubview:titleLabel];
            
            NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleLabel]-0-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(titleLabel)];
            
            NSLayoutConstraint * constraint2 = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_blureffectbackGroundView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
            
            NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:15];
            
            [self addConstraints:constraints1];
            [self addConstraint:constraint2];
            [self addConstraint:constraint3];
        }
        
        UIView * topView;
        if (isHasTitle) {
            topView = titleLabel;
        }
        
        for (int i = 0; i < buttons.count; i ++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.translatesAutoresizingMaskIntoConstraints=NO;
            [_blureffectbackGroundView.contentView addSubview:btn];
            [btn setTitle:buttons[i] forState:UIControlStateNormal];
            [btn setTitleColor:TEXT_BLACK_COLOR forState:UIControlStateNormal];
            btn.layer.masksToBounds = YES;
            [btn.layer setCornerRadius:3.0f];
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            btn.tag = i;
            btn.frame = CGRectMake(15, titleLabel.frame.origin.y + titleLabel.frame.size.height + 15 + 50 * i, screenWidth - 30, 40);
            
            NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[btn]-25-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(btn)];
            
            NSLayoutConstraint * constraint2;
            if (topView) {
                constraint2 = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1 constant:15];
            }else
            {
                constraint2 = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_blureffectbackGroundView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
            }
            
            NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
            
            [_blureffectbackGroundView addConstraints:constraints1];
            [_blureffectbackGroundView addConstraint:constraint2];
            [_blureffectbackGroundView addConstraint:constraint3];
            
            topView = btn;
        }
        
        if (cancelButton) {
            //创建取消按钮
            UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [cancelBtn addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
            cancelBtn.translatesAutoresizingMaskIntoConstraints=NO;
            [_blureffectbackGroundView.contentView addSubview:cancelBtn];
            cancelBtn.layer.masksToBounds = YES;
            [cancelBtn.layer setCornerRadius:3.0f];
            [cancelBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            cancelBtn.tag = buttons.count;
            [cancelBtn setTitle:cancelButton forState:UIControlStateNormal];
            [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            cancelBtn.frame = CGRectMake(15, titleLabel.frame.origin.y + titleLabel.frame.size.height + 15 + 50 * buttons.count, screenWidth - 30, 40);
            
            NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[cancelBtn]-25-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(cancelBtn)];
            
            NSLayoutConstraint * constraint2;
            if (topView) {
                constraint2 = [NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1 constant:15];
            }else
            {
                constraint2 = [NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_blureffectbackGroundView attribute:NSLayoutAttributeTop multiplier:1 constant:15];
            }
            
            NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:cancelBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
            
            [_blureffectbackGroundView addConstraints:constraints1];
            [_blureffectbackGroundView addConstraint:constraint2];
            [_blureffectbackGroundView addConstraint:constraint3];
        }
        
    }
    
    return self;
}

- (void)buttonClick:(UIButton *)sender{
    
    [self bk_performAfterDelay:ANIMATE_DURATION usingBlock:^(id  _Nonnull obj) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(hxActionSheet:clickedButtonAtIndex:)]) {
            
            [self.delegate hxActionSheet:self clickedButtonAtIndex:sender.tag];
        }
    }];
    
    [self dismissWithAnimate:YES];
}

- (void)tappedCancel{
    
    [self bk_performAfterDelay:ANIMATE_DURATION usingBlock:^(id  _Nonnull obj) {
        
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(hxAtionSheetCancel:)]) {
                [self.delegate hxAtionSheetCancel:self];
            }
        }
    }];

    [self dismissWithAnimate:YES];
}

- (void)dismissWithAnimate:(BOOL)animate
{
    if (animate) {
        _backGroundViewBottomConstraint.constant = backgroundHeight;

        [UIView animateWithDuration:ANIMATE_DURATION  animations:^{

            self.alpha = 0;
            [self layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
    }else
    {
        [self removeFromSuperview];
    }
}

@end
