//
//  HLSecondCell.m
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLSecondCell.h"

@implementation HLSecondCell


- (void)setContentDic:(NSDictionary *)contentDic {
    _contentDic = contentDic;
    
    NSLog(@"~%@-%@-%@",contentDic[@"zhishu"],contentDic[@"xiangyue"],contentDic[@"tcdj"]);
    
    self.pdStarView.scorePercent = [contentDic[@"zhishu"] floatValue]*0.2;
    self.pdStarView.allowIncompleteStar = YES;
    self.lqStarView.scorePercent = [contentDic[@"xiangyue"] floatValue]*0.2;
    self.lqStarView.allowIncompleteStar = YES;
    self.tcStarView.scorePercent = [contentDic[@"tcdj"] floatValue]*0.2;
    self.tcStarView.allowIncompleteStar = YES;
    
//    self.pdLab.attributedText = [self setAttributedTitle:@"配对指数" contentString:contentDic[@"zhishu"]];
//
//    self.lqLab.attributedText = [self setAttributedTitle:@"两清相悦指数" contentString:contentDic[@"xiangyue"]];
//
//    self.tcLab.attributedText = [self setAttributedTitle:@"天长地久指数" contentString:contentDic[@"tcdj"]];
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
