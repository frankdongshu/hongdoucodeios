//
//  HLFriendsAlbunTableViewCell.m
//  hongdou
//
//  Created by iMac on 2019/10/17.
//  Copyright © 2019 红豆-婚恋网. All rights reserved.
//

#import "HLFriendsAlbunTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "TZImagePreviewController.h"

@interface HLFriendsAlbunTableViewCell ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrView;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation HLFriendsAlbunTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.scrView = [[UIScrollView alloc] init];
        
        [self.contentView addSubview:self.scrView];
        
    }
    return self;
}

- (void)setPhotosArray:(NSArray *)photosArray{
    _photosArray = photosArray;
    
    self.scrView.contentSize = CGSizeMake(photosArray.count*10+photosArray.count*kScreenWidth/3.5+10, self.frame.size.height);
    
    [self.scrView removeAllSubviews];
    
    for (int i=0; i<photosArray.count; i++) {
        
        NSURL *url = [NSURL URLWithString:photosArray[i]];
        
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.layer.cornerRadius = 5;
        imgV.layer.masksToBounds = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.frame = CGRectMake((i+1)*10+kScreenWidth/3.5*i, 10, kScreenWidth/3.5, kScreenWidth/3.5);
        
        imgV.tag = i;
        imgV.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
        [imgV addGestureRecognizer:tap];
        
        NSString *suffix = [[url.absoluteString.lowercaseString componentsSeparatedByString:@"."] lastObject];
        if ([[suffix substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"mp4"]) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
            self.playerLayer.frame = CGRectMake(0, 0, kScreenWidth/3.5, kScreenWidth/3.5);
            [imgV.layer addSublayer:self.playerLayer];
            
            UIImageView *videoImgV = [[UIImageView alloc] init];
            videoImgV.image = [UIImage tz_imageNamedFromMyBundle:@"MMVideoPreviewPlay"];
            [imgV addSubview:videoImgV];
            
            [videoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.centerX.mas_equalTo(imgV);
                make.centerY.mas_equalTo(imgV);
                make.height.width.mas_equalTo(30);
                
            }];
            
            
        } else {
            
            [imgV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
        }
        
        [self.scrView addSubview:imgV];
        
    }
    
    [self.scrView layoutIfNeeded];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrView.frame = self.bounds;
}

- (void)buttonAction:(UITapGestureRecognizer *)tap {
    
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
        
    }];
    
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *str in self.photosArray) {
        [arr addObject:[NSURL URLWithString:str]];
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
