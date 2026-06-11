//
//  HLProductListCell.m
//  hongdou
//
//  Created by 维康1 on 2019/12/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLProductListCell.h"
#import "HLExchangeModel.h"


@interface HLProductListCell ()

@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation HLProductListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureUI];
    }
    return self;
}

- (void)configureUI {
    
//    CGFloat imgViewWidth = self.bounds.size.width - 60;
    
//    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-imgViewWidth/2, 10, imgViewWidth, imgViewWidth+10)];
    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width-20, self.bounds.size.height-80)];
    _imageV.contentMode = UIViewContentModeScaleAspectFill;
    _imageV.clipsToBounds  = YES;
    _imageV.layer.borderWidth = 0.5;
    [self.contentView addSubview:_imageV];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.bounds.size.height-60, self.bounds.size.width-20, 25)];
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_titleLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.bounds.size.height-35, self.bounds.size.width-20, 25)];
    _priceLabel.textColor = [UIColor redColor];
    _priceLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_priceLabel];
    
    _buyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buyBtn setTitle:@"立即兑换" forState:UIControlStateNormal];
    [_buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _buyBtn.frame = CGRectMake(self.bounds.size.width-75, self.bounds.size.height-35, 70, 25);
    _buyBtn.backgroundColor = kRGBA(153, 95, 248, 1);
    _buyBtn.titleLabel.font = kScaleFont(12);
    [_buyBtn addTarget:self action:@selector(buyClick:) forControlEvents:UIControlEventTouchUpInside];
    _buyBtn.layer.masksToBounds = YES;
    _buyBtn.layer.cornerRadius = 3;
    
    [self.contentView addSubview:_buyBtn];
    
}

- (void)buyClick:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectBuyButtonWithIdx:)]) {
        
        [self.delegate didSelectBuyButtonWithIdx:sender.tag];
    }
    
    
    
}

- (void)setModel:(HLExchangeModel *)model
{
    _model = model;
    
    [_imageV sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
    _titleLabel.text = model.title;
    _priceLabel.text = [NSString stringWithFormat:@"%@币",model.price];
}

@end
