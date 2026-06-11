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

//@property (nonatomic,strong) NSTimer *timer; // 定时器


@end

@implementation LLPhotoManageCell

- (void)setIsYanPin:(BOOL)isYanPin {
    _isYanPin = isYanPin;
    
    if (isYanPin) {
        _shuaButton.hidden = NO;
        _dateTimeLab.hidden = NO;
        _linkBtn.hidden = NO;
    } else {
        _shuaButton.hidden = YES;
        _dateTimeLab.hidden = YES;
        _linkBtn.hidden = YES;
    }
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // Xcode12 contentView覆盖问题
        self.contentView.hidden = YES;
        
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
        
        // 刷新按钮
        _shuaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shuaButton setTitle:@"刷新" forState:UIControlStateNormal];
        [_shuaButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _shuaButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _shuaButton.tag = self.indexPath.row+90;
        [_shuaButton addTarget:self action:@selector(shuaClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shuaButton];
        
        [_shuaButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.deleteButton.mas_right).offset(15);
            make.top.equalTo(self.picView.mas_bottom);
            make.bottom.mas_equalTo(self);
            
        }];
        
        // 倒计时
        _dateTimeLab = [[UILabel alloc] init];
        _dateTimeLab.textColor = [UIColor lightGrayColor];
        _dateTimeLab.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:_dateTimeLab];
        
        [_dateTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.shuaButton.mas_right).offset(15);
            make.top.equalTo(self.picView.mas_bottom);
            make.bottom.mas_equalTo(self);
            
        }];
        
        // link按钮
        _linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_linkBtn setTitle:@"设置详情链接" forState:UIControlStateNormal];
        [_linkBtn setImage:[UIImage imageNamed:@"weblink"] forState:UIControlStateNormal];
        [_linkBtn setTitleColor:kRGB(96, 162, 203) forState:UIControlStateNormal];
        _linkBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_linkBtn addTarget:self action:@selector(linkClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_linkBtn];
        
        [_linkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.dateTimeLab.mas_right).offset(15);
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
        
        
        // 占位
        self.zwLab = [[UILabel alloc] init];
        
        [self addSubview:self.zwLab];
        
    }
    return self;
}

- (void)colletionClick:(UIButton *)sender {
    
    if (sender.selected) {
        
        if (self.isYanPin) {
            [self requestCollectionUrl:@"/album/abdelLikes"];
        } else {
            [self requestCollectionUrl:HLAlbum_DeleteLike];
        }
        
        
    }else{
        
        if (self.isYanPin) {
            [self requestCollectionUrl:@"/album/ablikes"];
        } else {
            [self requestCollectionUrl:HLAlbum_Like];
        }
        
    }
    
}

// 刷新倒计时
- (void)shuaClick:(UIButton *)sender {
    
    [MBProgressHUD showLoading];
    
    NSDictionary *dic = @{
        @"uid":[LoginManager defaultManager].userid,
        @"aid":self.albumModel.albumId
    };
    
    [HLHTTPSessionManager postDataWithNSString:@"/album/abrenovate" withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        NSLog(@"---: %@",dictionary);
        
        NSString *code = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"code"]];
        if ([code isEqualToString:@"200"] ) {
            [MBProgressHUD hideLoading];
            
            self.dateTimeLab.text = @"24:00:00";
            
            
        } else {
            [MBProgressHUD showMessage:dictionary[@"msg"] view:nil];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showMessage:error.localizedDescription view:nil];
    }];
    
}

// 设置link
- (void)linkClick:(UIButton *)sender {
    
    [self.delegate linkButtonClickWithTag:sender.tag oldUrl:self.zwLab.text];
    
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
            
            if ([url isEqualToString:HLAlbum_DeleteLike] || [url isEqualToString:@"/album/abdelLikes"]) {
                
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteButtonClickIndexPath:andMessage:)]) {
        [self.delegate deleteButtonClickIndexPath:self.indexPath andMessage:self.isYanPin?@"确认删除信息?":@"确认删除此相册?"];
    }
}

-(NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime {
    
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value % (24 * 3600)/3600;
    int day = (int)value / (24 * 3600);
    NSString *str;
//    if (day != 0 && day > 0) {
//        str = [NSString stringWithFormat:@"%d天%d小时%d分%d秒后过期",day,house,minute,second];
//    }else if (day==0 && house != 0 && house>0) {
//        str = [NSString stringWithFormat:@"%d小时%d分%d秒后过期",house,minute,second];
//    }else if (day== 0 && house== 0 && minute!=0 && minute>0) {
//        str = [NSString stringWithFormat:@"%d分%d秒后过期",minute,second];
//    }else if (day < 0 || house< 0 || minute<0 || second<0) {
//        str = @"已过期";
//    }else{
//        str = [NSString stringWithFormat:@"%d秒后过期",second];
//    }
    
    
    // 00:00:00:00 格式显示
    if (day < 0 || house< 0 || minute<0 || second<0) {
        str = @"已过期";
    } else if (house==0 && minute==0 && second==0) {
        str = @"24:00:00";
    } else {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d",house,minute,second];
    }
    
    
    return str;
    
}

- (void)setAlbumModel:(HLAlbumDetails *)albumModel {
    _albumModel = albumModel;
    
    
    self.zwLab.text = albumModel.url;
    
    self.linkBtn.tag = [albumModel.albumId integerValue];
    
    self.contentLab.text = _albumModel.content;
    
    // 截止时间
    NSString *deadlineStr = _albumModel.datetime;
    // 当前时间的时间戳
    NSString *nowStr = [self getCurrentTimeyyyymmdd];
    
    self.dateTimeLab.text = [self dateTimeDifferenceWithStartTime:nowStr endTime:deadlineStr];
    
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



//// 倒计时
//- (void)starDaoJiShiClick:(NSInteger)secondsCountDown {
//
//    __weak __typeof(self) weakSelf = self;
//    if (_timer == nil) {
//        __block NSInteger timeout = secondsCountDown; // 倒计时时间
//        if (timeout!=0) {
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC,  0); //每秒执行
//            dispatch_source_set_event_handler(_timer, ^{
//                if(timeout <= 0){ //  当倒计时结束时做需要的操作: 关闭 活动到期不能提交
//                    dispatch_source_cancel(_timer);
//                    _timer = nil;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        weakSelf.dateTimeLab.text = @"已下架";
//                    });
//                } else { // 倒计时重新计算 时/分/秒
//                    NSInteger days = (int)(timeout/(3600*24));
//                    NSInteger hours = (int)((timeout-days*24*3600)/3600);
//                    NSInteger minute = (int)(timeout-days*24*3600-hours*3600)/60;
//                    NSInteger second = timeout - days*24*3600 - hours*3600 - minute*60;
//                    NSString *strTime = [NSString stringWithFormat:@"%02ld时%02ld分%02ld秒后下架", hours, minute, second];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (days == 0) {
//                            weakSelf.dateTimeLab.text = strTime;
//                        } else {
//                            weakSelf.dateTimeLab.text = [NSString stringWithFormat:@"%ld天 %02ld时 %02ld分 %02ld秒", days, hours, minute, second];
//                        }
//                    });
//                    timeout--; // 递减 倒计时-1(总时间以秒来计算)
//                }
//            });
//            dispatch_resume(_timer);
//        }
//    }
//
//}

@end
