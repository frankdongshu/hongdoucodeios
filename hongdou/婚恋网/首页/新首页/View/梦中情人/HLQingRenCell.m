//
//  HLQingRenCell.m
//  hongdou
//
//  Created by 李龙 on 2020/7/5.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLQingRenCell.h"
#import "HLMoreQingRenView.h"
#import "HLAlertOpenVipView.h"
#import "HLOpenMemberViewController.h"

@interface HLQingRenCell (){
    
    NSDictionary *_qingRenDic;
}
@property (weak, nonatomic) IBOutlet UIButton *imgViewBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightTopBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@end

@implementation HLQingRenCell

// 更多
- (IBAction)moreClick:(UIButton *)sender {
    
    if (![LoginManager defaultManager].isVip) {
        
        HLAlertOpenVipView *aView = [[HLAlertOpenVipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andMessage:@"想查看更多? 立即开通会员"];
        
        aView.SelectBlock = ^{
            // 跳转购买会员界面
            [self.delegate pushBuyVipClick];
        };
        
        [aView showSelf];
        
        return;
    }
    
    HLMoreQingRenView *mView = [[HLMoreQingRenView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) andArray:self->_qingRenDic[@"by"]];
    
    mView.SelectBlock = ^(NSString *uid) {
        [self.delegate pushQingRenDetailWithId:uid];
    };
    
    [mView showSelf];
    
}

// 问号
- (IBAction)wenHaoClick:(UIButton *)sender {
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"sign":@"dreamlover"
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/index/notice" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            [self.delegate wenhaoClickAlertWithTitle:dictionary[@"data"][@"title"] andMessage:dictionary[@"data"][@"val"]];
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// imgData 只会在选择了图片是改变,配对出来的图片再搜索还是之前选择图片的imgData
- (IBAction)searchClick:(UIButton *)sender {
    if (kISNullObject(self.dic[@"imgData"])) {
        [self showTostWithMessage:@"请先选择图片"];
    } else {
        [self uploadUserHeaderImage];
    }
}
- (IBAction)addPhotoClick:(UIButton *)sender {
    
    [self.delegate addPhotoMengZhongQingRen];
    
}
- (IBAction)rightTopClick:(UIButton *)sender {
    
    [self.delegate addPhotoMengZhongQingRen];
}

- (void)setDic:(NSDictionary *)dic {
    _dic = dic;
    
    NSLog(@"!~!~:%@",dic);
    
    self.imgView.image = dic[@"imgObj"];
    
    if ([dic[@"isSelect"] intValue] != 0) {
        self.imgViewBtn.hidden = YES;
        self.rightTopBtn.hidden = NO;
        
        self.imgView.userInteractionEnabled = NO;
        self.moreBtn.hidden = YES;
        self.searchBtn.enabled = YES;
        self.searchBtn.backgroundColor = kRGBA(142, 133, 253, 1);
        
    } else {
        self.imgViewBtn.hidden = NO;
        self.rightTopBtn.hidden = YES;
        self.moreBtn.hidden = YES;
    }
    
}

// 上传图片
- (void)uploadUserHeaderImage{
    
    [kAppDelegate.window showLoadMessageAtCenter:@"寻找中.."];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    NSData *imageData = self.dic[@"imgData"];
    
    [HLHTTPSessionManager postDataWithNSString:HLUPLoad_HeaderImage withDictionary:@{@"uid":[LoginManager defaultManager].userid} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/jpeg"];
        
    } success:^(NSDictionary *dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [self requestMengZhongQingRenDataWithUrl:dictionary[@"data"][@"url"]];
        } else {
            [kAppDelegate.window showError:dictionary[@"msg"]];
        }
        
    } failure:^(NSError *error) {
        [kAppDelegate.window showError:error.localizedDescription];
    }];
    
}

// 搜索匹配的情人
- (void)requestMengZhongQingRenDataWithUrl:(NSString *)url {
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"pic":url
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/user/dreamlover" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            
            self->_qingRenDic = dictionary[@"data"];
            
            if (!kISNullObject(dictionary[@"data"][@"head"])) {
                [kAppDelegate.window hide];
                
                [self.imgView sd_setImageWithURL:[NSURL URLWithString:dictionary[@"data"][@"head"]]];
                self.moreBtn.hidden = NO;
                self.imgView.userInteractionEnabled = YES;
                
                self.searchBtn.enabled = NO;
                self.searchBtn.backgroundColor = kRGBA(198, 197, 209, 1);
                
            } else {
                
                [kAppDelegate.window showError:dictionary[@"data"][@"xin"]];
                
                if ([[NSString stringWithFormat:@"%@",dictionary[@"data"][@"xin"]] isEqualToString:@"没有在图片中找到人像"]) {
                    
                    self.imgView.image = [UIImage imageNamed:@"cer_person_no"];
                    self.moreBtn.hidden = YES;
                    
                    self.searchBtn.enabled = NO;
                    self.searchBtn.backgroundColor = kRGBA(198, 197, 209, 1);
                    
                }
                
            }
            
        } else {
            [kAppDelegate.window showError:dictionary[@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showError:error.localizedDescription];
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewClick)];
    [_imgView addGestureRecognizer:tap];
}

- (void)imgViewClick {
    
    if (!kISNullObject(self->_qingRenDic[@"id"])) {
        [self.delegate pushQingRenDetailWithId:self->_qingRenDic[@"id"]];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
