//
//  HLTopicHeaderView.m
//  hongdou
//
//  Created by 维康1 on 2020/12/9.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLTopicHeaderView.h"

@implementation HLTopicHeaderView

- (void)setContentDic:(NSDictionary *)contentDic {
    _contentDic = contentDic;
    
    // 防止刷新数据, 重复创建
    if (self.peopleView.subviews.count > 0) {
        for (UIView *view in self.peopleView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    // 话题名称
    self.titleLab.text = contentDic[@"data"][@"name"];
    // 话题图片
//    [self.imgView sd_setImageWithURL:[NSURL URLWithString:contentDic[@"data"][@"pic"]]];
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:contentDic[@"data"][@"pic"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        self.imageHeight.constant = image.size.height/image.size.width*(kScreenWidth-32);
        
        [self.delegate tableViewHeaderImgHeightWith:self.imageHeight.constant];
        
    }];
    
    
    NSArray *arr = contentDic[@"data"][@"album"];
    
    // 参与人数
    self.peopleNumLab = [[YYLabel alloc] init];
    
    NSString *strings = [contentDic[@"data"][@"c"] stringValue];
    
    NSString *context = [NSString stringWithFormat:@"等%@人正在参与",contentDic[@"data"][@"c"]];
    
    NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:context];
    lawTitle.font = [UIFont systemFontOfSize:13];
    lawTitle.color = kRGBA(141, 154, 172, 1);
    
    [lawTitle setTextHighlightRange:[context rangeOfString:strings] color:kRGBA(249, 103, 129, 1) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        
    }];
    
    
    self.peopleNumLab.attributedText = lawTitle;
    
    [self.peopleView addSubview:self.peopleNumLab];
    
    
    int peopleNumInt = arr.count>3 ? 4:arr.count;
    
    [self.peopleNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.peopleView.mas_top).offset(12);
        make.bottom.equalTo(self.peopleView.mas_bottom).offset(-12);
        
        make.left.equalTo(self.peopleView.mas_left).offset(peopleNumInt*25+18);
        
    }];
    
    // 截止时间
    self.timeLab = [[UILabel alloc] init];
    self.timeLab.font = [UIFont systemFontOfSize:12];
    self.timeLab.textColor = kRGBA(255, 92, 121, 1);
    
    [self.peopleView addSubview:self.timeLab];
    
    
    // 截止时间
    NSString *deadlineStr = contentDic[@"data"][@"end"];
    // 当前时间的时间戳
    NSString *nowStr = [self getCurrentTimeyyyymmdd];
    // 计算时间差值
    NSInteger secondsCountDown = [self getDateDifferenceWithNowDateStr:nowStr deadlineStr:deadlineStr];
    // 倒计时开始
    [self starDaoJiShiClick:secondsCountDown];
    
    
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.peopleView.mas_top).offset(12);
        make.bottom.equalTo(self.peopleView.mas_bottom).offset(-12);
        
        make.right.equalTo(self.peopleView.mas_right);
        
    }];
    
    // 参与者头像排列
    for (int i=0; i<arr.count; i++) {
        
        if (i>3) {
            return;
        }
        
        UIImageView *imgV = [[UIImageView alloc] init];
        
        if (i==3) {
            imgV.image = [UIImage imageNamed:@"home_more"];
        } else {
            [imgV sd_setImageWithURL:[NSURL URLWithString:arr[i][@"head"]]];
        }
        
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.layer.masksToBounds = YES;
        imgV.layer.cornerRadius = 18;
        
        imgV.layer.borderColor = [[UIColor whiteColor] CGColor];
        imgV.layer.borderWidth = 1.5;
        
        [self.peopleView addSubview:imgV];
        
        
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.peopleView.mas_top).offset(12);
            make.bottom.equalTo(self.peopleView.mas_bottom).offset(-12);
            
            make.left.equalTo(self.peopleView.mas_left).offset(25*i);
            
            make.size.mas_equalTo(CGSizeMake(36, 36));
            
        }];

    }
    
    
}

#pragma mark - 截止时间倒计时
/**
 *  获取当天的字符串
 *
 *  @return 格式为年-月-日 时分秒
 */
- (NSString *)getCurrentTimeyyyymmdd {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatDay = [[NSDateFormatter alloc] init];
    formatDay.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dayStr = [formatDay stringFromDate:now];
    return dayStr;
}

/**
 *  获取时间差值  截止时间-当前时间
 *  nowDateStr : 当前时间
 *  deadlineStr : 截止时间
 *  @return 时间戳差值
 */
- (NSInteger)getDateDifferenceWithNowDateStr:(NSString*)nowDateStr deadlineStr:(NSString*)deadlineStr {
    NSInteger timeDifference = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSDate *nowDate = [formatter dateFromString:nowDateStr];
    NSDate *deadline = [formatter dateFromString:deadlineStr];
    NSTimeInterval oldTime = [nowDate timeIntervalSince1970];
    NSTimeInterval newTime = [deadline timeIntervalSince1970];
    timeDifference = newTime - oldTime;
    return timeDifference;
}

// 倒计时
- (void)starDaoJiShiClick:(NSInteger)secondsCountDown {
    
    __weak __typeof(self) weakSelf = self;
    if (_timer == nil) {
        __block NSInteger timeout = secondsCountDown; // 倒计时时间
        if (timeout!=0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC,  0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout <= 0){ //  当倒计时结束时做需要的操作: 关闭 活动到期不能提交
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.timeLab.text = @"当前活动已结束";
                    });
                } else { // 倒计时重新计算 时/分/秒
                    NSInteger days = (int)(timeout/(3600*24));
                    NSInteger hours = (int)((timeout-days*24*3600)/3600);
                    NSInteger minute = (int)(timeout-days*24*3600-hours*3600)/60;
                    NSInteger second = timeout - days*24*3600 - hours*3600 - minute*60;
                    NSString *strTime = [NSString stringWithFormat:@"%02ld时%02ld分%02ld秒后结束", hours, minute, second];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (days == 0) {
                            weakSelf.timeLab.text = strTime;
                        } else {
                            weakSelf.timeLab.text = [NSString stringWithFormat:@"%ld天 %02ld时 %02ld分 %02ld秒", days, hours, minute, second];
                        }
                    });
                    timeout--; // 递减 倒计时-1(总时间以秒来计算)
                }
            });
            dispatch_resume(_timer);
        }
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    
    
}


+(instancetype)initWithXib:(CGRect)frame delegate:(id<HLTopicHeaderViewDelegate>)delegate{
    HLTopicHeaderView *view = [[UINib nibWithNibName:NSStringFromClass([HLTopicHeaderView class]) bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    view.frame = frame;
    view.delegate = delegate;
//    [view awakeFromNib];
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
