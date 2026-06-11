//
//  ZPHMessageTableViewCellHtml.m
//  hongdou
//
//  Created by 维康1 on 2021/9/2.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "ZPHMessageTableViewCellHtml.h"
@interface ZPHMessageTableViewCellHtml ()
/**
 内容文本
 */
@property (nonatomic,strong)UILabel *textContentLabel;

@property (nonatomic,strong)NSString *htmlString;
@end
@implementation ZPHMessageTableViewCellHtml

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _textContentLabel = [[UILabel alloc]init];
        _textContentLabel.numberOfLines = 0;//换行
        _textContentLabel.textAlignment = NSTextAlignmentLeft;
        _textContentLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_textContentLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLink)];
        _textContentLabel.userInteractionEnabled = YES;
        [_textContentLabel addGestureRecognizer:tap];

    }
    
    return self;
}

-(void)setLayout:(ZPHMessageTableViewCellLayout *)layout {
    
    [super setLayout:layout];
    
    // Html字符串
    _htmlString = layout.model.text;
    
    _textContentLabel.frame = layout.contentFrame;
    
    _textContentLabel.attributedText = layout.layoutAttributedString;
    self.messageBackView.frame = layout.messageBackViewFrame;
}

// 点击html单元格
- (void)clickLink {
    
    NSString *chatStr = _htmlString;
    
    NSDataDetector *detector= [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *checkArr = [detector matchesInString:chatStr options:0 range:NSMakeRange(0, chatStr.length)];
    
    //判断有没有链接
    if(checkArr.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_LINK" object:checkArr];
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
