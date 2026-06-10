//
//  HLNewsSystemTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/24.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLNewsSystemTableViewCell.h"

@interface HLNewsSystemTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;


@end

@implementation HLNewsSystemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.topView az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xBD64FF],[UIColor colorWithHex:0x4B55EA]] locations:@[@(0.0),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1,1)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
