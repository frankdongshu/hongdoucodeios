//
//  HLRecCell.m
//  hongdou
//
//  Created by user on 2022/4/27.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLRecCell.h"

@implementation HLRecCell

- (IBAction)btnClick:(id)sender {
    [self.delegate updateBtnClick];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.swicthOn.onTintColor = [UIColor colorWithHex:0x8C49FF];
    [self.swicthOn addTarget:self action:@selector(changeSwitchStatu:) forControlEvents:UIControlEventValueChanged];
    self.timeLab.hidden = YES;
    
}

- (void)setStatu:(BOOL)statu{
    _statu = statu;
}

- (void)setIndex:(NSInteger)index{
    _index = index;
}

- (void)changeSwitchStatu:(UISwitch *)swicth{
    
    [self.delegate refreshTableViewWithSwitch:swicth];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
