//
//  ZPMessageHomeTableCell.m
//  ZHChatBar
//
//  Created by aaa on 2018/9/3.
//  Copyright © 2018年 zph. All rights reserved.
//

#import "ZPMessageHomeTableCell.h"

@interface ZPMessageHomeTableCell ()
@property (nonatomic,strong)UIImageView *headImgView;
@property (nonatomic,strong)UILabel *nameLabel;
@end
@implementation ZPMessageHomeTableCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        
    }
    return self;
}


- (void)setCellDataWithLastMessage:(NSDictionary *)dic {
    
    NSString *str = dic[@"lastMessage"][@"payload"];
    
    NSData *sData = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:sData options:NSJSONReadingMutableLeaves error:nil];
    
    NSData *tData = [[NSData alloc]initWithBase64EncodedString:responseJSON[@"payload"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *dataString = [[NSString alloc]initWithData:tData encoding:NSUTF8StringEncoding];
    
    
    _headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 64, 64)];
    _headImgView.image = [UIImage imageNamed:@"message_kefu"];
    [self.contentView addSubview:_headImgView];
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImgView.frame) +10, 12, 200, 20)];
    _nameLabel.text = dic[@"name"];
    [self.contentView addSubview:_nameLabel];
    
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
