//
//  HLNewUserView.m
//  hongdou
//
//  Created by 维康1 on 2021/1/18.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "HLNewUserView.h"

@implementation HLNewUserView

- (void)awakeFromNib{
    [super awakeFromNib];
    
}

+(instancetype)initWithXib:(CGRect)frame  delegate:(id<HLNewUserViewDeleagte>)delegate{
    HLNewUserView *view = [[UINib nibWithNibName:NSStringFromClass([HLNewUserView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    view.delegate = delegate;
    [view awakeFromNib];
    return view;
}

// 关闭
- (IBAction)closeClick:(id)sender {
    
    [self removeSelf];
    
}

// 立即领取
- (IBAction)goBtnClick:(id)sender {
    
    [self removeSelf];
    
    [self.delegate sureButtonClick];
    
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
