//
//  LLInviteUserCell.m
//  hongdou
//
//  Created by 维康1 on 2021/1/19.
//  Copyright © 2021 红豆-婚恋网. All rights reserved.
//

#import "LLInviteUserCell.h"

@implementation LLInviteUserCell


- (IBAction)yaoqingClick:(id)sender {
    [self sharePressed];
}

// 分享
- (void)sharePressed{
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params SSDKSetupShareParamsByText:[NSString stringWithFormat:@"邀请你来红豆佳缘, 注册时别忘了填写我的邀请码:%@",[LoginManager defaultManager].userid]
                                images:[UIImage imageNamed:@"image_touxiang"]
                                   url:[NSURL URLWithString:@"http://db.hongdou.art/index.php/index/index/invitational.html"]
                                 title:APP_NAME
                        type:SSDKContentTypeAuto];

    [ShareSDK showShareActionSheet:nil //(第一个参数要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，在ipad中要想弹出我们的分享菜单，这个参数必须要传值，可以传自己分享按钮的对象，或者可以创建一个小的view对象去传，传值与否不影响iphone显示)
                     customItems:@[@997,@998]
                     shareParams:params
              sheetConfiguration:nil
                  onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType,NSDictionary *userData,SSDKContentEntity *contentEntity,NSError *error,BOOL end)
             {
    switch (state) {
                 case SSDKResponseStateSuccess:
                         NSLog(@"成功");//成功
                         break;
                 case SSDKResponseStateFail:
                    {
                         NSLog(@"--%@",error.description);//失败
                         break;
                    }
                 case SSDKResponseStateCancel:
                 break;
                 default:
                 break;
             }
    }];
    
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
