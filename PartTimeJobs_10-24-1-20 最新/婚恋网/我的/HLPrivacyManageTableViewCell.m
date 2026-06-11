//
//  HLPrivacyManageTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLPrivacyManageTableViewCell.h"

@interface HLPrivacyManageTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation HLPrivacyManageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImageView.layer.cornerRadius = 22.f;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setFriendModel:(HLFriendUserModel *)friendModel{
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:friendModel.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    self.nameLabel.text = friendModel.nickname;
    self.contentLabel.text = [NSString stringWithFormat:@"%@岁·%@",friendModel.age.length ? friendModel.age : @"0",friendModel.height.length ? friendModel.height : @""];
    
}

- (IBAction)deleteClick:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonClickIndexPath:)]) {
        [self.delegate deleteButtonClickIndexPath:self.currentIndex];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
