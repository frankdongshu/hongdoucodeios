//
//  HLFindTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/11.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFindTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "TZImagePreviewController.h"

@interface HLFindTableViewCell ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIButton *likeBtn; // 预览页面喜欢按钮

@end

@implementation HLFindTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headImageView.layer.cornerRadius = 22.f;
    self.headImageView.layer.masksToBounds = YES;
    [self.isLikeButton setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
    [self.isLikeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];

    
}
- (void)setAlbumModel:(HLAlbumDetails *)albumModel{
    _albumModel = albumModel;
    
    if ([albumModel.member isEqualToString:@"0"]) { // 非会员
        self.vipImgV.hidden = YES;
        self.crownImgV.hidden = YES;
        self.headImageView.layer.borderColor=[[UIColor whiteColor] CGColor];
        self.headImageView.layer.borderWidth = 2; //边框的宽度
    } else { // 会员
        self.vipImgV.hidden = NO;
        self.crownImgV.hidden = NO;
        self.headImageView.layer.borderColor=[kRGBA(248, 221, 115, 1) CGColor];
        self.headImageView.layer.borderWidth = 2; //边框的宽度
    }
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:albumModel.head] placeholderImage:[UIImage imageNamed:@"icon_head"]];
    self.nickNameLabel.text = albumModel.nickname;
    self.contenLable.text = albumModel.content;
    
    [self.picBackGroudView removeAllSubviews];
    self.btnArray = [NSMutableArray array];

    if (albumModel.photoArray.count>0) {
        
        CGFloat width;
        
        if (albumModel.photoArray.count == 1) {
            width= (kScreenWidth - 160) / 1.f;
        } else if (albumModel.photoArray.count == 2) {
            width= (kScreenWidth - 109) / 2.f;
        } else {
            width= (kScreenWidth - 109) / 3.f;
        }
        
        [self.picBackGroudView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((self.albumModel.photoArray.count/4+1) * width +10);
//            make.bottom.equalTo(self.contentView.mas_bottom).offset(-45);
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
            [self.picBackGroudView addSubview:photoImageView];
            [self.btnArray addObject:photoImageView];

        }];
       
    }else{
        [self.picBackGroudView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    [self.isLikeButton setTitleColor:self.likesLabel.textColor forState:UIControlStateNormal];
    [self.isLikeButton setTitle:albumModel.likes forState:UIControlStateNormal];
    [self.isLikeButton setSelected:albumModel.islikes];
    [self.isLikeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];

    self.dateLabel.text = albumModel.date;
    
    self.cellHight = CGRectGetMaxY(self.picBackGroudView.frame) +48;

    [self setNeedsLayout];
    [self layoutIfNeeded];
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
//        [self.picBackGroudView addSubview:imageView];
        [self.btnArray addObject:imageView];
        
    }
}
- (void)buttonAction:(UITapGestureRecognizer *)tap{
    
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
        
        self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.likeBtn.frame = CGRectMake(15, 0, 60, toolBar.frame.size.height);
        self.likeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.likeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [self.likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [self.likeBtn setSelected:self.albumModel.islikes];
        [self.likeBtn setTitle:self.albumModel.likes forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
        [self.likeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.likeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.likeBtn addTarget:self action:@selector(isLikeClick:) forControlEvents:UIControlEventTouchUpInside];
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
//        CGRect rect = [self convertRect:photoImageView.frame fromView:self.picBackGroudView];
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

- (IBAction)isLikeClick:(UIButton *)sender {
    if (sender.selected) {
        [self requestCollectionUrl:HLAlbum_DeleteLike];
    }else{
        [self requestCollectionUrl:HLAlbum_Like];
    }
    
}


- (void)requestCollectionUrl:(NSString *)url{
    [kAppDelegate.window showLoading];
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:@{@"uid":[LoginManager defaultManager].userid,@"aid":self.albumModel.albumId} success:^(NSDictionary * _Nonnull dictionary) {
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            self.isLikeButton.selected = !self.isLikeButton.selected;
            self.likeBtn.selected = !self.likeBtn.selected;
            
            if ([url isEqualToString:HLAlbum_DeleteLike]) {
                
                [self.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[self.isLikeButton.titleLabel.text intValue]-1] forState:UIControlStateNormal];
                
                [self.likeBtn setTitle:[NSString stringWithFormat:@"%d",[self.likeBtn.titleLabel.text intValue]-1] forState:UIControlStateNormal];
                
            } else {
                
                [self.isLikeButton setTitle:[NSString stringWithFormat:@"%d",[self.isLikeButton.titleLabel.text intValue]+1] forState:UIControlStateNormal];
                
                [self.likeBtn setTitle:[NSString stringWithFormat:@"%d",[self.likeBtn.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            }
            
            self.albumModel.islikes = self.isLikeButton.selected;
            self.albumModel.likes = self.isLikeButton.titleLabel.text;
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(colletionButtonClick)]) {
                [weakSelf.delegate colletionButtonClick];
            }

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
