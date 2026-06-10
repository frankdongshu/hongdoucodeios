//
//  HLTopToolsTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/9/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLTopToolsTableViewCell.h"

@implementation HLTopToolsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithRed:247 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1.0];
    }
    return self;
}

- (void)setDataArry:(NSArray *)dataArry {
    _dataArry = dataArry;
    self.buttonArr = [NSMutableArray array];
    [_dataArry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HLCityModel *model =obj;
        [self createButton:idx title:model.cityName];
    }];
    
}

- (void)createButton:(NSInteger)index title:(NSString *)title {
    NSInteger indexX = index % 3;
    NSInteger indexY = index / 3;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonIntervalH = 16;
    CGFloat buttonIntervalV = 10;
    CGFloat buttonW = ([UIScreen mainScreen].bounds.size.width - buttonIntervalH * 4) / 3 - 5;
    CGFloat buttonH = 36;
    CGFloat buttonX = buttonIntervalH * (indexX + 1) + indexX * buttonW;
    CGFloat buttonY = buttonIntervalV * (indexY + 1) + indexY * buttonH;
    button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    [button setTag:index];
    [button.layer setCornerRadius:3];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button .titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    [self.buttonArr addObject:button];
}

- (void)buttonAction:(UIButton *)sender {
    if (self.selectCityBlock) {
        if (self.selectCityBlock) {
            self.selectCityBlock(self.dataArry[sender.tag]);
        }
    }
}



- (void)topToolsCellSelectCityBlock:(topToolsCellSelectCityBlock)block {
    if (block) {
        self.selectCityBlock = block;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
