//
//  HLConstellationCell.m
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLConstellationCell.h"

@implementation HLConstellationCell

// 没数据显示 - , 而不是显示null
- (NSString *)getDataString:(NSString *)string {
    
    NSString *dataStr = kISNullObject(string)?@" - ":string;
    
    return dataStr;
}


- (void)setTheDic:(NSDictionary *)theDic {
    _theDic = theDic;
    
    self.oneLab.text = [NSString stringWithFormat:@"男%@与女%@  %@",[self getDataString:theDic[@"men"]],[self getDataString:theDic[@"women"]],[self getDataString:theDic[@"jieguo"]]];
    
    
    self.pdStarView.scorePercent = [theDic[@"zhishu"] floatValue]*0.2;
    self.pdStarView.allowIncompleteStar = YES;
    self.lqStarView.scorePercent = [theDic[@"xiangyue"] floatValue]*0.2;
    self.lqStarView.allowIncompleteStar = YES;
    self.tcStarView.scorePercent = [theDic[@"tcdj"] floatValue]*0.2;
    self.tcStarView.allowIncompleteStar = YES;
    
    
//    self.twoLab.attributedText = [self setAttributedTitle:@"配对指数" contentString:theDic[@"zhishu"]];
//
//    self.threeLab.attributedText = [self setAttributedTitle:@"两清相悦指数" contentString:theDic[@"xiangyue"]];
//
//    self.fourLab.attributedText = [self setAttributedTitle:@"天长地久指数" contentString:theDic[@"tcdj"]];
    
}

- (NSMutableAttributedString *)setAttributedTitle:(NSString *)title contentString:(NSString *)content {
    
    NSString *dataStr = kISNullObject(content)?@"-":content;
    
    NSString *string = [NSString stringWithFormat:@"%@: %@",title,dataStr];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    
    [text addAttribute:NSForegroundColorAttributeName value:kRGBA(140, 73, 255, 1) range:[string rangeOfString:dataStr]];
    
    
    return text;
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.containerLab.layer.cornerRadius = 6.f;
    self.containerLab.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
