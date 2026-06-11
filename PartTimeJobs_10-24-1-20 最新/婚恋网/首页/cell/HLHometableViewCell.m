//
//  HLHometableViewCell.m
//  婚恋网
//
//  Created by jxzhang on 2019/3/10.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLHometableViewCell.h"

@implementation HLHometableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ageLable.layer.cornerRadius = 10.f;
    self.ageLable.layer.masksToBounds = YES;
    self.constellaLabel.layer.cornerRadius = 10.f;
    self.constellaLabel.layer.masksToBounds = YES;
    self.followButton.hidden = YES;
    [self.isLikeButton setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
    [self.isLikeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
    self.photosView.userInteractionEnabled = YES;
    self.imgArray = [NSMutableArray array];
}
- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setModel:(HLUser *)model{
    _model = model;
//    self.followButton.hidden  = !model.in_follow;
    
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
    
    NSString *string = [NSString stringWithFormat:@" %@ ",model.constellation];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSFontAttributeName value:kScaleFont(11) range:NSMakeRange(1, 1)];
//    self.constellaLabel.text =  [NSString stringWithFormat:@" %@ ", model.constellation.length ? model.constellation : @""];
    self.constellaLabel.attributedText = text;
    self.stageLable.text = model.education.length ? model.education : @"";
    self.occupationLabel.text = model.position.length ? model.position : @"";
    self.incomeLabel.text = model.earns.length ? model.earns : @"";
    
    
    [self.photosView removeAllSubviews];
    
    if (model.picArray.count>0) {
        
        
        
        CGFloat width;
        
        
        if (model.picArray.count == 1) {
            
            width= (kScreenWidth - 160);
            
            [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((kScreenWidth - 160));
            }];
            
        }
        else if (model.picArray.count == 2) {
            
            width= (kScreenWidth - 119)/2;
            
            [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((kScreenWidth - 119)/2);
            }];
            
        }
        else {
            
            width= (kScreenWidth - 119)/3;
            
            [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((kScreenWidth - 119)/3);
            }];
            
        }
        
        

        
        
        [model.picArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *imagUrl = obj;
            UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(idx%3 *(width + 10), 0, width, width)];
            photoImageView.hidden = NO;
            photoImageView.userInteractionEnabled = YES;
            [photoImageView sd_setImageWithURL:[NSURL URLWithString:imagUrl] placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            photoImageView.contentMode = UIViewContentModeScaleAspectFill;
            photoImageView.layer.cornerRadius = 3.f;
            photoImageView.layer.masksToBounds = YES;
            photoImageView.tag = idx;
            
            [self.imgArray addObject:photoImageView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
            [photoImageView addGestureRecognizer:tap];
            
            
            [self.photosView addSubview:photoImageView];
        }];
    }else{
        [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    [self.photosView layoutIfNeeded];

    [self.isLikeButton setTitleColor:self.likeNumLabel.textColor forState:UIControlStateNormal];
    
    [self.isLikeButton setSelected:model.in_follow];
    [self.isLikeButton setTitle:model.fans.length ? model.fans : @"0" forState:UIControlStateNormal];
    [self.isLikeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    [self layoutSubviews];
}

- (void)buttonAction:(UITapGestureRecognizer *)tap{
    // 获取当前点击的位置
    CGPoint selectPoint = [tap locationInView:self];
    [self.imgArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         UIImageView *photoImageView = self.imgArray[idx];
         // 某个图片区域位置
        CGRect rect = [self convertRect:photoImageView.frame fromView:self.photosView];
        // 判断点击点是否在某个课件内
        if (CGRectContainsPoint(rect, selectPoint)) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(browerPhotoClick:withCurrentIndex:)]) {
                [self.delegate browerPhotoClick:self.model.picArray withCurrentIndex:[tap.view tag]];
            }
            *stop = YES;
        }
    }];
    
    
}
- (void)showPhotoBrowser:(NSInteger)tag{
    if (self.delegate && [self.delegate respondsToSelector:@selector(browerPhotoClick:withCurrentIndex:)]) {
        [self.delegate browerPhotoClick:self.model.picArray withCurrentIndex:tag];
    }
}

- (IBAction)closeButtonClick:(id)sender {
    
    if ([[LoginManager defaultManager] isLogin]) {
        UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定对他/她不感兴趣？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 110;
        [alert show];
    } else {
        // 进入登录页
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
    }
    
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 110){
           WeakSelf(weakSelf);
            [HLHTTPSessionManager postDataWithNSString:HLGoPrivacy_Shield withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"sid":self.model.userid} success:^(NSDictionary * _Nonnull dictionary) {
                NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
                if ([code isEqualToString:@"200"] ) {
                    self.isLikeButton.selected = !self.isLikeButton.selected;
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(closeButtonClick:)]) {
                        [weakSelf.delegate closeButtonClick:self.indexPath];
                    }
                    
                }else {
                    [[UIApplication sharedApplication].keyWindow showTostWithMessage:[dictionary objectForKey:@"msg"]];
                }
            } failure:^(NSError * _Nonnull error) {
                [[UIApplication sharedApplication].keyWindow showTostWithMessage:@"操作失败，请重试！"];
            }];
        }
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
    
    NSDictionary *parmas = @{
        @"uid":kISNullString([LoginManager defaultManager].userid)?@"":[LoginManager defaultManager].userid,
        @"fid":self.model.userid
    };
    
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.isLikeButton.selected = !self.isLikeButton.selected;
            
            if ([url isEqualToString:HLCancelFollow_Shields]) { // 取关
                
                [self.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[self.isLikeButton.titleLabel.text intValue]-1] forState:UIControlStateNormal];
                
            } else { // 点关
                
                [self.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[self.isLikeButton.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            }
            
            self.model.in_follow = self.isLikeButton.selected;
            self.model.fans = self.isLikeButton.titleLabel.text;
            
            
        }else {
//            [[UIApplication sharedApplication].keyWindow showTostWithMessage:[dictionary objectForKey:@"msg"]];
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
