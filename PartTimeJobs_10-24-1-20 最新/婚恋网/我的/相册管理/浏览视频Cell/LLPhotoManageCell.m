//
//  LLPhotoManageCell.m
//  hongdou
//
//  Created by 李龙 on 2020/3/24.
//  Copyright © 2020 红豆-婚恋网. All rights reserved.
//

#import "LLPhotoManageCell.h"
#import "MultipleCollectionCell.h"
#import "TZImagePreviewController.h"

@interface LLPhotoManageCell ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>


@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UIView *picView;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


@property (nonatomic, strong) UIButton *likeButton; // 喜欢按钮

@property (nonatomic, strong) UIButton *likeBtn; // 预览页面喜欢按钮


@end

@implementation LLPhotoManageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 内容
        self.contentLab = [[UILabel alloc] init];
        self.contentLab.numberOfLines = 0;
        self.contentLab.font = kFontSize(14);
        self.contentLab.textColor = [UIColor darkGrayColor];
        [self addSubview:self.contentLab];
        
        // 容器
        self.picView = [[UIView alloc] init];
        [self addSubview:self.picView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_deleteButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
        
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.top.equalTo(self.picView.mas_bottom);
            make.bottom.mas_equalTo(self);
            
        }];
        
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        
        [_likeButton setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateSelected];
        [_likeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_likeButton addTarget:self action:@selector(colletionClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.likeButton];
        
        [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-15);
            make.top.equalTo(self.picView.mas_bottom);
            make.bottom.mas_equalTo(self);
            make.width.mas_equalTo(60);
        }];
        
    }
    return self;
}

- (void)colletionClick:(UIButton *)sender {
    
    if (sender.selected) {
        [self requestCollectionUrl:HLAlbum_DeleteLike];
    }else{
        [self requestCollectionUrl:HLAlbum_Like];
    }
    
}

- (void)requestCollectionUrl:(NSString *)url{
    [kAppDelegate.window showLoading];
    
    NSDictionary *params = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.albumModel.albumId
    };
    
    WeakSelf(weakSelf);
    [HLHTTPSessionManager postDataWithNSString:url withDictionary:params success:^(NSDictionary * _Nonnull dictionary) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [kAppDelegate.window hideLoading];
            self.likeButton.selected = !self.likeButton.selected;
            self.likeBtn.selected = !self.likeBtn.selected;
            
            if ([url isEqualToString:HLAlbum_DeleteLike]) {
                
                [weakSelf.likeButton setTitle:[NSString stringWithFormat:@"%d",[self.likeButton.titleLabel.text intValue]-1] forState:UIControlStateNormal];
                
                [weakSelf.likeBtn setTitle:[NSString stringWithFormat:@"%d",[self.likeBtn.titleLabel.text intValue]-1] forState:UIControlStateNormal];
                
            } else {
                
                [weakSelf.likeButton setTitle:[NSString stringWithFormat:@"%d",[self.likeButton.titleLabel.text intValue]+1] forState:UIControlStateNormal];
                
                [weakSelf.likeBtn setTitle:[NSString stringWithFormat:@"%d",[self.likeBtn.titleLabel.text intValue]+1] forState:UIControlStateNormal];
            }
            
            self.albumModel.islikes = self.likeButton.selected;
            self.albumModel.likes = self.likeButton.titleLabel.text;
            
            
        } else {
            [kAppDelegate.window showTostWithMessage:[dictionary objectForKey:@"msg"]];
        }
    } failure:^(NSError * _Nonnull error) {
        [kAppDelegate.window showTostWithMessage:[error localizedDescription]];
    }];
}

- (void)deleteClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonClickIndexPath:)]) {
        [self.delegate deleteButtonClickIndexPath:self.indexPath];
    }
}

- (void)setAlbumModel:(HLAlbumDetails *)albumModel {
    _albumModel = albumModel;
    
    self.contentLab.text = _albumModel.content;
    
    [self.likeButton setSelected:albumModel.islikes];
    [self.likeButton setTitle:albumModel.likes forState:UIControlStateNormal];
    
    [self.picView removeAllSubviews];
    
    [self.contentLab mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).offset(5);
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        
    }];
    
    [self.picView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLab.mas_bottom).offset(10);
        
        make.left.right.mas_equalTo(self);
        
        NSInteger totalCount = self.albumModel.photoArray.count; //总条数

        NSInteger pageCnt = 3;//每一页填满的个数

        NSInteger pageSize;//页数

        NSInteger a = totalCount % pageCnt;//总数 % 行的个数 =余数  是否等于0判断是否换段

        if (a == 0) {
            pageSize = totalCount / pageCnt;
        } else {
            pageSize = totalCount / pageCnt +1;
        }
        
        make.height.mas_equalTo(pageSize*90+((pageSize-1)*20)+30);
        
    }];
    

    CGFloat gridWidth = 90;//格子的宽度
    CGFloat gridHeight = 90;//格子的高度
    NSInteger rowNumber = 3;//每行几个
    //间距x,y
    CGFloat marginX = (kScreenWidth - gridWidth * rowNumber) / (rowNumber + 1);
    CGFloat marginY = 15;
    for (int i = 0; i < albumModel.photoArray.count ; i++) {
        HLPhotoModel *mod = albumModel.photoArray[i];
        NSURL *url = [NSURL URLWithString:mod.url];
        
        UIView *cellView = [[UIView alloc] init];
        cellView.tag = i;
        cellView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buttonAction:)];
        [cellView addGestureRecognizer:tap];
        
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [cellView addSubview:imgV];
        
        NSString *suffix = [[url.absoluteString.lowercaseString componentsSeparatedByString:@"."] lastObject];
        if ([[suffix substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"mp4"]) {
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
            self.playerLayer.frame = CGRectMake(0, 0, 90, 90);
            [cellView.layer addSublayer:self.playerLayer];
            
            UIImageView *videoImgV = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
            videoImgV.image = [UIImage tz_imageNamedFromMyBundle:@"MMVideoPreviewPlay"];
            [cellView addSubview:videoImgV];
            
        } else {
            
            [imgV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"tupianzhanwei"]];
        }
        
        [self.picView addSubview:cellView];
        
        [cellView mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_equalTo(marginX + i % rowNumber * (gridWidth + marginX));
            make.top.mas_equalTo(marginY + i / rowNumber * (gridHeight + marginY));
            make.width.mas_equalTo(gridWidth);
            make.height.mas_equalTo(gridHeight);
        }];
        
    }

    [self layoutIfNeeded];
    
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
        [self.likeBtn addTarget:self action:@selector(colletionClick:) forControlEvents:UIControlEventTouchUpInside];
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
        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
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
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;

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

@end
