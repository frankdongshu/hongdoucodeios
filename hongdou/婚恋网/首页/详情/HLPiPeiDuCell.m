//
//  HLPiPeiDuCell.m
//  hongdou
//
//  Created by 李龙 on 2020/6/23.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLPiPeiDuCell.h"

@implementation HLPiPeiDuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    circle2 = [[ZZCircleProgress alloc] initWithFrame:CGRectMake(xCrack*2+itemWidth, yCrack, itemWidth, itemWidth) pathBackColor:nil pathFillColor:ZZRGB(arc4random()%255, arc4random()%255, arc4random()%255) startAngle:0 strokeWidth:10];
//    circle2.progress = 0.6;
//    circle2.showPoint = NO;
//    circle2.animationModel = CircleIncreaseSameTime;
//    [self.view addSubview:circle2];
    
    self.circleView.pathBackColor = kRGBA(244, 244, 249, 1);
    self.circleView.pathFillColor = kRGBA(255, 126, 153, 1);
    self.circleView.startAngle = -90;
    self.circleView.strokeWidth = 8;
    self.circleView.progress = 0.3;
    self.circleView.showProgressText = YES;
    self.circleView.showPoint = NO;
    self.circleView.animationModel = CircleIncreaseSameTime;
    
    
    self.desLab.layer.cornerRadius = 6.f;
    self.desLab.layer.masksToBounds = YES;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
