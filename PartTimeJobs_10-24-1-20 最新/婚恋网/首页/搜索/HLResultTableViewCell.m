//
//  HLResultTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/30.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLResultTableViewCell.h"

@implementation HLResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.followLabel.hidden = YES;
    self.ageLable.layer.cornerRadius = 10.f;
    self.ageLable.layer.masksToBounds = YES;
    self.constellaLabel.layer.cornerRadius = 10.f;
    self.constellaLabel.layer.masksToBounds = YES;
    [self.isLikeButton setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
    [self.isLikeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
    self.photosView.userInteractionEnabled = YES;
    self.picArray = [NSMutableArray array];
}
- (void)setModel:(HLUser *)model{
    _model = model;
//    self.followLabel.hidden  = !model.in_follow;
    
    if ([model.memberdata isEqualToString:@"0"]) { // 非会员
        self.vipImgV.hidden = YES;
        self.crownImgV.hidden = YES;
        self.headerImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.headerImageView.layer.borderWidth = 2; //边框的宽度
    } else { // 会员
        self.vipImgV.hidden = NO;
        self.crownImgV.hidden = NO;
        self.headerImageView.layer.borderColor=[kRGBA(248, 221, 115, 1) CGColor];
        self.headerImageView.layer.borderWidth = 2; //边框的宽度
    }
    
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.nicknameLable.text = model.nickname;
    self.ageLable.text = @"";
    if (model.age.length>0 && model.height.length>0) {
        self.ageLable.text = [NSString stringWithFormat:@" %@岁· %@ ",model.age,model.height];
    }else{
        if (model.age.length>0) {
            self.ageLable.text = [NSString stringWithFormat:@" %@岁 ",model.age];
        }else{
            self.ageLable.text = [NSString stringWithFormat:@" %@ ",model.height];
            
        }
    }
    self.constellaLabel.text =  [NSString stringWithFormat:@" %@ ", model.constellation.length ? model.constellation : @""];
    self.stageLable.text = model.education.length ? model.education : @"";
    self.occupationLabel.text = model.position.length ? model.position : @"";
    self.incomeLabel.text = model.earns.length ? model.earns : @"";
    
    self.reasonLabel.text = model.recommend.length ? model.recommend : @"";
    
    self.picOneImageView.hidden = YES;
    self.picSecondImageView.hidden = YES;
    self.picThridImageView.hidden = YES;
    if (model.pic_one.length || model.pic_two.length || model.pic_three.length) {
        [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((kScreenWidth - 119)/3 + 10);
        }];
        if (model.pic_one.length) {
            self.picOneImageView.hidden = NO;
            [self.picOneImageView sd_setImageWithURL:[NSURL URLWithString:model.pic_one] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(picOneImageViewAction:)];
            [self.picOneImageView addGestureRecognizer:tap];
            [self.picArray addObject:model.pic_one];
        }
        if (model.pic_two.length) {
            self.picSecondImageView.hidden = NO;
            [self.picSecondImageView sd_setImageWithURL:[NSURL URLWithString:model.pic_two] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(picTwoImageViewAction:)];
            [self.picSecondImageView addGestureRecognizer:tap];
            [self.picArray addObject:model.pic_two];
            
        }
        if (model.pic_three.length) {
            self.picThridImageView.hidden = NO;
            [self.picThridImageView sd_setImageWithURL:[NSURL URLWithString:model.pic_three] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(picThreeImageViewAction:)];
            [self.picThridImageView addGestureRecognizer:tap];
            [self.picArray addObject:model.pic_three];
        }
    }else{
        [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    self.introduceLabel.text = model.album_s.length ? model.album_s : @"";

    [self.isLikeButton setSelected:model.in_follow];
    self.likeNumLabel.text = model.fans.length ? model.fans : @"0";
    
}

- (void)picOneImageViewAction:(UITapGestureRecognizer *)tap{
    
    [self showPhotoBrowser:0];
}
- (void)picTwoImageViewAction:(UITapGestureRecognizer *)tap{
    [self showPhotoBrowser:1];
    
}
- (void)picThreeImageViewAction:(UITapGestureRecognizer *)tap{
    [self showPhotoBrowser:2];
    
}

- (void)showPhotoBrowser:(NSInteger)tag{
    NSLog(@"__%ld",tag);
}

- (IBAction)dropDownClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownButtonClick)]) {
        [self.delegate dropdownButtonClick];
    }
}

- (IBAction)chartClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chartButtonClick:)]) {
        [self.delegate chartButtonClick:self.indexPath];
    }
    
}

- (IBAction)followButtonClick:(id)sender {
    if (self.isLikeButton.selected) {
        [self requestCollectionUrl:HLCancelFollow_Shields];
    }else{
        [self requestCollectionUrl:HLGoFollow_Shields];
    }
    
}


- (void)requestCollectionUrl:(NSString *)url{
    
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"fid":self.model.userid} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.isLikeButton.selected = !self.isLikeButton.selected;
            
            if ([url isEqualToString:HLCancelFollow_Shields]) {
                
                self.likeNumLabel.text = [NSString stringWithFormat:@"%d",[self.likeNumLabel.text intValue]-1];
                
            } else {
                
                self.likeNumLabel.text = [NSString stringWithFormat:@"%d",[self.likeNumLabel.text intValue]+1];
            }
            
        } else {
            [[UIApplication sharedApplication].keyWindow showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow showTostWithMessage:@"操作失败，请重试！"];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
