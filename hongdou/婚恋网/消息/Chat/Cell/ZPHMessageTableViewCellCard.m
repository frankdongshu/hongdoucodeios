//
//  ZPHMessageTableViewCellCard.m
//  hongdou
//
//  Created by user on 2022/5/5.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "ZPHMessageTableViewCellCard.h"

@interface ZPHMessageTableViewCellCard ()
/**
 内容文本
 */
@property (nonatomic,strong)UIImageView *textContentImgView;

@property (nonatomic,strong)UILabel *nameLab, *callLab;


@end

@implementation ZPHMessageTableViewCellCard

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _textContentImgView = [[UIImageView alloc]init];
        _textContentImgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_textContentImgView];
        
        _textContentImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImageView:)];
        [_textContentImgView addGestureRecognizer:tap];
        
        
        _nameLab = [[UILabel alloc] init];
        _nameLab.backgroundColor = [UIColor whiteColor];
        _nameLab.font = [UIFont systemFontOfSize:13];
        _nameLab.textColor = kRGB(102, 102, 102);
        [self.contentView addSubview:_nameLab];
        
        _callLab = [[UILabel alloc] init];
        _callLab.backgroundColor = [UIColor whiteColor];
        _callLab.font = [UIFont systemFontOfSize:13];
        _callLab.textColor = kRGB(102, 102, 102);
        [self.contentView addSubview:_callLab];
        
    }
    
    return self;
}

-(void)setLayout:(ZPHMessageTableViewCellLayout *)layout {
    
    [super setLayout:layout];
    
    _textContentImgView.frame = CGRectMake(layout.contentFrame.origin.x, layout.contentFrame.origin.y, layout.contentFrame.size.width, layout.contentFrame.size.height-60);
    [_textContentImgView sd_setImageWithURL:[NSURL URLWithString:layout.model.text]];
    
    _nameLab.frame = CGRectMake(layout.contentFrame.origin.x, CGRectGetMaxY(_textContentImgView.frame), layout.contentFrame.size.width, 30);
    _nameLab.text = [NSString stringWithFormat:@"  %@",layout.model.uname];
    
    _callLab.frame = CGRectMake(layout.contentFrame.origin.x, CGRectGetMaxY(_nameLab.frame), layout.contentFrame.size.width, 30);
    _callLab.text = [NSString stringWithFormat:@"  %@",layout.model.intro];
    
    
    self.messageBackView.frame = layout.messageBackViewFrame;
}

- (void)clickImageView:(UITapGestureRecognizer *)tap{
    
    if ([self.nameLab.text isEqualToString:[NSString stringWithFormat:@"  %@",[LoginManager defaultManager].nickName]]) {
        [self.delegate requestReceived:YES];
    } else {
        [self.delegate requestReceived:NO];
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
