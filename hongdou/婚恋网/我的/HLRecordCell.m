//
//  HLRecordCell.m
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLRecordCell.h"
#import "HLRecordModel.h"

@interface HLRecordCell ()

@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *addLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation HLRecordCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    
    self.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth-30, 115)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 6;
    [self addSubview:view];
    
    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 88, 88)];
    [view addSubview:_imageV];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imageV.frame)+10, CGRectGetMinY(_imageV.frame), 200, 21)];
    _titleLabel.textColor = kRGBA(63, 70, 87, 1);
    _titleLabel.font = kScaleFont(15);
    [view addSubview:_titleLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imageV.frame)+10, CGRectGetMaxY(_titleLabel.frame), 200, 21)];
    _timeLabel.textColor = kRGBA(138, 155, 173, 1);
    _timeLabel.font = kScaleFont(12);
    [view addSubview:_timeLabel];
    
    // 名字
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imageV.frame)+10, CGRectGetMaxY(_timeLabel.frame), 200, 21)];
    _nameLabel.textColor = kRGBA(138, 155, 173, 1);
    _nameLabel.font = kScaleFont(12);
    [view addSubview:_nameLabel];
    
    // 收货地址
    _addLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imageV.frame)+10, CGRectGetMaxY(_nameLabel.frame), 260, 21)];
    _addLabel.textColor = kRGBA(138, 155, 173, 1);
    _addLabel.font = kScaleFont(12);
    [view addSubview:_addLabel];
    
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width-160, view.frame.size.height-20, 150, 20)];
    _stateLabel.textAlignment = NSTextAlignmentRight;
    _stateLabel.textColor = kRGBA(63, 70, 87, 1);
    _stateLabel.font = kScaleFont(12);
    [view addSubview:_stateLabel];
    
}

- (void)setModel:(HLRecordModel *)model {
    _model = model;
    
    [_imageV sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    _titleLabel.text = model.title;
    _nameLabel.text = [NSString stringWithFormat:@"收货人: %@",model.consignee];
    _addLabel.text = [NSString stringWithFormat:@"收货地址: %@",model.address];
    _timeLabel.text = [NSString stringWithFormat:@"兑换时间: %@",model.time];
    _stateLabel.text = [NSString stringWithFormat:@"订单状态: %@",model.state];
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
