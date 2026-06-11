//
//  HLInviteAwardTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/23.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLInviteAwardTableViewCell.h"

@implementation HLInviteAwardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 7.5f;
    
}

- (void)setInviteModel:(HLInvitationModel *)inviteModel{
    _inviteModel = inviteModel;
    self.countLabel.text = [NSString stringWithFormat:@"共计%@位",inviteModel.counts];
    self.moneysLabel.text =  [NSString stringWithFormat:@"%@元",inviteModel.reward];
    
    
    
    NSArray *imgViewArray = @[_imgV5,_imgV4,_imgV3,_imgV2,_imgV1];
    NSArray *myCout = inviteModel.myinvite;

    for (int i=0; i<myCout.count; i++) {

        NSLog(@"=== %@",myCout[i]);
        
        UIImageView *imgView = imgViewArray[i];

        [imgView sd_setImageWithURL:[NSURL URLWithString:myCout[i][@"head"]]];
    }
}

- (IBAction)sendInviteAction:(id)sender {
    if (self.shareBlock) {
        self.shareBlock();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
