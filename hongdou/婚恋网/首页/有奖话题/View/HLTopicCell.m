//
//  HLTopicCell.m
//  hongdou
//
//  Created by 维康1 on 2020/12/10.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "HLTopicCell.h"
#import <AVFoundation/AVFoundation.h>
#import "TZImagePreviewController.h"
@interface HLTopicCell ()<TZImagePickerControllerDelegate>

// 昵称
@property(nonatomic ,strong) UILabel *nameLab;
// 头像
@property(nonatomic ,strong) UIImageView  *avatar;
// 金牌银牌铜牌
@property(nonatomic ,strong) UIImageView *vipImgV;
// 皇冠
@property(nonatomic ,strong) UIImageView *crownImgV;

// 内容
@property(nonatomic ,strong) YYLabel *contentLab;
// 图片
@property(nonatomic ,strong) UIView *photosView;
// 时间
@property(nonatomic ,strong) UILabel *timeLab;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIButton *likeBtn; // 预览页面喜欢按钮


@property (nonatomic, strong) UIButton *delBtn; // 删除按钮

@property (nonatomic, strong) UIButton *jiangBtn; // 即将获奖

@end

@implementation HLTopicCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpAllView];
//        [self creatPhotoImageView];
    }
    return self;
}

// 主题和动态没分开所以这么麻烦
- (void)setTopicString:(NSString *)topicString andTopicId:(NSString *)topicId andWin:(NSInteger)win {
    
    self.topicId = topicId;
    
    NSString *mianZe = topicString;
    
    NSMutableAttributedString *lawTitle = [[NSMutableAttributedString alloc] initWithString:self.albumModel.content];
    lawTitle.font = [UIFont systemFontOfSize:15];
    lawTitle.color = kRGBA(77, 88, 115, 1);
    
    [lawTitle setTextHighlightRange:[self.albumModel.content rangeOfString:mianZe] color:[UIColor colorWithHex:0xF96781] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        
        [self.delegate fabuClick:topicString andHuaTiId:topicId];
        
        
    }];
    
    
    self.contentLab.attributedText = lawTitle;
    
    // 即将获奖按钮
    if (self.indexPath.row+1 <= win) {
        self.jiangBtn.hidden = NO;
    } else {
        self.jiangBtn.hidden = YES;
    }
    
}

- (void)setAlbumModel:(HLAlbumDetails *)albumModel{
    _albumModel = albumModel;
    
    if (self.indexPath.row == 0) {
        self.vipImgV.image = [UIImage imageNamed:@"topic_jin"];
    } else if (self.indexPath.row == 1) {
        self.vipImgV.image = [UIImage imageNamed:@"topic_yin"];
    } else if (self.indexPath.row == 2) {
        self.vipImgV.image = [UIImage imageNamed:@"topic_tong"];
    } else {
        self.vipImgV.image = nil;
    }
    
    
    if (![[LoginManager defaultManager].userid isEqualToString:albumModel.uid]) {
        self.delBtn.hidden = YES;
    } else {
        self.delBtn.hidden = NO;
    }
    
    if ([albumModel.member isEqualToString:@"0"]) { // 非会员
        
        self.crownImgV.hidden = YES;
        self.avatar.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.avatar.layer.borderWidth = 2; //边框的宽度
    } else { // 会员
        
        self.crownImgV.hidden = NO;
        self.avatar.layer.borderColor=[kRGBA(248, 221, 115, 1) CGColor];
        self.avatar.layer.borderWidth = 2; //边框的宽度
    }
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:albumModel.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    self.nameLab.text = albumModel.nickname;
    
//    self.contentLab.text = albumModel.content;
    
    
    
    [self.photosView removeAllSubviews];
    self.btnArray = [NSMutableArray array];

    if (albumModel.photoArray.count>0) {
        self.photosView.hidden = NO;
        
        CGFloat width;
        
        if (albumModel.photoArray.count == 1) {
            
            width= (kScreenWidth - 160) / 1.f ;
            
        } else if (albumModel.photoArray.count == 2) {
            
            
            width= (kScreenWidth - 109) / 2.f ;
            
        } else {
            
            width= (kScreenWidth - 109) / 3.f ;
            
        }
        
        
        
        [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLab.mas_bottom).offset(10);
            make.left.equalTo(self.nameLab.mas_left);
            make.right.equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo((albumModel.photoArray.count/4 +1) * width + albumModel.photoArray.count/4*10);
            make.bottom.mas_equalTo(-45); // 这句很重要！！！
        }];
        
        [_albumModel.photoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HLPhotoModel *model = obj;
            NSInteger indexX = idx % 3 * (10 + width);
            UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(indexX, idx/3 *(width +10), width, width)];
            photoImageView.tag = idx;
            photoImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
            [photoImageView addGestureRecognizer:tap];
            
            NSURL *url = [NSURL URLWithString:model.url];
            
            NSString *suffix = [[url.absoluteString.lowercaseString componentsSeparatedByString:@"."] lastObject];
            if ([[suffix substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"mp4"]) {
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
                self.player = [AVPlayer playerWithPlayerItem:playerItem];
                self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
                self.playerLayer.frame = CGRectMake(0, 0, width, width);
                [photoImageView.layer addSublayer:self.playerLayer];
                
                UIImageView *videoImgV = [[UIImageView alloc] initWithFrame:CGRectMake(width/3, width/3, width/3, width/3)];
                videoImgV.image = [UIImage tz_imageNamedFromMyBundle:@"MMVideoPreviewPlay"];
                [photoImageView addSubview:videoImgV];
                
            } else {
                
                [photoImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
            }
            
            
            photoImageView.contentMode = UIViewContentModeScaleAspectFill;
            photoImageView.layer.cornerRadius = 3.f;
            photoImageView.layer.masksToBounds = YES;
//            photoImageView.frame = CGRectMake(idx%3*(width + 10), idx/3 * (width +10), width, width);
            [self.photosView addSubview:photoImageView];
            [self.btnArray addObject:photoImageView];

        }];
        
    }else{
        [self.photosView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.photosView.mas_bottom).offset(10);
            make.left.equalTo(self.nameLab.mas_left);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(0);
            make.bottom.mas_equalTo(-45); // 这句很重要！！！
        }];
        self.photosView.hidden = YES;
    }

    self.timeLab.text = albumModel.date;
    
    [self.isLikeButton setTitle:albumModel.vote forState:UIControlStateNormal];
    [self.isLikeButton setSelected:albumModel.isvote];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


// 添加所子控件
-(void)setUpAllView{
    // 头像
    self.avatar = [UIImageView zj_imageViewWithImage:@"icon_head" SuperView:self.contentView contentMode:UIViewContentModeScaleAspectFill isClip:YES constraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(14);
        make.width.height.mas_equalTo(44);
    }];
    
    [self.avatar setContentMode:UIViewContentModeScaleAspectFill];
    self.avatar.layer.cornerRadius = 22.f;
    self.avatar.layer.masksToBounds = YES;
    
    // vip
    self.vipImgV = [UIImageView zj_imageViewWithImage:nil SuperView:self.contentView contentMode:UIViewContentModeScaleAspectFit isClip:YES constraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar.mas_right).offset(-14);
        make.top.mas_equalTo(43);
        make.width.height.mas_equalTo(17);
    }];
    
    // 皇冠
    self.crownImgV = [UIImageView zj_imageViewWithImage:@"icon_crown" SuperView:self.contentView contentMode:UIViewContentModeScaleAspectFit isClip:YES constraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatar.mas_right).offset(-18);
        make.top.mas_equalTo(5);
        make.width.height.mas_equalTo(17);
    }];
    
    // 昵称
    self.nameLab = [UILabel zj_labelWithFontSize:16 textColor:[UIColor colorWithHex:0x3F4658] superView:self.contentView constraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.equalTo(self.avatar.mas_right).offset(5);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    
    
    // 固定样式(即将获奖)
    self.jiangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.jiangBtn setTitle:@"即将获奖" forState:UIControlStateNormal];
    [self.jiangBtn setBackgroundImage:[UIImage imageNamed:@"topic_zi"] forState:UIControlStateNormal];
    self.jiangBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    
    [self.contentView addSubview:self.jiangBtn];
    [self.jiangBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
        
    }];
    
    
    
//    // 内容
//    self.contentLab = [UILabel zj_labelWithFontSize:15 lines:0 text:nil textColor:[UIColor colorWithHex:0x4D5873] superView:self.contentView constraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.nameLab.mas_bottom).offset(8);
//        make.left.equalTo(self.nameLab.mas_left);
//        make.right.equalTo(self.contentView.mas_right).offset(-15);
//        make.height.mas_greaterThanOrEqualTo(20);
//    }];
//
//    self.contentLab.numberOfLines = 0;
    
    
    //
    self.contentLab = [[YYLabel alloc] init];
    self.contentLab.numberOfLines = 0;
    
    self.contentLab.preferredMaxLayoutWidth = kScreenWidth-100;//设置最大宽度
    
    [self.contentView addSubview:self.contentLab];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLab.mas_bottom).offset(8);
        make.left.equalTo(self.nameLab.mas_left);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.height.mas_greaterThanOrEqualTo(20);
    }];
    
    
    

    // 图片
    self.photosView = [[UIView alloc] init];
    [self.contentView addSubview:self.photosView];
    _photosView.userInteractionEnabled = YES;
    [_photosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).offset(10);
        make.left.equalTo(self.nameLab.mas_left);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.height.mas_equalTo(0.001);
    }];
    
#warning 注意  不管你的布局是怎样的 ，一定要有一个(最好是最底部的控件)相对 contentView.bottom的约束，否则计算cell的高度的时候会不正确！
    
    // 时间
    self.timeLab = [UILabel zj_labelWithFontSize:13 textColor:[UIColor colorWithHex:0x8D9AAC] superView:self.contentView constraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photosView.mas_bottom).offset(10);
        make.left.equalTo(self.photosView.mas_left);
        make.width.mas_lessThanOrEqualTo(kScreenWidth/2);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-10); // 这句很重要！！！

    }];
    // 删除按钮
    self.delBtn = [UIButton zj_buttonWithTitle:@"删除" titleColor:[UIColor colorWithHex:0x8D9AAC] norImage:nil selectedImage:nil backColor:nil fontSize:15 isBold:NO cornerRadius:0 supView:self.contentView constraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.timeLab.mas_centerY);
        make.left.equalTo(self.timeLab.mas_right).offset(15);
        
    } touchUp:^(id sender) {
        
        [self.delegate deleteButtonWithUid:self.albumModel.uid andAlbumId:self.albumModel.albumId];
        
    }];
    
    
    self.likesLabel = [UILabel zj_labelWithFontSize:15 textColor:[UIColor colorWithHex:0x8D9AAC] superView:self.contentView constraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photosView.mas_bottom).offset(10);
        make.right.mas_equalTo(-15);
//        make.width.mas_lessThanOrEqualTo(100);
        make.width.mas_greaterThanOrEqualTo(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-10);
        
    }];
    self.likesLabel.textAlignment = NSTextAlignmentLeft;
    
    self.isLikeButton = [UIButton zj_buttonWithTitle:nil titleColor:[UIColor colorWithHex:0x8D9AAC] norImage:[UIImage imageNamed:@"topic_nosel"] selectedImage:[UIImage imageNamed:@"topic_sel"] backColor:nil fontSize:16 isBold:NO cornerRadius:0 supView:self.contentView constraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photosView.mas_bottom).offset(7.5);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    } touchUp:^(id sender) {
        
        [self colletionClick:sender];
    }];
    
    [self.isLikeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    
}

- (void)colletionClick:(UIButton *)sender {
    
    if (sender.selected) {
        NSLog(@"已投票,不能取消");
    } else {
        // 进行投票
        [self requestVote];
    }
    
}

- (void)creatPhotoImageView{
    for (int i=0; i<4; i++) {
        CGFloat width= (kScreenWidth - 109) / 3.f ;
        NSInteger indexX = i % 3 * (10 + width);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(indexX, i/3 *(width +10), width, width)];
        imageView.tag = i;
        imageView.hidden = YES;
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"tupianzhanwei"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
        [imageView addGestureRecognizer:tap];
        [self.btnArray addObject:imageView];
        
    }
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_likeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_likeBtn setSelected:self.albumModel.islikes];
        [_likeBtn setTitle:self.albumModel.likes forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
        [_likeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _likeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_likeBtn addTarget:self action:@selector(colletionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (void)buttonAction:(UITapGestureRecognizer *)tap{
    
    if (![LoginManager defaultManager].isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOWLOGIN object:nil];
        return;
    }
    
    NSInteger viewTag = tap.self.view.tag;
    UIView *view = [self viewWithTag:viewTag];
    
    TZImagePickerController *imagePickerVc = [self createTZImagePickerController];
    imagePickerVc.maxImagesCount = 1;
    imagePickerVc.showSelectBtn = NO;
    [imagePickerVc setPhotoPreviewPageDidLayoutSubviewsBlock:^(UICollectionView *collectionView, UIView *naviBar, UIButton *backButton, UIButton *selectButton, UILabel *indexLabel, UIView *toolBar, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel) {
        if (numberLabel) {
            [numberLabel removeFromSuperview];
            numberLabel = nil;
        }
        if (numberImageView) {
            [numberImageView removeFromSuperview];
            numberImageView = nil;
        }
        if (doneButton) {
            [doneButton removeFromSuperview];
            doneButton = nil;
        }
        
        toolBar.backgroundColor = [UIColor colorWithHex:0x3C3A55];
        
        self.likeBtn.frame = CGRectMake(15, 0, 60, toolBar.frame.size.height);
        
        [toolBar addSubview:self.likeBtn];
        
        
        UIView *labView = [[UIView alloc] init];
        labView.backgroundColor = [UIColor colorWithHex:0x3C3A55 alpha:0.7];
        [toolBar addSubview:labView];
        
        UILabel *lab = [[UILabel alloc] init];
        lab.text = self.albumModel.content;
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:12];
        lab.textColor = [UIColor whiteColor];
        [labView addSubview:lab];
        
        
        [labView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(toolBar.mas_left);
            make.right.equalTo(toolBar.mas_right);
            make.bottom.equalTo(toolBar.mas_top);
        }];
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(labView.mas_left).offset(15);
            make.right.equalTo(labView.mas_right).offset(-15);
            make.bottom.equalTo(labView.mas_bottom).offset(-5);
            make.top.equalTo(labView.mas_top).offset(5);
            
        }];
        
    }];
    
    
    NSMutableArray *arr = [NSMutableArray array];
    for (HLPhotoModel *mod in self.albumModel.photoArray) {
        [arr addObject:[NSURL URLWithString:mod.url]];
    }
    
    TZImagePreviewController *previewVc = [[TZImagePreviewController alloc] initWithPhotos:arr currentIndex:view.tag tzImagePickerVc:imagePickerVc];
    [previewVc setBackButtonClickBlock:^(BOOL isSelectOriginalPhoto) {
        NSLog(@"预览页 返回 isSelectOriginalPhoto:%d", isSelectOriginalPhoto);
    }];
    [previewVc setSetImageWithURLBlock:^(NSURL *URL, UIImageView *imageView, void (^completion)(void)) {
        [imageView sd_setImageWithURL:URL];
    }];
    
    previewVc.modalPresentationStyle = 0;
    [self.viewController presentViewController:previewVc animated:YES completion:nil];
    
//    // 获取当前点击的位置
//    CGPoint selectPoint = [tap locationInView:self];
//    [self.btnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        UIImageView *photoImageView = self.btnArray[idx];
//        // 某个图片区域位置
//        CGRect rect = [self convertRect:photoImageView.frame fromView:self.photosView];
//        // 判断点击点是否在某个课件内
//        if (CGRectContainsPoint(rect, selectPoint)) {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(photoButtonClick:withIndexPath:andIsLike:)]) {
//                [self.delegate photoButtonClick:idx withIndexPath:self.indexPath andIsLike:self.isLikeButton.selected];
//            }
//            *stop = YES;
//        }
//    }];
    
    
}

#pragma mark - TZImagePickerController

- (TZImagePickerController *)createTZImagePickerController {
    [TZImageManager manager].isPreviewNetworkImage = YES;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self pushPhotoPickerVc:NO];
    
#pragma mark - 个性化设置，这些参数都可以不传，此时会走默认设置

    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];

    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.allowPickingMultipleVideo = YES;

    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;

    imagePickerVc.showSelectBtn = NO;
    //imagePickerVc.allowPreview = NO;
    // imagePickerVc.preferredLanguage = @"zh-Hans";

#pragma mark - 到这里为止
    
    return imagePickerVc;
}

- (void)requestVote {
    
    NSDictionary *params = @{@"uid":[LoginManager defaultManager].userid,
                             @"aid":self.albumModel.albumId,
                             @"tid":self.topicId};
    
    [kAppDelegate.window showLoading];
    [HLHTTPSessionManager postDataWithNSString:@"/album/Vote" withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            
            self.isLikeButton.selected = !self.isLikeButton.selected;
            self.likeBtn.selected = !self.likeBtn.selected;
            
            [self.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[self.isLikeButton.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            [self.likeBtn setTitle:[NSString stringWithFormat:@"%d",[self.likeBtn.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            
            
            self.albumModel.isvote = self.isLikeButton.selected;
            self.albumModel.vote = self.isLikeButton.titleLabel.text;
            
            
            
        } else {
            [kAppDelegate.window showTostWithMessage:dictionary[@"msg"]];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
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
