//
//  HLRankingCell.m
//  hongdou
//
//  Created by 维康1 on 2019/12/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLRankingCell.h"

@implementation HLRankingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSubview:self.numLab];
        [self addSubview:self.rankImgV];
        [self addSubview:self.imgV];
        [self addSubview:self.nameLab];
        [self addSubview:self.rankLab];
        [self addSubview:self.addLab];
        
    }
    
    return self;
}

- (UIImageView *)rankImgV {
    if (!_rankImgV) {
        _rankImgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 21, 20, 28)];
//        _rankImgV.backgroundColor = [UIColor redColor];
    }
    return _rankImgV;
}

- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.rankImgV.frame)+10, 15, 40, 40)];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.layer.masksToBounds = YES;
        _imgV.layer.cornerRadius = 20;
        
    }
    return _imgV;
}

- (UILabel *)numLab {
    if (!_numLab) {
        _numLab = [[UILabel alloc] initWithFrame:self.rankImgV.frame];
        _numLab.textAlignment = NSTextAlignmentCenter;
        _numLab.textColor = kRGBA(138, 155, 173, 1);
        _numLab.font = kFontSize(14);
    }
    return _numLab;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imgV.frame)+10, 0, 100, 70)];
//        _nameLab.backgroundColor = [UIColor redColor];
//        _nameLab.textAlignment = NSTextAlignmentCenter;
        _nameLab.font = kFontSize(14);
    }
    return _nameLab;
}

- (UILabel *)rankLab {
    if (!_rankLab) {
        _rankLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLab.frame), 0, 100, 70)];
//        _rankLab.textAlignment = NSTextAlignmentCenter;
        _rankLab.font = kFontSize(14);
        _rankLab.textColor = kRGBA(138, 155, 173, 1);
    }
    return _rankLab;
}

- (UILabel *)addLab {
    if (!_addLab) {
        _addLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120, 0, 90, 70)];
//        _addLab.backgroundColor = [UIColor redColor];
        _addLab.textAlignment = NSTextAlignmentRight;
        _addLab.font = kFontSize(14);
    }
    return _addLab;
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
