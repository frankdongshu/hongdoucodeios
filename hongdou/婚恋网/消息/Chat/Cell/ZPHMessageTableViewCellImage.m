//
//  ZPHMessageTableViewCellImage.m
//  ZHChatBar
//
//  Created by zph on 27/03/2018.
//  Copyright © 2018 zph. All rights reserved.
//

#import "ZPHMessageTableViewCellImage.h"

@interface ZPHMessageTableViewCellImage ()
/**
 内容文本
 */
@property (nonatomic,strong)UIImageView *textContentImgView;

// 图片url
@property (nonatomic,strong)NSString *urlString;

@end

@implementation ZPHMessageTableViewCellImage

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _textContentImgView = [[UIImageView alloc]init];
        _textContentImgView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_textContentImgView];
        
        _textContentImgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImageView:)];
        [_textContentImgView addGestureRecognizer:tap];
    }
    
    return self;
}

-(void)setLayout:(ZPHMessageTableViewCellLayout *)layout {
    
    [super setLayout:layout];
    
    self.urlString = layout.model.text;
    
    _textContentImgView.frame = layout.contentFrame;
    [_textContentImgView sd_setImageWithURL:[NSURL URLWithString:layout.model.text]];
    self.messageBackView.frame = layout.messageBackViewFrame;
}

- (void)clickImageView:(UITapGestureRecognizer *)tap{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CHECK_IMG" object:self.urlString];
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
