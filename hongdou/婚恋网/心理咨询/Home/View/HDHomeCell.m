//
//  HDHomeCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/12.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HDHomeCell.h"

@implementation HDHomeCell

- (void)setIscell:(IsCell)iscell {
    _iscell = iscell;
    
    if (iscell == NoneCell) {
        self.chatBtn.hidden = YES;
        self.likeBtn.hidden = YES;
    } else {
        
        if ([LoginManager defaultManager].isLogin) {
            self.chatBtn.hidden = NO;
            self.likeBtn.hidden = NO;
        } else {
            self.chatBtn.hidden = YES;
            self.likeBtn.hidden = YES;
        }
        
        
    }
    
}

- (void)setHomeMod:(CSHomeModel *)homeMod {
    
    _homeMod = homeMod;
    
    if ([homeMod.gender isEqual:@"女"]) {
        self.sexImgV.image = [UIImage imageNamed:@"nvsheng_ico"];
    }
    
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:homeMod.head]];
    self.nameLab.text = homeMod.nickname;
    self.addLab.text = homeMod.habitation;
    self.eduLab.text = homeMod.education;
    self.ageLab.text = [NSString stringWithFormat:@"%@岁",homeMod.age];
    self.ziZhiLab.text = homeMod.intelligence;
    
    [self.likeBtn setSelected:homeMod.follow];
    
}


- (IBAction)chartClick:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chartButtonClick:)]) {
        [self.delegate chartButtonClick:self.indexPath];
    }
    
}
- (IBAction)likeClik:(id)sender {
    
    if ([[LoginManager defaultManager] isLogin]) {
        if (self.likeBtn.selected) {
            [self requestCollectionUrl:HLCancelFollow_Shields];
            
        }else{
            [self requestCollectionUrl:HLGoFollow_Shields];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
    }
    
}

- (void)requestCollectionUrl:(NSString *)url{
    
    NSDictionary *parmas = @{
        @"uid":[LoginManager defaultManager].userid,
        @"fid":self.homeMod.userId
    };
    
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:parmas success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"%@",dictionary);
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            self.likeBtn.selected = !self.likeBtn.selected;
            
            self.homeMod.follow = self.likeBtn.selected;
            
        } else {
            NSLog(@"%@",dictionary[@"msg"]);
        }
    } failure:^(NSError * _Nonnull error) {
        [[UIApplication sharedApplication].keyWindow showError:error.localizedDescription];
    }];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ziZhiLab.textColor = REDColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
