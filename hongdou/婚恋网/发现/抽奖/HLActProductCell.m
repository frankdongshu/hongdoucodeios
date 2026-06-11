//
//  HLActProductCell.m
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLActProductCell.h"

@implementation HLActProductCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSubview:self.imgV];
        [self addSubview:self.nameLab];
        [self addSubview:self.timeLab];
        [self addSubview:self.countLab];
        [self addSubview:self.prizeCountLab];
        [self addSubview:self.messageLab];
        
    }
    
    return self;
}

- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 100, 100)];
        
    }
    return _imgV;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame)+10, CGRectGetMinY(self.imgV.frame), ScreenWidth-CGRectGetMaxX(self.imgV.frame)-15, 20)];
//        _nameLab.backgroundColor = [UIColor redColor];
        _nameLab.font = kFontSize(14);
    }
    return _nameLab;
}
- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame)+10, CGRectGetMaxY(self.nameLab.frame), ScreenWidth-CGRectGetMaxX(self.imgV.frame)-15, 20)];
//        _timeLab.backgroundColor = [UIColor purpleColor];
        _timeLab.font = kFontSize(14);
    }
    return _timeLab;
}
- (UILabel *)countLab {
    if (!_countLab) {
        _countLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame)+10, CGRectGetMaxY(self.timeLab.frame), ScreenWidth-CGRectGetMaxX(self.imgV.frame)-15, 20)];
//        _countLab.backgroundColor = [UIColor orangeColor];
        _countLab.font = kFontSize(14);
        _countLab.textColor = kRGBA(255, 92, 121, 1);
    }
    return _countLab;
}
- (UILabel *)prizeCountLab {
    if (!_prizeCountLab) {
        _prizeCountLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame)+10, CGRectGetMaxY(self.countLab.frame), ScreenWidth-CGRectGetMaxX(self.imgV.frame)-15, 20)];
//        _prizeCountLab.backgroundColor = [UIColor blueColor];
        _prizeCountLab.font = kFontSize(14);
    }
    return _prizeCountLab;
}
- (UILabel *)messageLab {
    if (!_messageLab) {
        _messageLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame)+10, CGRectGetMaxY(self.prizeCountLab.frame), ScreenWidth-CGRectGetMaxX(self.imgV.frame)-15, 40)];
//        _messageLab.backgroundColor = [UIColor yellowColor];
        _messageLab.numberOfLines = 0;
        _messageLab.font = kFontSize(14);
    }
    return _messageLab;
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
