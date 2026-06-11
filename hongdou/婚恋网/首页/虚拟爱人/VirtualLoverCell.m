//
//  VirtualLoverCell.m
//  hongdou
//
//  Created by xk work's computer on 2025/3/28.
//  Copyright © 2025 红豆-婚恋网. All rights reserved.
//



#import "VirtualLoverCell.h"

@interface VirtualLoverCell ()


@end

@implementation VirtualLoverCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addViews];
        [self layoutView];
    }
    return self;

}

#pragma mark - set



#pragma mark - UI
-(void)addViews {

    [self.contentView addSubview:self.sexImageView];

}

-(void)layoutView{

    [self.sexImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).mas_offset(10);
        make.right.equalTo(self.mas_right).mas_offset(-10);
        make.top.equalTo(self);
        make.bottom.equalTo(@-16);
    }];
}


//- (void)setVirtualLoverModel:(VirtualLoverModel *)virtualLoverModel {
//    _virtualLoverModel = virtualLoverModel;
//    [self.sexImageView sd_setImageWithURL:[NSURL URLWithString:virtualLoverModel.poster_img]];
//}

#pragma mark - lazy


-(UIImageView *)sexImageView{
    if (_sexImageView == nil) {
        _sexImageView = [[UIImageView alloc]init];
        _sexImageView.layer.cornerRadius = 8.0f;
        _sexImageView.layer.masksToBounds = YES;
        _sexImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _sexImageView;
}



@end

