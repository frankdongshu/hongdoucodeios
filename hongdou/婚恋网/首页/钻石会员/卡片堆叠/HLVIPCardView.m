//
//  HLVIPCardView.m
//  hongdou
//
//  Created by 维康1 on 2020/9/8.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLVIPCardView.h"

@implementation HLVIPCardView

+ (instancetype)initWithXib:(CGRect)frame delegate:(id<HLVIPCardViewDelegate>)delegate {
    HLVIPCardView *view = [[UINib nibWithNibName:NSStringFromClass([HLVIPCardView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    view.delegate = delegate;
    [view awakeFromNib];
    
    [view.shareBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [view.followBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    [view.chatBtn layoutButtonWithEdgeInsetsStyle:LXButtonEdgeInsetsStyleTop imageTitleSpace:5];
    
    return view;
}

- (IBAction)shareClick:(id)sender {
    
    [self.delegate shareVipClick];
}
- (IBAction)chatClick:(id)sender {
    
    [self.delegate chatVipClick];
}
- (IBAction)followClick:(id)sender {
    
    [self.delegate followVipClick];
}
- (IBAction)settingClick:(id)sender {
    
    [self.delegate settingVipClick];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
