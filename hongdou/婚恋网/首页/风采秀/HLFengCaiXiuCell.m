//
//  HLFengCaiXiuCell.m
//  hongdou
//
//  Created by user on 2022/8/3.
//  Copyright © 2022 红豆-婚恋网. All rights reserved.
//

#import "HLFengCaiXiuCell.h"

@interface HLFengCaiXiuCell ()
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@end

@implementation HLFengCaiXiuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    if (@available(iOS 11.0, *)) {
        self.imgView.layer.cornerRadius = 40.0;
        self.imgView.layer.maskedCorners = kCALayerMaxXMinYCorner;
    } else {
        // Fallback on earlier versions
    }

}

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    [self.likeBtn setSelected:[dic[@"in_likes"] intValue]];
}


- (IBAction)likeBtnClick:(UIButton *)sender {
    
    if (sender.selected) {
        [self requestCollectionUrl:@"/album/activitynotlikes"];
    } else {
        [self requestCollectionUrl:@"/album/activitylikes"];
    }
    
}

- (void)requestCollectionUrl:(NSString *)url {
    [kAppDelegate.window showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.dic[@"id"]
    };
    
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"--->: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            self.likeBtn.selected = !self.likeBtn.selected;
            
            if (![url isEqualToString:@"/album/activitylikes"]) {
                self.likeLab.text = [NSString stringWithFormat:@"%d",[self.likeLab.text intValue]-1];
            } else {
                self.likeLab.text = [NSString stringWithFormat:@"%d",[self.likeLab.text intValue]+1];
            }
            
            [self.delegate likeUpdateList];
            
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
