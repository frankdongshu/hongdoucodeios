//
//  HLFriendsTopView.m
//  hongdou
//
//  Created by iMac on 2019/10/16.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFriendsTopView.h"
#import "HeeeMusicAnimateView.h" // 音频播放动画
#import "LGAudioPlayer.h"

@interface HLFriendsTopView ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImageView *vipImgV, *crownImgV;
@property (nonatomic, strong) UILabel *nikeNameLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *evaluateLabel, *likeLabel, *noLikeLabel;

@property (nonatomic,strong) UIView *musicView; // 音频播放动画
@property (nonatomic,strong) HeeeMusicAnimateView *musicAnimateView;
@property (nonatomic, strong) LGAudioPlayer *audioPlayer; // 音频播放

@property (nonatomic,strong) UIButton *cerBtn; // 认证显示

@end

@implementation HLFriendsTopView

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self az_setGradientBackgroundWithColors:@[[UIColor colorWithHex:0xF3B2A1],[UIColor colorWithHex:0xEE7998]] locations:@[@(0.0),@(0.5),@(0.75),@(1.0)] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
        [self darwUI];
    }
    return self;
}

// 富文本
- (NSMutableAttributedString *)createFuWenBenWithString:(NSString *)content {
    
    NSString *string = [NSString stringWithFormat:@"%@",content];
    NSString *string1 = [NSString stringWithFormat:@"%@ 人",string];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string1];
    [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 212, 49, 1) range:[string1 rangeOfString:string]];
    
    return text;
}

- (void)setSoundModel:(HLSoundModel *)soundModel {
    _soundModel = soundModel;
    
    if (!kISNullObject(soundModel.sound)) {
        self.musicView.hidden = NO;
    }
    
}

- (void)setFriensModel:(HLUser *)friensModel{
    _friensModel = friensModel;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:friensModel.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    self.nikeNameLabel.text = friensModel.nickname;
    
    if ([friensModel.certification isEqualToString:@"1"]) {
        self.cerBtn.hidden = NO;
    }
    
    if ([friensModel.memberdata isEqualToString:@"0"]) { // 非会员
        self.vipImgV.hidden = YES;
        self.crownImgV.hidden = YES;
        self.iconView.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.iconView.layer.borderWidth = 2; //边框的宽度
    } else { // 会员
        self.vipImgV.hidden = NO;
        self.crownImgV.hidden = NO;
        self.iconView.layer.borderColor=[kRGBA(248, 221, 115, 1) CGColor];
        self.iconView.layer.borderWidth = 2; //边框的宽度
    }
    
    NSString *defaultValueStr = @"0";
    
    NSString *countString = [NSString stringWithFormat:@"%@",kISNullObject(friensModel.proper_bad)?defaultValueStr:friensModel.proper_bad];
    NSString *string = [NSString stringWithFormat:@"    有%@人评价了",countString];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSForegroundColorAttributeName value:kRGBA(255, 212, 49, 1) range:[string rangeOfString:countString]];
    self.evaluateLabel.attributedText = text;
    
    
    self.likeLabel.attributedText = [self createFuWenBenWithString:kISNullObject(friensModel.proper_like)?defaultValueStr:friensModel.proper_like];
    
    self.noLikeLabel.attributedText = [self createFuWenBenWithString:kISNullObject(friensModel.proper_no)?defaultValueStr:friensModel.proper_no];
    
    
//    NSString *contentStr = @"";
//    if (self.friensModel.age.length) {
//        contentStr = [NSString stringWithFormat:@"%@岁",friensModel.age];
//    }
//    if (self.friensModel.height.length) {
//        contentStr = [NSString stringWithFormat:@"%@  %@",contentStr,friensModel.height];
//    }
//    if (self.friensModel.constellation.length) {
//        contentStr = [NSString stringWithFormat:@"%@  %@",contentStr,friensModel.constellation];
//    }
//    if (self.friensModel.position.length) {
//        contentStr = [NSString stringWithFormat:@"%@  %@",contentStr,friensModel.position];
//    }
    
//    NSLog(@"---->%@",friensModel.label);
    
    NSMutableString *contentStr = [NSMutableString string];
    
    if (friensModel.label.count > 0) {
        
        for (NSString *str in friensModel.label) {
            
            [contentStr appendFormat:@"%@\t",str];
        }
    }
    
    
    self.contentLabel.text = contentStr;
}

- (void)clickImageView:(UITapGestureRecognizer *)tap{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoImgViewClick:)]) {
        [self.delegate photoImgViewClick:tap];
    }
    
}

- (void)darwUI{
    __weak typeof(self) weakSelf = self;
    
    _iconView = ({
        _iconView = [[UIImageView alloc]  init];
        _iconView.image = [UIImage imageNamed:@"icon_head"];
        _iconView.layer.cornerRadius = 50.f;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderWidth = 2.0;
        _iconView.layer.borderColor = [[UIColor whiteColor] CGColor];
        [_iconView setContentMode:UIViewContentModeScaleAspectFill];
        _iconView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImageView:)];
        [_iconView addGestureRecognizer:tap];
        
        [self addSubview:_iconView];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.mas_top).offset(kNavigationBarHeight+10);
            make.left.equalTo(weakSelf.mas_left).offset(kScreenWidth/2 - 50.f);
            make.height.width.mas_equalTo(100);
            
        }];
        _iconView;
    });
    
    _vipImgV = ({
        _vipImgV = [[UIImageView alloc]  init];
        _vipImgV.image = [UIImage imageNamed:@"icon_vip"];
        [self addSubview:_vipImgV];
        
        [_vipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.iconView).offset(-3);
            make.right.equalTo(weakSelf.iconView).offset(-3);
            make.height.width.mas_equalTo(25);
            
        }];
        _vipImgV;
    });
    
    _crownImgV = ({
        _crownImgV = [[UIImageView alloc]  init];
        _crownImgV.image = [UIImage imageNamed:@"icon_crown"];
        [_crownImgV setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:_crownImgV];
        
        [_crownImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.iconView).offset(-13);
            make.right.equalTo(weakSelf.iconView).offset(-8);
            make.height.mas_equalTo(25);
            make.width.mas_equalTo(30);
            
        }];
        _crownImgV;
    });
    
    
    _nikeNameLabel = ({
        _nikeNameLabel = [[UILabel alloc] init];
        _nikeNameLabel.textAlignment = NSTextAlignmentCenter;
        _nikeNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_nikeNameLabel];
        [_nikeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.iconView.mas_bottom).offset(15);
            make.left.right.equalTo(weakSelf);
            make.height.mas_equalTo(20);
        }];
        _nikeNameLabel;
    });
    
    _cerBtn = ({
        _cerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cerBtn.backgroundColor = kRGBA(255, 255, 255, .3);
        [_cerBtn setImage:[UIImage imageNamed:@"renzheng"] forState:UIControlStateNormal];
        [_cerBtn setTitle:@" 本人头像" forState:UIControlStateNormal];
        _cerBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _cerBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _cerBtn.layer.cornerRadius = 13;
        _cerBtn.hidden = YES;
        
        [self addSubview:_cerBtn];
        
        [_cerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.nikeNameLabel.mas_bottom).offset(15);
            make.centerX.equalTo(weakSelf);
            make.height.mas_equalTo(26);
        }];
        
        _cerBtn;
    });
    
    _contentLabel = ({
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.numberOfLines = 0;
        _contentLabel.hidden = YES;
        [self addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.nikeNameLabel.mas_bottom).offset(20);
            make.left.right.equalTo(weakSelf);
            make.height.mas_equalTo(40);
        }];
        _contentLabel;
    });
    
    _evaluateLabel = ({
        _evaluateLabel = [[UILabel alloc] init];
        _evaluateLabel.backgroundColor = kRGBA(255, 117, 153, 1);
        _evaluateLabel.textColor = [UIColor whiteColor];
        _evaluateLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_evaluateLabel];
        [_evaluateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.iconView.mas_centerY);
            make.left.equalTo(self.iconView.mas_right).offset(60);
            make.right.equalTo(weakSelf).offset(13);
            make.height.mas_equalTo(26);
        }];
        
        _evaluateLabel.layer.borderWidth = 0.3;
        _evaluateLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
        _evaluateLabel.layer.cornerRadius = 13;
        _evaluateLabel.layer.masksToBounds = YES;
        
        _evaluateLabel;
    });
    
    _musicView = ({
        
        _musicView = [[UIView alloc] init];
        _musicView.hidden = YES;
        
        [self addSubview:_musicView];
        
        [_musicView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.evaluateLabel.mas_top).offset(-10);
            make.left.equalTo(self.iconView.mas_right).offset(100);
            make.right.equalTo(weakSelf).offset(13);
            make.height.mas_equalTo(26);
        }];
        
        _musicView.layer.borderWidth = 0.3;
        _musicView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _musicView.layer.cornerRadius = 13;
        _musicView.layer.masksToBounds = YES;
        
        _musicAnimateView = [HeeeMusicAnimateView new];
        _musicAnimateView.viewColor = [UIColor whiteColor];
        _musicAnimateView.totalWidth = 20;
        
        [_musicView addSubview:_musicAnimateView];
        
        
        
        UIButton *musicBtn = [[UIButton alloc] init];
        
        [musicBtn addTarget:self action:@selector(musicClick:) forControlEvents:UIControlEventTouchUpInside];
        [_musicView addSubview:musicBtn];
        
        [musicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_musicView);
            make.size.equalTo(_musicView);
        }];

        
        
        _musicView;
        
    });
    
    
    _noLikeLabel = ({
        _noLikeLabel = [[UILabel alloc] init];
        _noLikeLabel.backgroundColor = [UIColor clearColor];
        _noLikeLabel.textColor = [UIColor whiteColor];
        _noLikeLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_noLikeLabel];
        [_noLikeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-5);
            make.top.equalTo(weakSelf.evaluateLabel.mas_bottom);
        }];
        
        _noLikeLabel;
    });
    
    UIButton *imgBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgBtn1 setImage:[UIImage imageNamed:@"friend_cha"] forState:UIControlStateNormal];
    [self addSubview:imgBtn1];
    
    [imgBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.evaluateLabel.mas_bottom);
        make.right.equalTo(self.noLikeLabel.mas_left).offset(-5);
        make.height.equalTo(self.noLikeLabel.mas_height);
    }];
    
    
    _likeLabel = ({
        _likeLabel = [[UILabel alloc] init];
        _likeLabel.backgroundColor = [UIColor clearColor];
        _likeLabel.textColor = [UIColor whiteColor];
        _likeLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_likeLabel];
        [_likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(imgBtn1.mas_left).offset(-10);
            make.top.equalTo(weakSelf.evaluateLabel.mas_bottom);
        }];
        
        _likeLabel;
    });
    
    UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgBtn setImage:[UIImage imageNamed:@"friend_hao"] forState:UIControlStateNormal];
    [self addSubview:imgBtn];
    
    [imgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.evaluateLabel.mas_bottom);
        make.right.equalTo(self.likeLabel.mas_left).offset(-5);
        make.height.equalTo(self.likeLabel.mas_height);
    }];
    
}

- (LGAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[LGAudioPlayer alloc] init];
        __weak typeof(self) weakSelf = self;
        _audioPlayer.playComplete = ^{
            [weakSelf.musicAnimateView stop];
        };
    }
    return _audioPlayer;
}

- (void)musicClick:(UIButton *)sender {
    
    if (self.audioPlayer.isPlaying) {
        [self.musicAnimateView stop];
        [self.audioPlayer stopPlaying];
    } else {
        [self.musicAnimateView start];
        [self.audioPlayer startPlayWithUrl:self.soundModel.sound isLocalFile:NO];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _musicAnimateView.center = CGPointMake(self.musicView.frame.size.width/2, self.musicView.frame.size.height/2);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
