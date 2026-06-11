//
//  myWK.m
//  hongdou
//
//  Created by 维康1 on 2020/9/23.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "myWK.h"

@implementation myWK

- (instancetype)initWithCoder:(NSCoder *)coder
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    WKWebViewConfiguration *myConfiguration = [WKWebViewConfiguration new];
    self = [super initWithFrame:frame configuration:myConfiguration];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
