//
//  HLCoPlaintSelectTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/22.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLCoPlaintSelectTableViewCell.h"

@implementation HLCoPlaintSelectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.selectBtn setImage:[UIImage imageNamed:@"icon_noSelect"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"icon_select"] forState:UIControlStateSelected];
    
}

- (void)setListModel:(HLListModel *)listModel{
    _listModel = listModel;
    self.titleLabel.text = listModel.name;
    [self.selectBtn setSelected:listModel.isSelect];
}

- (IBAction)selectClickAction:(id)sender {
    if (self.refreshBlock && !self.selectBtn.isSelected) {
        [self.selectBtn setSelected:!self.selectBtn.selected];
        self.refreshBlock();
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
