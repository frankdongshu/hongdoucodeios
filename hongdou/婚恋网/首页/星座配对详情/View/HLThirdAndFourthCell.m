//
//  HLThirdAndFourthCell.m
//  hongdou
//
//  Created by 李龙 on 2020/6/26.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLThirdAndFourthCell.h"

@implementation HLThirdAndFourthCell


- (void)setContentDic:(NSDictionary *)dic indexpath:(NSIndexPath *)indexpath {
    
    if (indexpath.row == 2) {
        self.titleLab.text = @"恋爱建议:";
        self.contentLab.text = dic[@"lianai"];
    }
    else {
        self.titleLab.text = @"注意事项:";
        self.contentLab.text = dic[@"zhuyi"];
    }
    
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
